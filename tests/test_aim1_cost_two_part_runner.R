#!/usr/bin/env Rscript

test <- function() {
  stopifnot(length(commandArgs(trailingOnly = TRUE)) == 0L)
  script <- grep("^--file=", commandArgs(), value = TRUE)
  stopifnot(length(script) == 1L)
  script <- normalizePath(sub("^--file=", "", script), mustWork = TRUE)
  runner <- file.path(dirname(dirname(script)), "R", "cost",
                      "aim1_cost_two_part_runner.R")

  Sys.umask("0077")
  folder <- tempfile("aim1-cost-synthetic-")
  stopifnot(dir.create(folder, mode = "0700"))
  on.exit(unlink(folder, recursive = TRUE), add = TRUE)
  input <- file.path(folder, "synthetic.csv")
  output <- file.path(folder, "synthetic.json")
  invoke <- function(scenario) {
    system2(file.path(R.home("bin"), "Rscript"),
            c("--vanilla", shQuote(c(runner, input, scenario, output))),
            stdout = TRUE, stderr = TRUE)
  }
  write_fixture <- function(rows) {
    utils::write.csv(rows, input, row.names = FALSE, na = "")
  }
  near <- function(actual, expected) {
    stopifnot(isTRUE(all.equal(unname(actual), unname(expected), tolerance = 1e-8)))
  }

  set.seed(427)
  n <- 527L
  included <- seq_len(n) <= 489L
  score <- runif(n, 0.1, 0.8)
  age <- sample(58:90, n, replace = TRUE)
  sex <- sample(c("F", "M"), n, replace = TRUE)
  days <- sample(180:1500, n, replace = TRUE)
  years <- days / 365.25
  probability <- plogis(-0.8 + 0.12 * (score / 0.1) + 0.4 * log(years))
  positive <- rbinom(n, 1L, probability)
  mean_cost <- 400 * exp(0.08 * (score / 0.1) + 0.55 * log(years))
  cost <- positive * rgamma(n, shape = 4, scale = mean_cost / 4)
  fixture <- data.frame(
    row_id = paste0("row", seq_len(n)),
    status = ifelse(included, "ELIGIBLE", "SYNTHETIC_EXCLUDED"),
    deac20 = score, age_index = age, sex = sex,
    person_days = days, person_years = years, cost_eur_2023 = cost
  )
  fixture[!included, -(1:2)] <- NA
  write_fixture(fixture)
  log <- invoke("R_P")
  if (!is.null(attr(log, "status"))) stop(paste(log, collapse = "\n"))
  report <- jsonlite::fromJSON(output)

  # Reference fits verify the estimated time terms and the combined prediction.
  frame <- data.frame(
    cost = cost[included], positive = positive[included],
    score = score[included] / 0.1, age = age[included],
    sex = factor(sex[included], levels = c("F", "M")), time = log(years[included])
  )
  binary <- glm(positive ~ score + age + sex + time,
                family = binomial(), data = frame)
  gamma <- glm(cost ~ score + age + sex + time, family = Gamma(link = "log"),
               data = frame, subset = positive == 1L)
  rates <- vapply(c(0.4, 0.5), function(value) {
    target <- frame
    target$score <- value / 0.1
    sum(predict(binary, target, type = "response") *
          predict(gamma, target, type = "response")) / sum(years[included])
  }, numeric(1))
  results <- c(rate_04 = rates[1], rate_05 = rates[2],
               difference = rates[2] - rates[1], ratio = rates[2] / rates[1])

  stopifnot(
    report$schema == "aim1-cost-two-part-v1",
    report$status == "PRIVATE_REVIEW_REQUIRED",
    report$source_semantics == "ASSUMPTION_BASED",
    report$scenario == "R_P",
    report$model_n == sum(included),
    report$positive_n == sum(positive[included]),
    report$assumed_zero_n == sum(positive[included] == 0L),
    identical(names(report$model_formulas), c("logit", "gamma")),
    identical(names(report$combined_eur_per_person_year), names(results)),
    identical(names(report$combined_ci95_percentile), names(results)),
    report$bootstrap$n == 1000L, report$bootstrap$seed == 20261106L,
    report$bootstrap$failed >= 0L, report$bootstrap$failed <= 50L,
    all(is.finite(unlist(report$diagnostics)))
  )
  for (formula in report$model_formulas) {
    terms <- terms(as.formula(paste(formula, collapse = " ")))
    stopifnot(
      identical(attr(terms, "term.labels"),
                c("deac_per_0_1", "age_index", "sex", "log_person_years")),
      is.null(attr(terms, "offset"))
    )
  }
  near(report$person_years, sum(years[included]))
  near(report$deac_coefficients_per_0_1$logit, coef(binary)[["score"]])
  near(report$deac_coefficients_per_0_1$gamma, coef(gamma)[["score"]])
  near(unlist(report$combined_eur_per_person_year), results)
  for (interval in report$combined_ci95_percentile) {
    stopifnot(length(interval) == 2L, all(is.finite(interval)), diff(interval) >= 0)
  }

  expect_failure <- function(rows, code, scenario = "R_P") {
    write_fixture(rows)
    log <- suppressWarnings(invoke(scenario))
    stopifnot(identical(attr(log, "status"), 2L),
              identical(as.vector(log), paste0("AIM1_COST_MODEL_ERROR_CLASS=", code)),
              !file.exists(output))
  }
  output <- file.path(folder, "rejected.json")
  expect_failure(fixture[-n, ], "INPUT_SCHEMA")
  expect_failure(fixture, "INPUT_SCHEMA", "SYNTHETIC_UNKNOWN")
  invalid <- fixture
  invalid$cost_eur_2023[1] <- NA_real_
  expect_failure(invalid, "INPUT_VALUE")
  invalid$cost_eur_2023[1] <- -1
  expect_failure(invalid, "INPUT_VALUE")
  invalid <- fixture
  invalid$person_years[1] <- invalid$person_years[1] + 1
  expect_failure(invalid, "INPUT_VALUE")
  invalid <- fixture
  invalid$cost_eur_2023[included] <- 0
  expect_failure(invalid, "INSUFFICIENT_OUTCOME_VARIATION")
  invalid <- fixture
  invalid$deac20[included] <- 0.55
  expect_failure(invalid, "STANDARDIZATION_OUTSIDE_SCORE_RANGE")

  cat("PASS 8/8: both model parts, combined predictions, JSON, bootstrap",
      "and seven rejected synthetic inputs\n")
}

test()
