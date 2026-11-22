#!/usr/bin/env Rscript
# Conditional AIM1 cost model. Input must be a reviewed private staged CSV.

Sys.umask("0077")

required <- c("row_id", "status", "deac20", "age_index", "sex",
              "person_days", "person_years", "cost_eur_2023")

check_input <- function(x, scenario) {
  if (!identical(names(x), required) || nrow(x) != 527L ||
      !identical(x$row_id, paste0("row", seq_len(527L))) ||
      anyNA(x$status) || !scenario %in% c("R_P", "E2_S0"))
    stop("INPUT_SCHEMA", call. = FALSE)
  d <- x[x$status == "ELIGIBLE", , drop = FALSE]
  if (nrow(d) == 0L || anyNA(d[, required[-c(1L, 2L)], drop = FALSE]) ||
      any(!is.finite(d$deac20) | d$deac20 < 0 | d$deac20 > 1) ||
      any(!is.finite(d$age_index) | d$age_index < 0 | d$age_index > 120) ||
      any(!d$sex %in% c("F", "M")) ||
      any(!is.finite(d$person_days) | d$person_days <= 0 |
          d$person_days != floor(d$person_days)) ||
      any(!is.finite(d$person_years) | d$person_years <= 0) ||
      any(abs(d$person_years - d$person_days / 365.25) > 1e-10) ||
      any(!is.finite(d$cost_eur_2023) | d$cost_eur_2023 < 0))
    stop("INPUT_VALUE", call. = FALSE)
  d$sex <- factor(d$sex, levels = c("F", "M"))
  d$deac_per_0_1 <- d$deac20 / 0.1
  d$log_person_years <- log(d$person_years)
  d$positive <- as.integer(d$cost_eur_2023 > 0)
  d
}

