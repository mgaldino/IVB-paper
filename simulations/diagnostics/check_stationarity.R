# ============================================================================
# check_stationarity.R
# Verify stationarity of the VAR system for all parameter combinations
#
# The DGP is:
#   D_t = α_D + γ_D Z_{t-1} + ρ_D D_{t-1} + u_t
#   Y_t = α_Y + β D_t + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + e_t
#   Z_t = α_Z + δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ν_t
#
# Substituting Y_t into Z_t to get reduced form:
#   Z_t = α_Z + δ_D D_t + δ_Y(α_Y + β D_t + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + e_t) + ρ_Z Z_{t-1} + ν_t
#   Z_t = ... + (δ_D + δ_Y β) D_t + (ρ_Z + δ_Y γ_Y) Z_{t-1} + δ_Y ρ_Y Y_{t-1} + ...
#
# State vector: X_t = (D_t, Y_t, Z_t)'
# Reduced form VAR(1): X_t = c + A X_{t-1} + innovations
#
# We need |eigenvalues(A)| < 1 for stationarity
# ============================================================================

check_var_stationarity <- function(beta, rho_Y, rho_D, gamma_D, gamma_Y,
                                    delta_D, delta_Y, rho_Z) {
  # Reduced form: substitute contemporaneous D_t into Y_t, then both into Z_t
  #
  # D_t = ρ_D D_{t-1} + γ_D Z_{t-1} + (exogenous)
  #
  # Y_t = β D_t + ρ_Y Y_{t-1} + γ_Y Z_{t-1} + (exogenous)
  #      = β(ρ_D D_{t-1} + γ_D Z_{t-1} + u_t) + ρ_Y Y_{t-1} + γ_Y Z_{t-1} + e_t
  #      = β ρ_D D_{t-1} + ρ_Y Y_{t-1} + (β γ_D + γ_Y) Z_{t-1} + ...
  #
  # Z_t = δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + (exogenous)
  #      = δ_D(ρ_D D_{t-1} + γ_D Z_{t-1} + u_t)
  #        + δ_Y(β ρ_D D_{t-1} + ρ_Y Y_{t-1} + (β γ_D + γ_Y) Z_{t-1} + β u_t + e_t)
  #        + ρ_Z Z_{t-1} + ν_t
  #      = (δ_D ρ_D + δ_Y β ρ_D) D_{t-1}
  #        + δ_Y ρ_Y Y_{t-1}
  #        + (δ_D γ_D + δ_Y(β γ_D + γ_Y) + ρ_Z) Z_{t-1} + ...

  # Companion matrix A where X_t = A X_{t-1} + ...
  # Rows: D_t, Y_t, Z_t
  # Cols: D_{t-1}, Y_{t-1}, Z_{t-1}

  A <- matrix(0, 3, 3)

  # Row 1: D_t equation
  A[1, 1] <- rho_D                        # D_{t-1}
  A[1, 2] <- 0                            # Y_{t-1}
  A[1, 3] <- gamma_D                      # Z_{t-1}

  # Row 2: Y_t (reduced form)
  A[2, 1] <- beta * rho_D                 # D_{t-1}
  A[2, 2] <- rho_Y                        # Y_{t-1}
  A[2, 3] <- beta * gamma_D + gamma_Y     # Z_{t-1}

  # Row 3: Z_t (reduced form)
  A[3, 1] <- (delta_D + delta_Y * beta) * rho_D           # D_{t-1}
  A[3, 2] <- delta_Y * rho_Y                               # Y_{t-1}
  A[3, 3] <- delta_D * gamma_D + delta_Y * (beta * gamma_D + gamma_Y) + rho_Z  # Z_{t-1}

  eigs <- eigen(A, only.values = TRUE)$values
  max_mod <- max(Mod(eigs))

  list(A = A, eigenvalues = eigs, max_modulus = max_mod,
       stationary = max_mod < 1)
}

# ---- Check all scenarios from sim_dual_role_z.R ----
cat("=" , rep("=", 70), "\n", sep = "")
cat("STATIONARITY CHECK FOR DUAL-ROLE Z SIMULATION\n")
cat(rep("=", 71), "\n\n", sep = "")

# Fixed parameters
beta <- 1; rho_Y <- 0.5; rho_D <- 0.5
gamma_D <- 0.15; gamma_Y <- 0.2
delta_D <- 0.1; delta_Y <- 0.1

rho_Z_vals <- c(0.1, 0.3, 0.5, 0.7, 0.9)

cat("Fixed: β=1, ρ_Y=0.5, ρ_D=0.5, γ_D=0.15, γ_Y=0.2, δ_D=0.1, δ_Y=0.1\n\n")

results <- data.frame(rho_Z = numeric(), max_eigenvalue = numeric(),
                       stationary = logical(), effective_Z_persistence = numeric())

for (rz in rho_Z_vals) {
  res <- check_var_stationarity(beta, rho_Y, rho_D, gamma_D, gamma_Y,
                                 delta_D, delta_Y, rz)
  # Effective Z persistence = A[3,3]
  eff_z <- res$A[3, 3]
  results <- rbind(results, data.frame(
    rho_Z = rz, max_eigenvalue = round(res$max_modulus, 4),
    stationary = res$stationary, effective_Z_persistence = round(eff_z, 4)
  ))
  cat(sprintf("ρ_Z = %.1f: |λ_max| = %.4f  effective_Z_persist = %.4f  %s\n",
              rz, res$max_modulus, eff_z,
              ifelse(res$stationary, "OK", "*** UNSTABLE ***")))
  cat(sprintf("  eigenvalues: %s\n",
              paste(sprintf("%.4f", Mod(res$eigenvalues)), collapse = ", ")))
}

cat("\n")

# ---- Also check the firewall scenario (ρ_Y = 0) ----
cat("--- Firewall scenario: ρ_Y = 0 ---\n")
for (rz in c(0.3, 0.7, 0.9)) {
  res <- check_var_stationarity(beta, 0, rho_D, gamma_D, gamma_Y,
                                 delta_D, delta_Y, rz)
  cat(sprintf("ρ_Z = %.1f, ρ_Y = 0: |λ_max| = %.4f  %s\n",
              rz, res$max_modulus,
              ifelse(res$stationary, "OK", "*** UNSTABLE ***")))
}

cat("\n")

# ---- Check asymmetry scenarios ----
cat("--- Asymmetry scenarios: varying γ_D and δ_D (ρ_Z = 0.7) ---\n")
for (gd in c(0.05, 0.15, 0.3, 0.5)) {
  for (dd in c(0.05, 0.1, 0.2)) {
    res <- check_var_stationarity(beta, rho_Y, rho_D, gd, gamma_Y,
                                   dd, delta_Y, 0.7)
    cat(sprintf("γ_D=%.2f, δ_D=%.2f: |λ_max| = %.4f  %s\n",
                gd, dd, res$max_modulus,
                ifelse(res$stationary, "OK", "*** UNSTABLE ***")))
  }
}

cat("\nDone.\n")
