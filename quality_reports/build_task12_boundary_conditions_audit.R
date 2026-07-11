#!/usr/bin/env Rscript

# Task 12 static audit: boundary conditions and scope of existing simulations.
#
# This script intentionally does not source or execute any simulation code.  It
# reads the Task 10 inventory and versioned CSV artifacts, then writes only
# audit products under quality_reports/.  The output is designed to distinguish
# verified existing evidence from a declared-but-missing output and a legacy
# script without persisted results.

suppressPackageStartupMessages(library(data.table))

audit_date <- "2026-07-11"
inventory_path <- "quality_reports/simulation_design_inventory.csv"
output_dir <- "quality_reports"

stop_if_missing <- function(path) {
  if (!file.exists(path)) stop("Required static input is missing: ", path, call. = FALSE)
}

stop_if_missing(inventory_path)
inv <- fread(inventory_path)

required_ids <- c(
  "dual_role_varyT_8models", "dual_role_varyT", "mechC_adl",
  "staggered_posttreat", "nl_collider", "nl_interact", "nl_carryover",
  "callaway_controls", "v4_mechD", "feedback_Y_to_D", "direct_feedback",
  "feedback_carryover", "direct_carryover", "persistent_unobserved"
)
missing_ids <- setdiff(required_ids, inv$inventory_id)
if (length(missing_ids)) {
  stop("Task 12 inventory IDs missing: ", paste(missing_ids, collapse = ", "), call. = FALSE)
}

rows <- inv[inventory_id %in% required_ids]
for (path in rows$source_script) stop_if_missing(path)

verified_paths <- unlist(strsplit(
  rows[status == "verified_existing_artifacts", result_file_paths], ";", fixed = TRUE
))
verified_paths <- verified_paths[nzchar(verified_paths)]
for (path in verified_paths) stop_if_missing(path)

range_text <- function(x, digits = 3) {
  x <- x[is.finite(x)]
  if (!length(x)) return("not available")
  sprintf("%.*f to %.*f", digits, min(x), digits, max(x))
}

rep_text <- function(x, requested = 500L) {
  x <- x[is.finite(x)]
  if (!length(x)) return(paste0("requested ", requested, "; persisted count unavailable"))
  if (min(x) == max(x) && min(x) == requested) return(paste0(requested, " per retained scenario"))
  paste0("requested ", requested, "; persisted ", min(x), "--", max(x), " per scenario")
}

read_result <- function(path) fread(path)
vary_t <- read_result("simulations/dual_role_z/results/sim_dual_role_z_varyT_8models_results.csv")
mech_c <- read_result("simulations/v4_mechanisms/results/sim_mechC_adl_results.csv")
staggered <- read_result("simulations/dynamics/results/sim_staggered_posttreat_results.csv")
nl_collider <- read_result("simulations/nonlinearity/results/sim_nl_collider_results.csv")
nl_interact <- read_result("simulations/nonlinearity/results/sim_nl_interact_results.csv")
nl_carryover <- read_result("simulations/nonlinearity/results/sim_nl_carryover_results.csv")
callaway <- read_result("simulations/dynamics/results/sim_callaway_controls_results.csv")
mech_d <- read_result("simulations/v4_mechanisms/results/sim_ivb_twfe_v4_mechD.csv")
feedback <- read_result("simulations/dynamics/results/sim_feedback_Y_to_D_results.csv")
direct_feedback <- read_result("simulations/dynamics/results/sim_direct_feedback_results.csv")
feedback_carryover <- read_result("simulations/dynamics/results/sim_feedback_carryover_results.csv")
direct_carryover <- read_result("simulations/dynamics/results/sim_direct_carryover_results.csv")
unobserved <- read_result("simulations/dynamics/results/sim_persistent_confounder_results.csv")

