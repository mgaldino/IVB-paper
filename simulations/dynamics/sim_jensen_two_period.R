# ============================================================================
# sim_jensen_two_period.R
# Jensen-calibrated two-period DiD: safe adjustment vs time-varying controls
#
# Goal
# ----
# Replicate the empirical geometry found in Jensen (2025):
#   1. A baseline DiD with prior-voting x post adjustment
#   2. The same model + realized time-varying controls (TVCs)
#   3. A "safe" model with pre-treatment covariates x post
#   4. The full model with both safe-adjustment and TVCs
#
# We simulate three scenarios:
#   A. jensen_full_like       : safe block moves more than TVCs; TVCs are small
#   B. jensen_restricted_like : TVCs move in the opposite direction of safe block
#   C. ivb_post_dominant      : TVCs dominate the total shift
#
# DGP intuition
# -------------
# D_i is binary, non-staggered, and correlated with baseline X.
# Untreated post-period trends depend on X and prior voting V.
# Realized post-period controls are dual-role:
#   - Zm is mediator-like: affected by D and predictive of Y
#   - Zc is collider-like: affected by D and an unobserved post shock U
#     that also affects Y
#
# The true ATT_total is:
#   tau_total = tau_direct + y_zm * zm_d + y_zc * zc_d
#
# Output
# ------
# results/sim_jensen_two_period_summary.csv
# results/sim_jensen_two_period_raw.csv
# results/sim_jensen_two_period_decomp.csv
# results/sim_jensen_two_period_scenarios.csv
# results/sim_jensen_two_period_sessioninfo.txt
# ============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(future.apply)
  library(readr)
  library(tibble)
})

options(scipen = 999)

parse_args <- function(args) {
  get_arg <- function(flag, default) {
    idx <- match(flag, args)
    if (is.na(idx) || idx == length(args)) {
      default
    } else {
      args[[idx + 1]]
    }
  }

  list(
    n_reps = as.integer(get_arg("--reps", "500")),
    n_units = as.integer(get_arg("--n", "5000")),
    workers = as.integer(get_arg("--workers", "4")),
    seed = as.integer(get_arg("--seed", "20260323")),
    out_dir = get_arg("--out-dir", "results")
  )
}

cfg <- parse_args(commandArgs(trailingOnly = TRUE))
set.seed(cfg$seed)

make_scenarios <- function() {
  common <- list(
    sigma_alpha = 0.35,
    lambda_post = 0.10,
    v_intercept = -0.10,
    v_x1 = 0.35,
    v_x2 = -0.20,
    d_intercept = -0.25,
    d_x1 = 0.45,
    d_x2 = -0.35,
    d_v = 0.35,
    y_v = 0.18,
    y_x1 = 0.05,
    y_x2 = -0.04,
    sigma_y0 = 0.35,
    sigma_y1 = 0.35,
    sigma_zm0 = 0.40,
    sigma_zm1 = 0.35,
    sigma_zc0 = 0.40,
    sigma_zc1 = 0.35,
    zm0_x1 = 0.45,
    zm0_x2 = -0.20,
    zc0_x1 = 0.20,
    zc0_x2 = 0.10,
    zm_ar = 0.35,
    zc_ar = 0.35,
    zm_x1 = 0.35,
    zm_x2 = -0.20,
    zc_x1 = 0.25,
    zc_x2 = 0.15,
    zm_u = 0.00,
    zc_u = 0.00,
    y_zm = 0.09,
    y_zc = 0.00,
    y_u = 0.00,
    tau_direct = 0.10,
    zm_d = 0.12,
    zc_d = 0.00,
    target_base_minus_safe = 0.026,
    target_full_minus_safe = -0.005,
    target_tvc_minus_base = -0.007
  )

  scenario_a <- utils::modifyList(common, list(
    scenario = "jensen_full_like",
    tau_direct = 0.104,
    zm_d = 0.08,
    zc_d = 0.00,
    y_u = 0.00,
    zc_u = 0.00,
    d_x1 = 0.40,
    d_x2 = -0.30,
    y_x1 = 0.045,
    y_x2 = -0.035
  ))

  scenario_b <- utils::modifyList(common, list(
    scenario = "jensen_restricted_like",
    tau_direct = 0.072,
    zm_d = 0.09,
    zc_d = 0.35,
    zc_u = 0.80,
    y_u = -0.08,
    d_intercept = -0.55,
    d_x1 = 0.35,
    d_x2 = -0.25,
    y_x1 = 0.035,
    y_x2 = -0.025,
    target_base_minus_safe = 0.018,
    target_full_minus_safe = 0.012,
    target_tvc_minus_base = 0.010
  ))

  scenario_c <- utils::modifyList(common, list(
    scenario = "ivb_post_dominant",
    tau_direct = 0.08,
    zm_d = 0.10,
    zc_d = 0.75,
    zc_u = 1.10,
    y_u = -0.16,
    d_x1 = 0.50,
    d_x2 = -0.35,
    y_x1 = 0.04,
    y_x2 = -0.03,
    target_base_minus_safe = 0.015,
    target_full_minus_safe = 0.025,
    target_tvc_minus_base = 0.020
  ))

  list(scenario_a, scenario_b, scenario_c)
}

