# ============================================================================
# check_stationarity_extended.R
# Verify stationarity for extended DGPs with:
#   - Direct feedback: φ Y_{t-1} → D_t  (Imai & Kim assumption (c))
#   - Direct carryover: β₂ D_{t-1} → Y_t  (Imai & Kim assumption (d))
#
# Extended DGP:
#   D_t = α_D + γ_D Z_{t-1} + ρ_D D_{t-1} + φ Y_{t-1} + u_t
#   Y_t = α_Y + β D_t + β₂ D_{t-1} + γ_Y Z_{t-1} + ρ_Y Y_{t-1} + e_t
#   Z_t = α_Z + δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + ν_t
#
# State vector: X_t = (D_t, Y_t, Z_t)'
# ============================================================================

check_var_stationarity_ext <- function(beta, rho_Y, rho_D, gamma_D, gamma_Y,
                                        delta_D, delta_Y, rho_Z,
                                        phi = 0, beta2 = 0) {
  # Reduced form derivation:
  #
  # D_t = ρ_D D_{t-1} + φ Y_{t-1} + γ_D Z_{t-1} + (exogenous)
  #
  # Y_t = β D_t + β₂ D_{t-1} + ρ_Y Y_{t-1} + γ_Y Z_{t-1} + (exogenous)
  #      = β(ρ_D D_{t-1} + φ Y_{t-1} + γ_D Z_{t-1} + u_t)
  #        + β₂ D_{t-1} + ρ_Y Y_{t-1} + γ_Y Z_{t-1} + e_t
  #      = (β ρ_D + β₂) D_{t-1} + (β φ + ρ_Y) Y_{t-1}
  #        + (β γ_D + γ_Y) Z_{t-1} + ...
  #
  # Z_t = δ_D D_t + δ_Y Y_t + ρ_Z Z_{t-1} + (exogenous)
  #      = δ_D(ρ_D D_{t-1} + φ Y_{t-1} + γ_D Z_{t-1} + u_t)
  #        + δ_Y((β ρ_D + β₂) D_{t-1} + (β φ + ρ_Y) Y_{t-1}
  #              + (β γ_D + γ_Y) Z_{t-1} + β u_t + e_t)
  #        + ρ_Z Z_{t-1} + ν_t
  #      = (δ_D ρ_D + δ_Y(β ρ_D + β₂)) D_{t-1}
  #        + (δ_D φ + δ_Y(β φ + ρ_Y)) Y_{t-1}
  #        + (δ_D γ_D + δ_Y(β γ_D + γ_Y) + ρ_Z) Z_{t-1} + ...

  A <- matrix(0, 3, 3)

  # Row 1: D_t equation
  A[1, 1] <- rho_D                            # D_{t-1}
  A[1, 2] <- phi                              # Y_{t-1}
  A[1, 3] <- gamma_D                          # Z_{t-1}

  # Row 2: Y_t (reduced form)
  A[2, 1] <- beta * rho_D + beta2             # D_{t-1}
  A[2, 2] <- beta * phi + rho_Y               # Y_{t-1}
  A[2, 3] <- beta * gamma_D + gamma_Y         # Z_{t-1}

  # Row 3: Z_t (reduced form)
  A[3, 1] <- delta_D * rho_D + delta_Y * (beta * rho_D + beta2)    # D_{t-1}
  A[3, 2] <- delta_D * phi + delta_Y * (beta * phi + rho_Y)        # Y_{t-1}
  A[3, 3] <- delta_D * gamma_D + delta_Y * (beta * gamma_D + gamma_Y) + rho_Z  # Z_{t-1}

  eigs <- eigen(A, only.values = TRUE)$values
  max_mod <- max(Mod(eigs))

  list(A = A, eigenvalues = eigs, max_modulus = max_mod,
       stationary = max_mod < 1)
}

# ---- Fixed parameters (same as dual-role Z simulations) ----
beta <- 1; rho_Y <- 0.5; rho_D <- 0.5
gamma_D <- 0.15; gamma_Y <- 0.2
delta_D <- 0.1; delta_Y <- 0.1

cat(rep("=", 71), "\n", sep = "")
cat("STATIONARITY CHECK FOR EXTENDED DGPs (Imai & Kim violations)\n")
cat(rep("=", 71), "\n\n")
cat("Fixed: beta=1, rho_Y=0.5, rho_D=0.5, gamma_D=0.15, gamma_Y=0.2\n")
cat("       delta_D=0.1, delta_Y=0.1\n\n")