boundary <- data.table(
  family = c(
    "Panel length, N, and burn-in",
    "Binary and staggered absorbing treatment",
    "Nonlinear treatment and covariate response",
    "Measurement error in the observed control",
    "Lagged feedback from outcome to treatment",
    "Carryover and lag specification",
    "Contemporaneous unobserved confounding"
  ),
  evidence_status = c(
    "existing result; plus declared output missing",
    rep("existing result", 6)
  ),
  actually_varied = c(
    "In the retained eight-model grid, T = 10, 20, 30, 50, 100 and rho_Z = 0.50, 0.85.",
    "Switcher/never-treated shares, onset times, collider channels, outcome persistence, and rho_Z in binary dynamic and absorbing-staggered DGPs.",
    "Specified quadratic, cubic, logarithmic, sinusoidal, interaction, nonlinear carryover, and level-dependent-trend forms and strengths.",
    "Classical measurement-error variance in observed Z: sigma^2_me = 0, 0.5, 1, 2, with collider-channel strengths.",
    "Lagged feedback phi from Y_(t-1) to D_t and rho_Z; related direct-feedback and feedback-plus-carryover designs vary their documented grids.",
    "Linear beta_2, nonlinear carryover form/strength, and rho_Z; combined design also varies feedback phi.",
    "Current confounding strength kappa, persistence phi_U, rho_Z, and the U-to-Z channel delta_U."
  ),
  held_fixed = c(
    "The retained T grid fixes N = 100 and burn-in = 100; it is not an N or burn-in sensitivity analysis.",
    "Dynamic binary designs retain a linear homogeneous CET (beta = 1), short panel windows, and their stated lag structure; treatment is exogenous in mechC_adl.",
    "Most nonlinear designs fix N = 100, T = 30, burn-in = 100, linear CET beta = 1, and the remaining dynamic parameters; the collider grid also includes T = 10, 30.",
    "N = 200, T = 30, beta = 1, no burn-in, and a static TWFE collider DGP are fixed in the legacy v4 mechanism-D artifact.",
    "N = 100, T = 30, burn-in = 100, beta = 1, and the stated dual-role channels are fixed; feedback is lagged, not contemporaneous.",
    "N = 100, T = 30, burn-in = 100, beta = 1, and the stated dual-role channels are fixed in the direct/nonlinear designs.",
    "N = 100, T = 30, burn-in = 100, beta = 1, and the specified linear dynamic structure are fixed."
  ),
  measured = c(
    sprintf("Bias and MCSE by T for eight estimators; |bias(ADL+FE+lagged Z)| = %s.", range_text(abs(vary_t$adl_l_fe_bias))),
    sprintf("Bias/RMSE/MCSE by specification. mechC_adl has %d retained scenarios; absorbing design has %d.", nrow(mech_c), nrow(staggered)),
    sprintf("Bias, RMSE, MCSE, and discarded draws. Persisted replications: collider (%s), interaction (%s), carryover (%s); stable Callaway grid max |ADL(all) bias| = %s.", rep_text(nl_collider$n_sims), rep_text(nl_interact$n_sims), rep_text(nl_carryover$n_sims), range_text(abs(callaway[n_discarded == 0, adl_all_bias]))),
    sprintf("FWL shift, coefficient bias, RMSE, and coverage; |long-model bias| = %s.", range_text(abs(mech_d$bias_long))),
    sprintf("Bias, RMSE, MCSE, stability/discard records, and FWL quantities. Retained Y-to-D rows: %d; %s.", nrow(feedback), rep_text(feedback$n_sims)),
    sprintf("Bias, RMSE, MCSE, estimated lag coefficient, and stability/discard records. Direct carryover: %s; feedback-carryover: %s.", rep_text(direct_carryover$n_sims), rep_text(feedback_carryover$n_sims)),
    sprintf("Bias/RMSE/MCSE for observed-history specifications and an oracle observing U_t; with kappa > 0, |ADL(all) bias| = %s and oracle |bias| = %s.", range_text(abs(unobserved[kappa > 0, adl_all_bias])), range_text(abs(unobserved[kappa > 0, oracle_adl_bias])))
  ),
  not_identified = c(
    "No result identifies robustness to N or burn-in changes, arbitrary short panels, or a general finite-T correction. The separate 200-rep T script declares an output but has no versioned CSV.",
    "No result identifies effects for non-absorbing treatment paths, anticipation, treatment-effect heterogeneity, regime effects, or arbitrary adoption processes.",
    "No result identifies arbitrary nonlinear links, untested interactions, nonlinear outcome models, or general causal effects outside the named DGPs.",
    "No result identifies the latent true Z, corrects measurement error, or validates the specification-shift interpretation when measurement reliability is unknown.",
    "No result covers contemporaneous Y_t-to-D_t feedback, all feedback lags, or a causal estimator without sequential exchangeability and sufficient observed history.",
    "No result identifies cumulative/long-run effects when the lag structure is wrong, or establishes that a single-lag ADL is adequate in other DGPs.",
    "No observed-history specification identifies the CET with an omitted current common cause; the oracle is a DGP benchmark, not an empirical remedy."
  ),
  source_script = c(
    "simulations/dual_role_z/sim_dual_role_z_varyT_8models.R; simulations/dual_role_z/sim_dual_role_z_varyT.R (missing output)",
    "simulations/v4_mechanisms/sim_mechC_adl.R; simulations/dynamics/sim_staggered_posttreat.R",
    "simulations/nonlinearity/sim_nl_collider.R; sim_nl_interact.R; sim_nl_carryover.R; simulations/dynamics/sim_callaway_controls.R",
    "simulations/v4_mechanisms/sim_ivb_twfe_v4.R (mechanism D)",
    "simulations/dynamics/sim_feedback_Y_to_D.R; sim_direct_feedback.R; sim_feedback_carryover.R",
    "simulations/dynamics/sim_direct_carryover.R; sim_feedback_carryover.R; simulations/nonlinearity/sim_nl_carryover.R",
    "simulations/dynamics/sim_persistent_confounder.R"
  ),
  result_artifact = c(
    "simulations/dual_role_z/results/sim_dual_role_z_varyT_8models_results.csv; sim_dual_role_z_varyT_results.csv is absent",
    "simulations/v4_mechanisms/results/sim_mechC_adl_results.csv; simulations/dynamics/results/sim_staggered_posttreat_results.csv",
    "simulations/nonlinearity/results/sim_nl_*_results.csv; simulations/dynamics/results/sim_callaway_controls_results.csv",
    "simulations/v4_mechanisms/results/sim_ivb_twfe_v4_mechD.csv",
    "simulations/dynamics/results/sim_feedback_Y_to_D_results.csv; sim_direct_feedback_results.csv; sim_feedback_carryover_results.csv",
    "simulations/dynamics/results/sim_direct_carryover_results.csv; sim_feedback_carryover_results.csv; simulations/nonlinearity/results/sim_nl_carryover_results.csv",
    "simulations/dynamics/results/sim_persistent_confounder_results.csv"
  ),
  replication_count = c(
    rep_text(vary_t$n_sims),
    "500 per retained scenario in each cited dynamic result CSV",
    paste("collider", rep_text(nl_collider$n_sims), "; interaction", rep_text(nl_interact$n_sims), "; carryover", rep_text(nl_carryover$n_sims)),
    "500 per scenario (legacy v4 CSV)",
    paste("Y-to-D", rep_text(feedback$n_sims), "; direct-feedback", rep_text(direct_feedback$n_sims), "; feedback-carryover", rep_text(feedback_carryover$n_sims)),
    paste("direct", rep_text(direct_carryover$n_sims), "; nonlinear", rep_text(nl_carryover$n_sims), "; feedback-carryover", rep_text(feedback_carryover$n_sims)),
    rep_text(unobserved$n_sims)
  ),
  interpretation_boundary = c(
    "Figure 2's T = 30 result is conditional on its fixed N, burn-in, DGP, and estimator set; it is not evidence that dynamic FE is generally free of finite-T bias.",
    "These are design-specific CET comparisons under stated adoption clocks; they do not validate a general DID, event-study, or treatment-regime estimator.",
    "The results test only named stable functional forms and a linear CET target; they bound neither unknown nonlinearities nor link-function misspecification generally.",
    "Measurement error changes the observed projection and attenuation pattern; it does not turn the observed shift into a causal estimate or supply reliability correction.",
    "Lagged feedback can be studied only within the stated stable grid; the conditional baseline still requires a defended causal clock, history, and exchangeability.",
    "Correctly representing the relevant history is a scope condition. If the target is cumulative or the lag order is wrong, the reported coefficient can answer a different question.",
    "The observed-history ADL baseline does not solve contemporaneous unobserved confounding; an additional design, measurement, or assumption is required."
  )
)