fit_parts <- function(d) {
  if (nrow(d) < 30L || sum(d$positive) < 10L || sum(!d$positive) < 10L)
    stop("INSUFFICIENT_OUTCOME_VARIATION", call. = FALSE)
  rhs <- ~ deac_per_0_1 + age_index + sex + log_person_years
  if (qr(stats::model.matrix(rhs, d))$rank < ncol(stats::model.matrix(rhs, d)) ||
      qr(stats::model.matrix(rhs, d[d$positive == 1L, , drop = FALSE]))$rank <
        ncol(stats::model.matrix(rhs, d[d$positive == 1L, , drop = FALSE])))
    stop("DESIGN_RANK_DEFICIENT", call. = FALSE)
  warnings <- character()
  capture <- function(expr) withCallingHandlers(expr, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  logit <- capture(stats::glm(positive ~ deac_per_0_1 + age_index + sex +
                               log_person_years, family = stats::binomial(), data = d))
  gamma <- capture(stats::glm(cost_eur_2023 ~ deac_per_0_1 + age_index + sex +
                               log_person_years, family = stats::Gamma(link = "log"),
                             data = d[d$positive == 1L, , drop = FALSE]))
  if (length(warnings) || !isTRUE(logit$converged) || !isTRUE(gamma$converged))
    stop("FIT_WARNING_OR_NONCONVERGENCE", call. = FALSE)
  if (any(!is.finite(stats::coef(logit))) || any(!is.finite(stats::coef(gamma))) ||
      any(stats::fitted(logit) < 1e-8 | stats::fitted(logit) > 1 - 1e-8))
    stop("SEPARATION_OR_COEFFICIENT_UNRESOLVED", call. = FALSE)
  list(logit = logit, gamma = gamma)
}

standardized_rate <- function(fits, target, score) {
  target$deac_per_0_1 <- score / 0.1
  p <- stats::predict(fits$logit, newdata = target, type = "response")
  mu <- stats::predict(fits$gamma, newdata = target, type = "response")
  if (any(!is.finite(p) | !is.finite(mu) | p < 0 | p > 1 | mu <= 0))
    stop("PREDICTION_INVALID", call. = FALSE)
  sum(p * mu) / sum(target$person_years)
}

summarize_fit <- function(d, scenario, bootstrap_n = 1000L, seed = 20261106L) {
  if (min(d$deac20) > 0.4 || max(d$deac20) < 0.5)
    stop("STANDARDIZATION_OUTSIDE_SCORE_RANGE", call. = FALSE)
  fits <- fit_parts(d)
  rate_04 <- standardized_rate(fits, d, 0.4)
  rate_05 <- standardized_rate(fits, d, 0.5)
  original <- c(rate_04 = rate_04, rate_05 = rate_05,
                difference = rate_05 - rate_04, ratio = rate_05 / rate_04)
  set.seed(seed)
  draws <- matrix(NA_real_, bootstrap_n, 4L)
  colnames(draws) <- names(original)
  failures <- 0L
  for (b in seq_len(bootstrap_n)) {
    sample <- d[sample.int(nrow(d), nrow(d), replace = TRUE), , drop = FALSE]
    value <- tryCatch({
      fitted <- fit_parts(sample)
      a <- standardized_rate(fitted, d, 0.4)
      z <- standardized_rate(fitted, d, 0.5)
      c(a, z, z - a, z / a)
    }, error = function(e) NULL)
    if (is.null(value) || any(!is.finite(value))) failures <- failures + 1L
    else draws[b, ] <- value
  }
  if (failures > bootstrap_n * 0.05)
    stop("BOOTSTRAP_FAILURE_THRESHOLD", call. = FALSE)
  intervals <- lapply(seq_len(ncol(draws)), function(j)
    unname(stats::quantile(draws[, j], c(0.025, 0.975), na.rm = TRUE)))
  names(intervals) <- names(original)
  list(schema = "aim1-cost-two-part-v1", status = "PRIVATE_REVIEW_REQUIRED",
       source_semantics = "ASSUMPTION_BASED", scenario = scenario,
       model_n = nrow(d), positive_n = sum(d$positive),
       assumed_zero_n = sum(!d$positive), person_years = sum(d$person_years),
       model_formulas = list(logit = deparse(stats::formula(fits$logit)),
                             gamma = deparse(stats::formula(fits$gamma))),
       time_rule = "Cumulative EUR response; estimated log(person_years) covariate in both parts; no offset",
       target = "All eligible persons' fixed age, sex and follow-up; DEAC20 set to 0.4 or 0.5",
       combined_eur_per_person_year = as.list(original),
       combined_ci95_percentile = intervals,
       bootstrap = list(n = bootstrap_n, seed = seed, failed = failures),
       deac_coefficients_per_0_1 = list(logit = unname(stats::coef(fits$logit)[["deac_per_0_1"]]),
                                       gamma = unname(stats::coef(fits$gamma)[["deac_per_0_1"]])),
       diagnostics = list(logit_max_fitted = max(stats::fitted(fits$logit)),
                          gamma_dispersion = summary(fits$gamma)$dispersion,
                          gamma_max_abs_pearson = max(abs(stats::residuals(fits$gamma, type = "pearson"))),
                          gamma_max_cook = max(stats::cooks.distance(fits$gamma))))
}

self_test <- function() {
  set.seed(42)
  n <- 527L
  d <- data.frame(row_id = paste0("row", seq_len(n)), status = "ELIGIBLE",
                  deac20 = stats::runif(n, 0.2, 0.8),
                  age_index = sample(60:90, n, TRUE),
                  sex = sample(c("F", "M"), n, TRUE),
                  person_days = sample(365:1800, n, TRUE))
  d$person_years <- d$person_days / 365.25
  logit <- -1 + 0.2 * d$deac20 / 0.1 + 0.1 * log(d$person_years)
  d$cost_eur_2023 <- ifelse(stats::rbinom(n, 1, stats::plogis(logit)) == 1,
                            stats::rgamma(n, shape = 2, scale = 350), 0)
  d <- check_input(d[, required], "R_P")
  result <- summarize_fit(d, "R_P", bootstrap_n = 20L, seed = 17L)
  stopifnot(result$combined_eur_per_person_year$rate_05 > 0,
            result$combined_eur_per_person_year$ratio > 0,
            result$bootstrap$n == 20L)
  bad <- d
  bad$cost_eur_2023[1] <- NA_real_
  stopifnot(inherits(try(check_input(bad[, required], "R_P"), silent = TRUE), "try-error"))
  all_positive <- d
  all_positive$positive <- 1L
  stopifnot(inherits(try(fit_parts(all_positive), silent = TRUE), "try-error"))
  separated <- d
  separated$positive <- as.integer(separated$deac20 > 0.5)
  separated$cost_eur_2023 <- ifelse(separated$positive == 1L, 100, 0)
  stopifnot(inherits(try(fit_parts(separated), silent = TRUE), "try-error"))
  cat("AIM1_COST_TWO_PART_SYNTHETIC_PASS\n")
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  safe <- c("INPUT_SCHEMA", "INPUT_VALUE", "INSUFFICIENT_OUTCOME_VARIATION",
            "DESIGN_RANK_DEFICIENT", "FIT_WARNING_OR_NONCONVERGENCE",
            "SEPARATION_OR_COEFFICIENT_UNRESOLVED",
            "STANDARDIZATION_OUTSIDE_SCORE_RANGE", "PREDICTION_INVALID",
            "BOOTSTRAP_FAILURE_THRESHOLD", "PACKAGE_MISSING", "OUTPUT_EXISTS", "USAGE")
  tryCatch({
    if (identical(args, "--self-test")) self_test()
    else if (length(args) == 3L) {
      if (!requireNamespace("jsonlite", quietly = TRUE)) stop("PACKAGE_MISSING", call. = FALSE)
      if (file.exists(args[[3]])) stop("OUTPUT_EXISTS", call. = FALSE)
      input <- utils::read.csv(args[[1]], stringsAsFactors = FALSE, check.names = FALSE)
      d <- check_input(input, args[[2]])
      result <- summarize_fit(d, args[[2]])
      jsonlite::write_json(result, args[[3]], auto_unbox = TRUE, pretty = TRUE,
                           digits = 10, na = "null")
    } else stop("USAGE", call. = FALSE)
  }, error = function(e) {
    code <- conditionMessage(e)
    if (!code %in% safe) code <- "UNKNOWN"
    cat(paste0("AIM1_COST_MODEL_ERROR_CLASS=", code, "\n"))
    quit(status = 2L)
  })
}