att_total <- function(pars) {
  pars$tau_direct + pars$y_zm * pars$zm_d + pars$y_zc * pars$zc_d
}

simulate_two_period_panel <- function(n_units, pars) {
  x1 <- rnorm(n_units)
  x2 <- rnorm(n_units)
  alpha_i <- rnorm(n_units, 0, pars$sigma_alpha)
  u_post <- rnorm(n_units)

  p_v <- plogis(pars$v_intercept + pars$v_x1 * x1 + pars$v_x2 * x2)
  v <- rbinom(n_units, 1, p_v)

  p_d <- plogis(
    pars$d_intercept + pars$d_x1 * x1 + pars$d_x2 * x2 + pars$d_v * v
  )
  d <- rbinom(n_units, 1, p_d)

  zm0 <- pars$zm0_x1 * x1 + pars$zm0_x2 * x2 + rnorm(n_units, 0, pars$sigma_zm0)
  zc0 <- pars$zc0_x1 * x1 + pars$zc0_x2 * x2 + rnorm(n_units, 0, pars$sigma_zc0)

  zm1 <- pars$zm_ar * zm0 + pars$zm_d * d + pars$zm_x1 * x1 +
    pars$zm_x2 * x2 + pars$zm_u * u_post + rnorm(n_units, 0, pars$sigma_zm1)
  zc1 <- pars$zc_ar * zc0 + pars$zc_d * d + pars$zc_x1 * x1 +
    pars$zc_x2 * x2 + pars$zc_u * u_post + rnorm(n_units, 0, pars$sigma_zc1)

  y0 <- alpha_i + pars$y_zm * zm0 + pars$y_zc * zc0 + rnorm(n_units, 0, pars$sigma_y0)
  y1 <- alpha_i + pars$lambda_post + pars$y_v * v +
    pars$y_x1 * x1 + pars$y_x2 * x2 +
    pars$tau_direct * d + pars$y_zm * zm1 + pars$y_zc * zc1 +
    pars$y_u * u_post + rnorm(n_units, 0, pars$sigma_y1)

  tibble(
    id = rep(seq_len(n_units), each = 2),
    time = rep(0:1, times = n_units),
    Post = rep(0:1, times = n_units),
    D = rep(d, each = 2),
    V = rep(v, each = 2),
    X1 = rep(x1, each = 2),
    X2 = rep(x2, each = 2),
    Zm = as.vector(rbind(zm0, zm1)),
    Zc = as.vector(rbind(zc0, zc1)),
    Y = as.vector(rbind(y0, y1))
  ) |>
    mutate(id_f = factor(id))
}

extract_estimate <- function(model, term = "Post:D") {
  vc <- vcov(model)
  coef_table <- summary(model)$coeftable

  tibble(
    estimate = unname(coef(model)[[term]]),
    std_error = sqrt(vc[term, term]),
    conf_low = estimate - qnorm(0.975) * std_error,
    conf_high = estimate + qnorm(0.975) * std_error,
    p_value = unname(coef_table[term, "Pr(>|t|)"])
  )
}

estimate_specs <- function(dt) {
  dt <- dt |>
    mutate(
      D = as.numeric(D),
      Post = as.numeric(Post),
      V = as.numeric(V)
    )

  models <- list(
    base = feols(Y ~ Post + Post:D + Post:V | id_f, data = dt, vcov = ~id_f),
    tvc = feols(Y ~ Post + Post:D + Post:V + Zm + Zc | id_f, data = dt, vcov = ~id_f),
    safe = feols(Y ~ Post + Post:D + Post:V + Post:X1 + Post:X2 | id_f, data = dt, vcov = ~id_f),
    full = feols(Y ~ Post + Post:D + Post:V + Post:X1 + Post:X2 + Zm + Zc | id_f, data = dt, vcov = ~id_f)
  )

  bind_rows(lapply(names(models), function(spec) {
    extract_estimate(models[[spec]]) |>
      mutate(spec = spec, .before = 1)
  }))
}

run_rep <- function(rep_id, pars, n_units) {
  dt <- simulate_two_period_panel(n_units, pars)
  est <- estimate_specs(dt)
  est |>
    mutate(
      rep = rep_id,
      scenario = pars$scenario,
      att_true = att_total(pars),
      treat_share = mean(dt$D[dt$Post == 1]),
      n_units = n_units,
      n_obs = nrow(dt)
    )
}