boundary[, inventory_ids := c(
  "dual_role_varyT_8models; dual_role_varyT (declared output missing)",
  "mechC_adl; staggered_posttreat",
  "nl_collider; nl_interact; nl_carryover; callaway_controls",
  "v4_mechD",
  "feedback_Y_to_D; direct_feedback; feedback_carryover",
  "direct_carryover; feedback_carryover; nl_carryover",
  "persistent_unobserved"
)]

compact <- boundary[, .(
  `Boundary examined in existing DGPs` = family,
  `Existing evidence` = c(
    "T varies from 10 to 100 with N and burn-in fixed; the separately declared 200-rep T output is absent.",
    "Binary staggered and absorbing-treatment designs vary adoption composition and timing (500 retained replications per scenario).",
    "Named nonlinear collider, interaction, carryover, and trend designs report bias/RMSE only for their retained stable scenarios.",
    "A legacy static TWFE design varies measurement-error variance in Z (500 replications per scenario).",
    "Lagged-feedback and feedback-plus-carryover designs report bias and stability within their stated grids.",
    "Linear and nonlinear lag structures are varied; omitted or misspecified history can change the estimand.",
    "When a current common cause is unobserved, observed-history ADL retains material bias; the oracle observes that cause."
  ),
  `Interpretation boundary` = interpretation_boundary
)]

