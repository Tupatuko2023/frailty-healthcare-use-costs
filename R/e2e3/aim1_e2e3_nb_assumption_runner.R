#!/usr/bin/env Rscript
# Private four-model E2/E3 proxy runner. Input is a staged 527-row CSV.

Sys.umask("0077")

run <- function(input, output) {
  if (!requireNamespace("MASS", quietly = TRUE) ||
      !requireNamespace("jsonlite", quietly = TRUE)) {
    stop("PACKAGE_MISSING", call. = FALSE)
  }
  x <- utils::read.csv(input, stringsAsFactors = FALSE, na.strings = c("", "NA"),
                       check.names = FALSE)
  needed <- c("row_id", "status", "deac20", "age_index",
              "sex_encoded_in_bridge_hetu", "person_days", "person_years",
              "E2_S0", "E2_S1", "E3_S0", "E3_S1")
  if (!identical(names(x), needed) || nrow(x) != 527L ||
      !identical(x$row_id, paste0("row", seq_len(527L))) ||
      anyNA(x$status)) {
    stop("INPUT_SCHEMA", call. = FALSE)
  }
  active <- x$status == "ELIGIBLE"
  d <- x[active, , drop = FALSE]
  if (nrow(d) > 0L && (anyNA(d[, needed[-c(1L, 2L)]]) ||
                       any(!is.finite(d$deac20)) || any(d$deac20 < 0 | d$deac20 > 1) ||
                       any(!is.finite(d$age_index)) || any(d$age_index < 0 | d$age_index > 120) ||
                       any(!d$sex_encoded_in_bridge_hetu %in% c("F", "M")) ||
                       any(!is.finite(d$person_years)) || any(d$person_years <= 0) ||
                       any(abs(d$person_years - d$person_days / 365.25) > 1e-10))) {
    stop("INPUT_VALUE", call. = FALSE)
  }
  outcomes <- c("E2_S0", "E2_S1", "E3_S0", "E3_S1")
  if (nrow(d) > 0L && any(vapply(d[, outcomes, drop = FALSE],
      function(y) any(!is.finite(y) | y < 0 | y != floor(y)), logical(1)))) {
    stop("COUNT_VALUE", call. = FALSE)
  }
  if (nrow(d) > 0L && (any(d$E2_S1 < d$E2_S0) || any(d$E3_S1 < d$E3_S0))) {
    stop("COUNT_PARITY", call. = FALSE)
  }
  d$deac_per_0_1 <- d$deac20 / 0.1
  d$sex_encoded_in_bridge_hetu <- factor(d$sex_encoded_in_bridge_hetu,
                                          levels = c("F", "M"))
  model_one <- function(yname) {
    y <- d[[yname]]
    base <- list(status = "NOT_ESTIMABLE", n = nrow(d),
                 count_sum = sum(y), person_years = sum(d$person_years),
                 response_unit = if (startsWith(yname, "E2_"))
                   "INCLUSIVE_UNION_DAY_PROXY" else "CANDIDATE_START_COUNT_PROXY")
    if (nrow(d) < 8L || sum(y) == 0L || length(unique(y)) < 2L ||
        length(unique(d$deac20)) < 2L || length(unique(d$age_index)) < 2L ||
        length(unique(d$sex_encoded_in_bridge_hetu)) < 2L) {
      base$reason <- "INSUFFICIENT_VARIATION"
      return(base)
    }
    frame <- data.frame(y = y, deac_per_0_1 = d$deac_per_0_1,
                        age_index = d$age_index,
                        sex = d$sex_encoded_in_bridge_hetu,
                        person_years = d$person_years)
    formula <- y ~ deac_per_0_1 + age_index + sex + offset(log(person_years))
    if (qr(stats::model.matrix(formula, data = frame))$rank <
        ncol(stats::model.matrix(formula, data = frame))) {
      base$reason <- "DESIGN_RANK_DEFICIENT"
      return(base)
    }
    warned <- FALSE
    fit <- tryCatch(withCallingHandlers(
      MASS::glm.nb(formula, data = frame, link = log),
      warning = function(w) { warned <<- TRUE; invokeRestart("muffleWarning") }
    ), error = function(e) NULL)
    if (is.null(fit)) {
      base$reason <- "FIT_FAILED"
      return(base)
    }
    if (warned || !isTRUE(fit$converged)) {
      base$status <- "FIT_WARNING"
      base$reason <- "WARNING_OR_NONCONVERGENCE"
      return(base)
    }
    coef <- summary(fit)$coefficients
    if (!"deac_per_0_1" %in% rownames(coef) ||
        !all(is.finite(coef["deac_per_0_1", c("Estimate", "Std. Error")])) ||
        coef["deac_per_0_1", "Std. Error"] <= 0 ||
        !is.finite(fit$theta) || fit$theta <= 0) {
      base$status <- "FIT_WARNING"
      base$reason <- "COEFFICIENT_UNRESOLVED"
      return(base)
    }
    beta <- unname(coef["deac_per_0_1", "Estimate"])
    se <- unname(coef["deac_per_0_1", "Std. Error"])
    base$status <- "ESTIMATED"
    base$irr_per_0_1 <- exp(beta)
    base$ci95_wald <- c(exp(beta - 1.95996398454005 * se),
                        exp(beta + 1.95996398454005 * se))
    base$theta <- unname(fit$theta)
    base$aic <- stats::AIC(fit)
    diagnostic <- tryCatch({
      pearson <- stats::residuals(fit, type = "pearson")
      cook <- stats::cooks.distance(fit)
      list(status = "COMPUTED", pearson_dispersion = sum(pearson^2) / fit$df.residual,
           observed_zeros = sum(y == 0),
           expected_zeros = sum(stats::dnbinom(0, mu = stats::fitted(fit), size = fit$theta)),
           max_abs_pearson = max(abs(pearson)), max_cooks_distance = max(cook))
    }, error = function(e) list(status = "DIAGNOSTIC_FAILED"))
    if (diagnostic$status == "COMPUTED" &&
        any(!is.finite(unlist(diagnostic[-1])))) {
      diagnostic <- list(status = "DIAGNOSTIC_FAILED")
    }
    base$diagnostic <- diagnostic
    diagnostic_pdf <- file.path(dirname(output), paste0("diagnostic_", yname, ".pdf"))
    opened <- FALSE
    plot_ok <- tryCatch({
      grDevices::pdf(diagnostic_pdf, width = 9, height = 7, family = "sans")
      opened <- TRUE
      graphics::par(mfrow = c(2L, 2L))
      pearson <- stats::residuals(fit, type = "pearson")
      cooks <- stats::cooks.distance(fit)
      graphics::plot(stats::fitted(fit), pearson, pch = 16L, cex = 0.4,
                     xlab = "Fitted proxy count", ylab = "Pearson residual",
                     main = "Residual pattern")
      graphics::abline(h = 0, col = "gray50")
      graphics::plot(seq_along(cooks), cooks, pch = 16L, cex = 0.4,
                     xlab = "Anonymous row order", ylab = "Cook distance",
                     main = "Influence; no automatic removal")
      eta <- stats::predict(fit, type = "link")
      work <- eta + (y - stats::fitted(fit)) / stats::fitted(fit)
      co <- stats::coef(fit)
      for (term in c("deac_per_0_1", "age_index")) {
        xx <- frame[[term]]
        partial <- work - eta + co[[term]] * xx
        graphics::plot(xx, partial, pch = 16L, cex = 0.4,
                       xlab = term, ylab = "Log-link partial residual",
                       main = paste("Descriptive form:", term))
        graphics::abline(a = 0, b = co[[term]], col = "gray50")
        if (length(unique(xx)) >= 5L) {
          sm <- stats::lowess(xx, partial)
          graphics::lines(sm, col = "red3", lwd = 2)
        }
      }
      grDevices::dev.off()
      opened <- FALSE
      TRUE
    }, error = function(e) {
      if (opened) grDevices::dev.off()
      FALSE
    })
    if (!plot_ok && file.exists(diagnostic_pdf)) unlink(diagnostic_pdf)
    base$diagnostic_plot <- if (plot_ok) basename(diagnostic_pdf) else "PLOT_FAILED"
    base
  }
  models <- setNames(lapply(outcomes, model_one), outcomes)
  result <- list(
    schema = "aim1-e2e3-nb-model-results-v1",
    status = if (all(vapply(models, function(m) m$status == "ESTIMATED", logical(1))))
      "FOUR_MODELS_ESTIMATED" else "FOUR_MODELS_WITH_ISSUES",
    source_people = 527L,
    model_eligible_n = nrow(d),
    model_status_counts = as.list(table(x$status)),
    total_person_years = sum(d$person_years),
    model_formula = "proxy_count ~ deac20/0.1 + age_index + sex_encoded_in_bridge_hetu + offset(log(person_years))",
    package = list(MASS = as.character(utils::packageVersion("MASS")),
                   jsonlite = as.character(utils::packageVersion("jsonlite")),
                   R = as.character(getRversion())),
    models = models)
  jsonlite::write_json(result, output, auto_unbox = TRUE, pretty = TRUE,
                       digits = 10, na = "null")
  invisible(result)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 2L) quit(status = 2L)
  tryCatch(run(args[[1]], args[[2]]), error = function(e) quit(status = 2L))
}