summarize_results <- function(raw_results, scenarios_tbl) {
  summary_specs <- raw_results |>
    group_by(scenario, att_true, spec) |>
    summarise(
      mean_estimate = mean(estimate),
      bias = mean(estimate - att_true),
      rmse = sqrt(mean((estimate - att_true)^2)),
      coverage = mean(conf_low <= att_true & conf_high >= att_true),
      mcse = sd(estimate) / sqrt(n()),
      n_sims = n(),
      .groups = "drop"
    )

  decomp <- raw_results |>
    select(scenario, rep, spec, estimate) |>
    tidyr::pivot_wider(names_from = spec, values_from = estimate) |>
    mutate(
      base_minus_safe = base - safe,
      full_minus_safe = full - safe,
      tvc_minus_base = tvc - base
    ) |>
    group_by(scenario) |>
    summarise(
      mean_base = mean(base),
      mean_tvc = mean(tvc),
      mean_safe = mean(safe),
      mean_full = mean(full),
      achieved_base_minus_safe = mean(base_minus_safe),
      achieved_full_minus_safe = mean(full_minus_safe),
      achieved_tvc_minus_base = mean(tvc_minus_base),
      mcse_base_minus_safe = sd(base_minus_safe) / sqrt(n()),
      mcse_full_minus_safe = sd(full_minus_safe) / sqrt(n()),
      mcse_tvc_minus_base = sd(tvc_minus_base) / sqrt(n()),
      .groups = "drop"
    ) |>
    left_join(
      scenarios_tbl |>
        select(
          scenario,
          target_base_minus_safe,
          target_full_minus_safe,
          target_tvc_minus_base
        ),
      by = "scenario"
    ) |>
    mutate(
      gap_base_minus_safe = achieved_base_minus_safe - target_base_minus_safe,
      gap_full_minus_safe = achieved_full_minus_safe - target_full_minus_safe,
      gap_tvc_minus_base = achieved_tvc_minus_base - target_tvc_minus_base
    )

  list(summary_specs = summary_specs, decomp = decomp)
}

save_outputs <- function(raw_results, summary_specs, decomp, scenarios_tbl, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  write_csv(raw_results, file.path(out_dir, "sim_jensen_two_period_raw.csv"))
  write_csv(summary_specs, file.path(out_dir, "sim_jensen_two_period_summary.csv"))
  write_csv(decomp, file.path(out_dir, "sim_jensen_two_period_decomp.csv"))
  write_csv(scenarios_tbl, file.path(out_dir, "sim_jensen_two_period_scenarios.csv"))
  writeLines(
    capture.output(sessionInfo()),
    file.path(out_dir, "sim_jensen_two_period_sessioninfo.txt")
  )
}

scenarios <- make_scenarios()
scenarios_tbl <- bind_rows(lapply(scenarios, function(x) tibble(!!!x))) |>
  mutate(att_true = vapply(scenarios, att_total, numeric(1)))

cat(rep("=", 72), "\n", sep = "")
cat("SIM: JENSEN-CALIBRATED TWO-PERIOD DID\n")
cat(rep("=", 72), "\n", sep = "")
cat(sprintf("Scenarios: %d | Reps per scenario: %d | N units: %d | Workers: %d\n",
            nrow(scenarios_tbl), cfg$n_reps, cfg$n_units, cfg$workers))
cat("Specifications: base, tvc, safe, full\n\n")

print(
  scenarios_tbl |>
    select(
      scenario, att_true,
      target_base_minus_safe, target_full_minus_safe, target_tvc_minus_base
    )
)

plan(multisession, workers = cfg$workers)
t0 <- proc.time()[3]

raw_results <- bind_rows(future_lapply(scenarios, function(pars) {
  bind_rows(lapply(seq_len(cfg$n_reps), run_rep, pars = pars, n_units = cfg$n_units))
}, future.seed = TRUE))

elapsed <- proc.time()[3] - t0
plan(sequential)

out <- summarize_results(raw_results, scenarios_tbl)
save_outputs(
  raw_results = raw_results,
  summary_specs = out$summary_specs,
  decomp = out$decomp,
  scenarios_tbl = scenarios_tbl,
  out_dir = file.path("simulations", "dynamics", cfg$out_dir)
)

cat("\n")
cat(rep("-", 72), "\n", sep = "")
cat("MEAN ESTIMATES AND BIAS\n")
cat(rep("-", 72), "\n", sep = "")
print(
  out$summary_specs |>
    mutate(
      mean_estimate = round(mean_estimate, 3),
      bias = round(bias, 3),
      rmse = round(rmse, 3),
      coverage = round(coverage, 3)
    ) |>
    select(scenario, spec, mean_estimate, bias, rmse, coverage, n_sims)
)

cat("\n")
cat(rep("-", 72), "\n", sep = "")
cat("SHIFT DECOMPOSITION\n")
cat(rep("-", 72), "\n", sep = "")
print(
  out$decomp |>
    mutate(
      across(
        c(
          mean_base, mean_tvc, mean_safe, mean_full,
          achieved_base_minus_safe, achieved_full_minus_safe, achieved_tvc_minus_base,
          target_base_minus_safe, target_full_minus_safe, target_tvc_minus_base,
          gap_base_minus_safe, gap_full_minus_safe, gap_tvc_minus_base
        ),
        ~ round(.x, 3)
      )
    )
)

cat(sprintf(
  "\nSaved outputs to simulations/dynamics/%s | total time: %.1fs\n",
  cfg$out_dir, elapsed
))