reconciliation <- data.table(
  manuscript_or_inventory_claim = c(
    "Figure 2 reports N = 100, T = 30, burn-in = 100, and 500 replications.",
    "The manuscript reports stable-scenario nonlinearity evidence and separately reports remaining bias under contemporaneous unobserved confounding.",
    "The manuscript must not use sim_dual_role_z_varyT.R to support a numerical finite-T claim.",
    "Measurement-error and binary/staggered artifacts are existing evidence but do not currently support a general estimator claim in the manuscript.",
    "Legacy sim_ivb_completa.R remains outside numerical manuscript support."
  ),
  inventory_audit = c(
    "Consistent: Task 11 validation records 500 raw/published replications for the Figure 2 source, and Task 10 verifies its source/results artifacts.",
    "Consistent: Task 10 classifies Callaway and persistent-unobserved artifacts as verified existing results; the manuscript conditions the nonlinear statement on stable scenarios and says the baseline does not address unobserved current confounding.",
    "Confirmed discrepancy/gap: Task 10 classifies dual_role_varyT as declared_output_missing. Its script states 200 reps, but no matching versioned result exists.",
    "Clarification added: the compact table labels these as design-specific existing artifacts, not evidence of general robustness or identification beyond their DGPs.",
    "Confirmed: Task 10 classifies v1_legacy_completa as legacy_no_persisted_result; it is not cited as numerical evidence."
  ),
  disposition = c("no correction required", "no correction required", "exclude from numerical claims", "scope language added", "exclude from numerical claims")
)

validation <- data.table(
  check = c(
    "required Task 12 inventory rows present",
    "source scripts exist",
    "declared result artifacts for verified rows exist",
    "dual_role_varyT is explicitly classified as missing output",
    "v1_legacy_completa is explicitly classified as legacy without persisted result",
    "no simulation code sourced or executed by this script"
  ),
  value = c(
    length(required_ids), length(rows$source_script), length(verified_paths),
    inv[inventory_id == "dual_role_varyT", status],
    inv[inventory_id == "v1_legacy_completa", status],
    "static reads only"
  ),
  pass = c(
    length(missing_ids) == 0,
    TRUE,
    TRUE,
    identical(inv[inventory_id == "dual_role_varyT", status], "declared_output_missing"),
    identical(inv[inventory_id == "v1_legacy_completa", status], "legacy_no_persisted_result"),
    TRUE
  )
)

fwrite(boundary, file.path(output_dir, "task12_boundary_conditions.csv"))
fwrite(compact, file.path(output_dir, "task12_boundary_conditions_compact.csv"))
fwrite(reconciliation, file.path(output_dir, "task12_reconciliation.csv"))
fwrite(validation, file.path(output_dir, "task12_static_validation.csv"))

if (!all(validation$pass)) stop("Task 12 static validation failed.", call. = FALSE)
message("Task 12 static audit artifacts written to ", output_dir)