# ========================================================================
# 1. Sim 1 — Direct Feedback: φ Y_{t-1} → D_t
# ========================================================================
cat(rep("-", 60), "\n", sep = "")
cat("SIM 1: Direct Feedback (φ Y_{t-1} → D_t)\n")
cat(rep("-", 60), "\n\n")

phi_vals <- c(0, 0.05, 0.1, 0.2)
rho_Z_vals <- c(0.5, 0.85)

for (rz in rho_Z_vals) {
  for (ph in phi_vals) {
    res <- check_var_stationarity_ext(beta, rho_Y, rho_D, gamma_D, gamma_Y,
                                       delta_D, delta_Y, rz,
                                       phi = ph, beta2 = 0)
    cat(sprintf("ρ_Z=%.2f, φ=%.2f: |λ_max|=%.4f  %s  eigenvalues: %s\n",
                rz, ph, res$max_modulus,
                ifelse(res$stationary, "OK", "*** UNSTABLE ***"),
                paste(sprintf("%.4f", Mod(res$eigenvalues)), collapse = ", ")))
  }
  cat("\n")
}

# ========================================================================
# 2. Sim 2 — Direct Carryover: β₂ D_{t-1} → Y_t
# ========================================================================
cat(rep("-", 60), "\n", sep = "")
cat("SIM 2: Direct Carryover (β₂ D_{t-1} → Y_t)\n")
cat(rep("-", 60), "\n\n")

beta2_vals <- c(0, 0.2, 0.5)

for (rz in rho_Z_vals) {
  for (b2 in beta2_vals) {
    res <- check_var_stationarity_ext(beta, rho_Y, rho_D, gamma_D, gamma_Y,
                                       delta_D, delta_Y, rz,
                                       phi = 0, beta2 = b2)
    cat(sprintf("ρ_Z=%.2f, β₂=%.2f: |λ_max|=%.4f  %s  eigenvalues: %s\n",
                rz, b2, res$max_modulus,
                ifelse(res$stationary, "OK", "*** UNSTABLE ***"),
                paste(sprintf("%.4f", Mod(res$eigenvalues)), collapse = ", ")))
  }
  cat("\n")
}

# ========================================================================
# 3. Sim 3 — Combined: φ + β₂
# ========================================================================
cat(rep("-", 60), "\n", sep = "")
cat("SIM 3: Combined (φ Y_{t-1} → D_t + β₂ D_{t-1} → Y_t)\n")
cat(rep("-", 60), "\n\n")

combo_grid <- list(
  list(phi = 0.1, beta2 = 0.3),
  list(phi = 0.2, beta2 = 0.5)
)

for (rz in rho_Z_vals) {
  for (cc in combo_grid) {
    res <- check_var_stationarity_ext(beta, rho_Y, rho_D, gamma_D, gamma_Y,
                                       delta_D, delta_Y, rz,
                                       phi = cc$phi, beta2 = cc$beta2)
    cat(sprintf("ρ_Z=%.2f, φ=%.2f, β₂=%.2f: |λ_max|=%.4f  %s  eigenvalues: %s\n",
                rz, cc$phi, cc$beta2, res$max_modulus,
                ifelse(res$stationary, "OK", "*** UNSTABLE ***"),
                paste(sprintf("%.4f", Mod(res$eigenvalues)), collapse = ", ")))
  }
  cat("\n")
}

# ========================================================================
# 4. Sanity: reproduce original check_stationarity.R baseline
# ========================================================================
cat(rep("-", 60), "\n", sep = "")
cat("SANITY: Baseline (φ=0, β₂=0) matches original check_stationarity.R\n")
cat(rep("-", 60), "\n\n")

for (rz in c(0.1, 0.3, 0.5, 0.7, 0.9)) {
  res <- check_var_stationarity_ext(beta, rho_Y, rho_D, gamma_D, gamma_Y,
                                     delta_D, delta_Y, rz,
                                     phi = 0, beta2 = 0)
  cat(sprintf("ρ_Z=%.1f: |λ_max|=%.4f  %s\n",
              rz, res$max_modulus,
              ifelse(res$stationary, "OK", "*** UNSTABLE ***")))
}

cat("\nDone.\n")
