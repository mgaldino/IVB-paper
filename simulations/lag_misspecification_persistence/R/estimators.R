lmp_twoway_demean <- function(values, N, TT) {
  value_matrix <- matrix(values, nrow = N, ncol = TT, byrow = TRUE)
  demeaned <- sweep(value_matrix, 1L, rowMeans(value_matrix), "-")
  demeaned <- sweep(demeaned, 2L, colMeans(value_matrix), "-")
  as.vector(t(demeaned + mean(value_matrix)))
}

lmp_prepare_within <- function(panel, parameters) {
  data.table::setorderv(panel, c("id", "time"))
  N <- data.table::uniqueN(panel$id)
  TT <- data.table::uniqueN(panel$time)
  if (nrow(panel) != N * TT || any(table(panel$id) != TT)) {
    stop("Within transformation requires a balanced panel.", call. = FALSE)
  }
  variable_names <- c(
    "Y", "D", "Z", "Z_lag",
    paste0("D_lag_", parameters$candidate_lags),
    paste0("Y_lag_", parameters$candidate_lags)
  )
  source_data <- dplyr::select(panel, dplyr::all_of(variable_names))
  demeaned <- lapply(
    source_data,
    lmp_twoway_demean,
    N = N,
    TT = TT
  )
  list(
    y = demeaned$Y,
    x = as.matrix(as.data.frame(demeaned[names(demeaned) != "Y"])),
    id = panel$id,
    time = panel$time,
    N = N,
    TT = TT
  )
}

lmp_residual_acf1 <- function(residuals, id, time) {
  residual_data <- data.table::data.table(id = id, time = time, residual = residuals)
  data.table::setorder(residual_data, id, time)
  pairs <- residual_data[, .(residual, lag_residual = data.table::shift(residual)), by = id]
  pairs <- pairs[is.finite(residual) & is.finite(lag_residual)]
  if (nrow(pairs) < 3L || stats::sd(pairs$residual) == 0 || stats::sd(pairs$lag_residual) == 0) {
    return(NA_real_)
  }
  stats::cor(pairs$residual, pairs$lag_residual)
}

lmp_fit_within <- function(prepared, lag_order, control_spec) {
  x_names <- c(
    "D",
    paste0("Y_lag_", seq_len(lag_order)),
    paste0("D_lag_", seq_len(lag_order))
  )
  if (identical(control_spec, "Z_lag")) {
    x_names <- c(x_names, "Z_lag")
  }
  if (identical(control_spec, "Z_contemporaneous")) {
    x_names <- c(x_names, "Z")
  }
  X <- prepared$x[, x_names, drop = FALSE]
  y <- prepared$y
  xtx <- crossprod(X)
  condition_number <- kappa(xtx)
  if (!is.finite(condition_number) || condition_number > 1e12) {
    stop("Within design matrix is singular or ill-conditioned.", call. = FALSE)
  }
  bread <- solve(xtx)
  coefficients <- as.vector(bread %*% crossprod(X, y))
  names(coefficients) <- x_names
  residuals <- as.vector(y - X %*% coefficients)
  cluster_scores <- rowsum(X * residuals, group = prepared$id, reorder = TRUE)
  G <- nrow(cluster_scores)
  n <- nrow(X)
  k <- ncol(X)
  correction <- (G / (G - 1)) * ((n - 1) / (n - k))
  vcov <- correction * bread %*% crossprod(cluster_scores) %*% bread
  se_D <- sqrt(unname(vcov["D", "D"]))
  rss <- sum(residuals ^ 2)
  list(
    beta_hat = unname(coefficients["D"]),
    se = se_D,
    ci_lower = unname(coefficients["D"] - stats::qnorm(0.975) * se_D),
    ci_upper = unname(coefficients["D"] + stats::qnorm(0.975) * se_D),
    residual_acf1 = lmp_residual_acf1(residuals, prepared$id, prepared$time),
    aic = n * log(rss / n) + 2 * k,
    bic = n * log(rss / n) + log(n) * k,
    nobs = n,
    n_clusters = G,
    condition_number = condition_number
  )
}

lmp_safe_fit <- function(prepared, lag_order, control_spec) {
  tryCatch(
    {
      result <- lmp_fit_within(prepared, lag_order, control_spec)
      c(list(status = "ok", error_stage = NA_character_, error_message = NA_character_), result)
    },
    error = function(error) {
      list(
        status = "failed",
        error_stage = "estimator",
        error_message = conditionMessage(error),
        beta_hat = NA_real_, se = NA_real_, ci_lower = NA_real_, ci_upper = NA_real_,
        residual_acf1 = NA_real_, aic = NA_real_, bic = NA_real_, nobs = NA_integer_,
        n_clusters = NA_integer_, condition_number = NA_real_
      )
    }
  )
}

lmp_select_lag <- function(candidate_fits, criterion, candidate_lags) {
  if (any(vapply(candidate_fits, function(fit) !identical(fit$status, "ok"), logical(1)))) {
    return(list(
      status = "failed",
      selected_lag = NA_integer_,
      error_stage = "selection",
      error_message = "At least one pre-specified Z_lag candidate failed; criterion not applied."
    ))
  }
  score <- vapply(candidate_fits, `[[`, numeric(1), tolower(criterion))
  list(
    status = "ok",
    selected_lag = candidate_lags[which.min(score)],
    error_stage = NA_character_,
    error_message = NA_character_
  )
}
