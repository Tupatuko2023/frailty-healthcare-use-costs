#!/usr/bin/env Rscript

test <- function() {
  stopifnot(length(commandArgs(trailingOnly = TRUE)) == 0L)
  script <- grep("^--file=", commandArgs(), value = TRUE)
  script <- normalizePath(sub("^--file=", "", script), mustWork = TRUE)
  runner <- file.path(dirname(dirname(script)), "R", "e2e3",
                      "aim1_e2e3_nb_assumption_runner.R")
  stopifnot(file.exists(runner))

  Sys.umask("0077")
  folder <- tempfile("aim1-e2e3-synthetic-")
  stopifnot(dir.create(folder, mode = "0700"))
  on.exit(unlink(folder, recursive = TRUE), add = TRUE)
  input <- file.path(folder, "synthetic.csv")
  output <- file.path(folder, "synthetic.json")

  set.seed(527)
  n <- 527L
  eligible <- seq_len(n) <= 480L
  deac <- runif(n, 0.05, 0.6)
  age <- sample(65:99, n, replace = TRUE)
  sex <- sample(c("F", "M"), n, replace = TRUE)
  days <- sample(90:730, n, replace = TRUE)
  years <- days / 365.25
  starts <- rnbinom(n, size = 1.5, mu = years * exp(0.4 + 2 * deac))
  s1 <- rpois(n, 0.6)
  day_extra <- rpois(n, 1.2)
  fixture <- data.frame(
    row_id = paste0("row", seq_len(n)),
    status = ifelse(eligible, "ELIGIBLE", "SYNTHETIC_EXCLUDED"),
    deac20 = deac,
    age_index = age,
    sex_encoded_in_bridge_hetu = sex,
    person_days = days,
    person_years = years,
    E2_S0 = 2L * starts + day_extra,
    E2_S1 = 2L * (starts + s1) + day_extra,
    E3_S0 = starts,
    E3_S1 = starts + s1
  )
  fixture[!eligible, -(1:2)] <- NA
  utils::write.csv(fixture, input, row.names = FALSE, na = "")
  exit_status <- system2(file.path(R.home("bin"), "Rscript"),
                         c("--vanilla", shQuote(c(runner, input, output))))
  stopifnot(exit_status == 0L)
  result <- jsonlite::fromJSON(output)
  models <- c("E2_S0", "E2_S1", "E3_S0", "E3_S1")
  person_years <- sum(years[eligible])
  stopifnot(
    result$schema == "aim1-e2e3-nb-model-results-v1",
    result$status == "FOUR_MODELS_ESTIMATED",
    result$source_people == n,
    result$model_eligible_n == sum(eligible),
    result$model_status_counts$ELIGIBLE == sum(eligible),
    result$model_status_counts$SYNTHETIC_EXCLUDED == sum(!eligible),
    abs(result$total_person_years - person_years) < 1e-7,
    identical(names(result$package), c("MASS", "jsonlite", "R")),
    identical(names(result$models), models)
  )
  for (name in models) {
    model <- result$models[[name]]
    unit <- if (startsWith(name, "E2")) "INCLUSIVE_UNION_DAY_PROXY" else
      "CANDIDATE_START_COUNT_PROXY"
    pdf <- paste0("diagnostic_", name, ".pdf")
    stopifnot(
      model$status == "ESTIMATED",
      model$response_unit == unit,
      model$n == sum(eligible),
      model$count_sum == sum(fixture[[name]][eligible]),
      abs(model$person_years - person_years) < 1e-7,
      is.finite(model$irr_per_0_1), model$irr_per_0_1 > 0,
      length(model$ci95_wald) == 2L,
      all(is.finite(model$ci95_wald)), model$ci95_wald[1] > 0,
      model$ci95_wald[1] < model$irr_per_0_1,
      model$irr_per_0_1 < model$ci95_wald[2],
      is.finite(model$theta), model$theta > 0, is.finite(model$aic),
      model$diagnostic$status == "COMPUTED", model$diagnostic_plot == pdf,
      identical(readChar(file.path(folder, pdf), 5L, useBytes = TRUE), "%PDF-")
    )
  }

  # The CLI maps all failures to status 2. Call the same entry function
  # to verify the specific validation error for each synthetic input.
  scope <- new.env()
  sys.source(runner, envir = scope)
  bad_input <- file.path(folder, "invalid.csv")
  bad_output <- file.path(folder, "invalid.json")
  expect_failure <- function(rows, expected) {
    utils::write.csv(rows, bad_input, row.names = FALSE, na = "")
    error <- tryCatch(scope$run(bad_input, bad_output), error = identity)
    stopifnot(inherits(error, "error"), conditionMessage(error) == expected,
              !file.exists(bad_output))
  }
  expect_failure(fixture[-n, ], "INPUT_SCHEMA")
  invalid <- fixture
  invalid$person_years[1] <- invalid$person_years[1] + 1
  expect_failure(invalid, "INPUT_VALUE")
  invalid <- fixture
  invalid$E3_S0[1] <- -1L
  expect_failure(invalid, "COUNT_VALUE")
  invalid <- fixture
  invalid$E2_S1[1] <- invalid$E2_S0[1]
  invalid$E2_S0[1] <- invalid$E2_S1[1] + 1L
  expect_failure(invalid, "COUNT_PARITY")

  degenerate <- fixture
  degenerate$deac20[eligible] <- 0.1
  utils::write.csv(degenerate, input, row.names = FALSE, na = "")
  result <- scope$run(input, file.path(folder, "degenerate.json"))
  stopifnot(
    result$status == "FOUR_MODELS_WITH_ISSUES",
    all(vapply(result$models, function(model) {
      identical(model$status, "NOT_ESTIMABLE") &&
        identical(model$reason, "INSUFFICIENT_VARIATION")
    }, logical(1)))
  )

  cat("PASS 6/6: four E2/E3 models, JSON and PDFs, four input errors,",
      "and insufficient variation\n")
}

test()
