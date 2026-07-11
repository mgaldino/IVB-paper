task13_capture_warnings <- function(expr) {
  warnings <- character()
  value <- withCallingHandlers(
    expr,
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  list(value = value, warnings = unique(warnings))
}

task13_twoway_demean <- function(values, id, time) {
  values -
    ave(values, id, FUN = mean) -
    ave(values, time, FUN = mean) +
    mean(values)
}

task13_fit_within <- function(panel, include_Z_lag) {
  x_names <- c("D", "Y_lag")
  if (isTRUE(include_Z_lag)) {
    x_names <- c(x_names, "Z_lag")
  }

  x_raw <- as.matrix(dplyr::select(panel, dplyr::all_of(x_names)))
  y_raw <- panel$Y
  id <- panel$id
  time <- panel$time

  X <- apply(
    x_raw,
    2L,
    task13_twoway_demean,
    id = id,
    time = time
  )
  if (is.null(dim(X))) {
    X <- matrix(X, ncol = 1L)
  }
  colnames(X) <- x_names
  y <- task13_twoway_demean(y_raw, id = id, time = time)

  xtx <- crossprod(X)
  if (!is.finite(kappa(xtx)) || kappa(xtx) > 1e12) {
    stop("Within design matrix is singular or ill-conditioned.", call. = FALSE)
  }

  bread <- solve(xtx)
  coefficients <- as.vector(bread %*% crossprod(X, y))
  names(coefficients) <- x_names
  residuals <- as.vector(y - X %*% coefficients)

  score_rows <- X * residuals
  cluster_scores <- rowsum(score_rows, group = id, reorder = TRUE)
  influence <- cluster_scores %*% bread
  colnames(influence) <- x_names

  G <- nrow(cluster_scores)
  n <- nrow(X)
  k <- ncol(X)
  correction <- (G / (G - 1)) * ((n - 1) / (n - k))
  vcov <- correction * crossprod(influence)

  list(
    coefficient_D = unname(coefficients["D"]),
    se_D = sqrt(unname(vcov["D", "D"])),
    influence_D = unname(influence[, "D"]),
    nobs = n,
    n_clusters = G,
    condition_number = kappa(xtx)
  )
}

task13_fit_fe_pair <- function(panel) {
  list(
    short = task13_fit_within(panel, include_Z_lag = FALSE),
    long = task13_fit_within(panel, include_Z_lag = TRUE)
  )
}

task13_fit_hpj_pair <- function(panel, full_pair = NULL) {
  if (is.null(full_pair)) {
    full_pair <- task13_fit_fe_pair(panel)
  }

  T_periods <- max(panel$time)
  split_point <- floor(T_periods / 2)
  first_half <- panel[panel$time <= split_point]
  second_half <- panel[panel$time > split_point]

  T_first <- data.table::uniqueN(first_half$time)
  T_second <- data.table::uniqueN(second_half$time)
  if (min(T_first, T_second) < 4L) {
    stop("Each half panel must contain at least four periods.", call. = FALSE)
  }

  first_pair <- task13_fit_fe_pair(first_half)
  second_pair <- task13_fit_fe_pair(second_half)
  weight_first <- T_first / T_periods
  weight_second <- T_second / T_periods
  N_clusters <- data.table::uniqueN(panel$id)

  combine <- function(specification) {
    full <- full_pair[[specification]]
    half_1 <- first_pair[[specification]]
    half_2 <- second_pair[[specification]]

    estimate <- 2 * full$coefficient_D -
      weight_first * half_1$coefficient_D -
      weight_second * half_2$coefficient_D

    influence <- 2 * full$influence_D -
      weight_first * half_1$influence_D -
      weight_second * half_2$influence_D

    variance <- (N_clusters / (N_clusters - 1)) * sum(influence^2)

    list(
      coefficient_D = estimate,
      se_D = sqrt(variance),
      nobs = full$nobs,
      n_clusters = N_clusters,
      T_first = T_first,
      T_second = T_second,
      weight_first = weight_first,
      weight_second = weight_second
    )
  }

  list(short = combine("short"), long = combine("long"))
}

task13_ab_formula <- function(include_Z_lag, lag_min, lag_max) {
  lag_window <- sprintf("%d:%d", lag_min, lag_max)
  if (isTRUE(include_Z_lag)) {
    stats::as.formula(paste0(
      "Y ~ lag(Y, 1) + D + Z_lag | ",
      "lag(Y, ", lag_window, ") + ",
      "lag(D, ", lag_window, ") + ",
      "lag(Z_lag, ", lag_window, ")"
    ))
  } else {
    stats::as.formula(paste0(
      "Y ~ lag(Y, 1) + D | ",
      "lag(Y, ", lag_window, ") + ",
      "lag(D, ", lag_window, ")"
    ))
  }
}

task13_fit_ab <- function(panel, include_Z_lag, parameters) {
  # pgmm() evaluates an internal, unqualified plm() call in its caller frame.
  # Binding it locally keeps namespace use explicit without attaching packages.
  plm <- plm::plm
  pdata <- plm::pdata.frame(
    as.data.frame(panel),
    index = c("id", "time"),
    drop.index = FALSE,
    row.names = FALSE
  )

  formula <- task13_ab_formula(
    include_Z_lag = include_Z_lag,
    lag_min = parameters$ab_lag_min,
    lag_max = parameters$ab_lag_max
  )

  captured <- task13_capture_warnings(
    plm::pgmm(
      formula,
      data = pdata,
      effect = "individual",
      model = "onestep",
      transformation = "d",
      collapse = TRUE
    )
  )
  model <- captured$value

  robust_summary <- summary(model, robust = TRUE)
  coefficient_table <- robust_summary$coefficients
  if (!"D" %in% rownames(coefficient_table)) {
    stop("Arellano-Bond did not return the contemporaneous D coefficient.", call. = FALSE)
  }

  instrument_count <- max(vapply(model$W, ncol, integer(1)))
  if (instrument_count > parameters$ab_max_instruments) {
    stop(
      sprintf(
        "Arellano-Bond instrument count %d exceeds pre-specified limit %d.",
        instrument_count,
        parameters$ab_max_instruments
      ),
      call. = FALSE
    )
  }

  robust_vcov <- plm::vcovHC(
    model,
    method = "arellano",
    type = "HC0",
    cluster = "group"
  )
  ar2 <- plm::mtest(model, order = 2L, vcov = robust_vcov)
  hansen <- plm::sargan(model, weights = "twosteps")

  list(
    coefficient_D = unname(coefficient_table["D", "Estimate"]),
    se_D = unname(coefficient_table["D", "Std. Error"]),
    nobs = stats::nobs(model),
    n_clusters = data.table::uniqueN(panel$id),
    instrument_count = instrument_count,
    ar2_p = unname(ar2$p.value),
    hansen_p = unname(hansen$p.value),
    warnings = paste(captured$warnings, collapse = " | ")
  )
}

task13_fit_ab_pair <- function(panel, parameters) {
  list(
    short = task13_fit_ab(panel, include_Z_lag = FALSE, parameters = parameters),
    long = task13_fit_ab(panel, include_Z_lag = TRUE, parameters = parameters)
  )
}

task13_safe_fit <- function(expr) {
  tryCatch(
    list(status = "ok", result = force(expr), error_message = NA_character_),
    error = function(e) {
      list(
        status = "failed",
        result = NULL,
        error_message = conditionMessage(e)
      )
    }
  )
}
