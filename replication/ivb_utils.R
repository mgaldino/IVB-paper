# IVB utilities for applied models with one or many treatment terms.
#
# Main identity implemented in this script:
#   beta_j* - beta_j = -theta* * pi_j
# where:
#   - theta* is the coefficient of collider z in the long model
#   - pi_j is the coefficient of treatment term d_j in the auxiliary model z ~ d + w

#' Compute Included Variable Bias (IVB) for one or many treatment terms.
#'
#' This function computes IVB using nested `fixest::feols` models:
#'   1) Short model: y ~ d_vars + w | fe
#'   2) Long model:  y ~ d_vars + w + z | fe
#'   3) Auxiliary:   z ~ d_vars + w | fe
#'
#' For each treatment term d_j, it returns:
#'   - IVB formula: -theta* * pi_j
#'   - Direct difference: beta_j(long) - beta_j(short)
#'   - Numeric check: formula - direct difference
#'
#' @param data A data frame containing all variables.
#' @param y Character scalar. Outcome variable name.
#' @param d_vars Character vector. Treatment variables (e.g., c("D_t", "D_t_1")).
#' @param z Character scalar. Suspected collider included only in the long model.
#' @param w Character vector. Legitimate controls used in short, long, and auxiliary models.
#' @param fe Character vector. Fixed effects to absorb in all models (e.g., c("unit_id", "year")).
#' @param vcov Variance-covariance setting passed to `fixest::feols` (default "iid").
#' @param na_action Character scalar. "omit" drops rows with missing values in required variables;
#'   "fail" stops if any missing value is found.
#'
#' @return A list with:
#'   - inputs: input arguments used in estimation.
#'   - formulas: formulas for short, long, and auxiliary models.
#'   - sample_n: number of complete cases used.
#'   - theta: coefficient on collider z in the long model.
#'   - results: data.frame with one row per treatment term and IVB diagnostics.
#'   - models: fitted feols objects (short, long, auxiliary).
#'
#' @examples
#' # res <- compute_ivb_multi(
#' #   data = df,
#' #   y = "y",
#' #   d_vars = c("D_t", "D_t_1"),
#' #   z = "Z_t",
#' #   w = c("X1", "X2"),
#' #   fe = c("unit_id", "year")
#' # )
#' # res$results
compute_ivb_multi <- function(data,
                              y,
                              d_vars,
                              z,
                              w = character(),
                              fe = character(),
                              vcov = "iid",
                              na_action = c("omit", "fail")) {
  na_action <- match.arg(na_action)

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required. Install it with install.packages('dplyr').", call. = FALSE)
  }
  if (!requireNamespace("fixest", quietly = TRUE)) {
    stop("Package 'fixest' is required. Install it with install.packages('fixest').", call. = FALSE)
  }

  if (!is.data.frame(data)) {
    stop("'data' must be a data.frame.", call. = FALSE)
  }
  if (!is.character(y) || length(y) != 1L) {
    stop("'y' must be a single character string.", call. = FALSE)
  }
  if (!is.character(z) || length(z) != 1L) {
    stop("'z' must be a single character string.", call. = FALSE)
  }
  if (!is.character(d_vars) || length(d_vars) < 1L) {
    stop("'d_vars' must be a character vector with at least one treatment variable.", call. = FALSE)
  }
  if (!is.character(w)) {
    stop("'w' must be a character vector.", call. = FALSE)
  }
  if (!is.character(fe)) {
    stop("'fe' must be a character vector.", call. = FALSE)
  }

  d_vars <- unique(d_vars)
  w <- unique(w)
  fe <- unique(fe)

  if (z %in% d_vars) {
    stop("Collider 'z' cannot also appear in 'd_vars'.", call. = FALSE)
  }
  if (z %in% w) {
    stop("Collider 'z' cannot also appear in 'w'.", call. = FALSE)
  }
  if (y %in% c(d_vars, w, z)) {
    stop("Outcome 'y' cannot also appear in d_vars, w, or z.", call. = FALSE)
  }
  if (z %in% fe) {
    stop("Collider 'z' cannot also appear in 'fe'.", call. = FALSE)
  }
  if (any(d_vars %in% fe)) {
    stop("Treatment variables in 'd_vars' cannot also appear in 'fe'.", call. = FALSE)
  }

  required_vars <- unique(c(y, d_vars, z, w, fe))
  missing_vars <- setdiff(required_vars, names(data))
  if (length(missing_vars) > 0L) {
    stop(
      paste0("Missing variable(s) in 'data': ", paste(missing_vars, collapse = ", ")),
      call. = FALSE
    )
  }

  df <- dplyr::select(data, dplyr::all_of(required_vars))

  if (na_action == "omit") {
    df <- df[stats::complete.cases(df), , drop = FALSE]
  } else if (anyNA(df)) {
    stop("Missing values found. Use na_action = 'omit' to drop incomplete rows.", call. = FALSE)
  }

  if (nrow(df) == 0L) {
    stop("No observations available after NA handling.", call. = FALSE)
  }

  rhs_short <- c(d_vars, w)
  rhs_long <- c(d_vars, w, z)
  rhs_aux <- c(d_vars, w)

  build_feols_formula <- function(lhs, rhs_terms, fe_terms) {
    rhs <- if (length(rhs_terms) > 0L) paste(rhs_terms, collapse = " + ") else "1"
    if (length(fe_terms) > 0L) {
      stats::as.formula(paste0(lhs, " ~ ", rhs, " | ", paste(fe_terms, collapse = " + ")))
    } else {
      stats::as.formula(paste0(lhs, " ~ ", rhs))
    }
  }

  f_short <- build_feols_formula(lhs = y, rhs_terms = rhs_short, fe_terms = fe)
  f_long <- build_feols_formula(lhs = y, rhs_terms = rhs_long, fe_terms = fe)
  f_aux <- build_feols_formula(lhs = z, rhs_terms = rhs_aux, fe_terms = fe)

  m_short <- fixest::feols(fml = f_short, data = df, vcov = vcov)
  m_long <- fixest::feols(fml = f_long, data = df, vcov = vcov)
  m_aux <- fixest::feols(fml = f_aux, data = df, vcov = vcov)

  coef_short <- stats::coef(m_short)
  coef_long <- stats::coef(m_long)
  coef_aux <- stats::coef(m_aux)

  theta <- unname(coef_long[[z]])
  beta_short <- unname(coef_short[d_vars])
  beta_long <- unname(coef_long[d_vars])
  pi_vals <- unname(coef_aux[d_vars])

  if (is.na(theta)) {
    stop("Estimated coefficient for collider 'z' is NA. Check collinearity in long model.", call. = FALSE)
  }
  if (anyNA(beta_short) || anyNA(beta_long) || anyNA(pi_vals)) {
    stop(
      "At least one treatment coefficient is NA. Check collinearity or variable coding.",
      call. = FALSE
    )
  }

  ivb_formula <- -theta * pi_vals
  ivb_direct <- beta_long - beta_short

  results <- data.frame(
    term = d_vars,
    beta_short = beta_short,
    beta_long = beta_long,
    theta = rep(theta, length(d_vars)),
    pi = pi_vals,
    ivb_formula = ivb_formula,
    ivb_direct = ivb_direct,
    diff_check = ivb_formula - ivb_direct,
    stringsAsFactors = FALSE
  )

  list(
    inputs = list(y = y, d_vars = d_vars, z = z, w = w, fe = fe, vcov = vcov, na_action = na_action),
    formulas = list(short = f_short, long = f_long, auxiliary = f_aux),
    sample_n = nrow(df),
    theta = theta,
    results = results,
    models = list(short = m_short, long = m_long, auxiliary = m_aux)
  )
}

# Quick use
# source("replication/ivb_utils.R")
#
# res <- compute_ivb_multi(
#   data = df,
#   y = "y",
#   d_vars = c("D_t", "D_t_1"),
#   z = "Z_t",
#   w = c("X1", "X2"),
#   fe = c("unit_id", "year")
# )
#
# res$results
