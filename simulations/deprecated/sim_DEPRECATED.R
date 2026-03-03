# =============================================================================
# DEPRECATED: This file is an abandoned exploratory draft and should NOT be used.
# It contains bugs (undefined variable on line 44) and incomplete code.
# The authoritative simulation file is: sim_ivb_completa.R
# =============================================================================

# Set seed for reproducibility
set.seed(123)

# Sample size
n <- 10000

# Parameters
beta0 <- 0
beta1 <- 1
gamma0 <- 0
gamma1 <- 0.6
gamma2 <- 0.4

# Generate exogenous variable D
D <- rnorm(n, mean = 0, sd = 1)

# Generate error terms
e1 <- rnorm(n, mean = 0, sd = 1)
e2 <- rnorm(n, mean = 0, sd = 1)

# Generate Y based on the true model
Y <- beta0 + beta1 * D + e1

# Generate Z as a collider influenced by D and Y
Z <- gamma0 + gamma1 * D + gamma2 * Y + e2

# Short regression: Regress Y on D (true model)
model_short <- lm(Y ~ D)
summary(model_short)
# Long regression: Regress Y on D and Z (including collider Z)
model_long <- lm(Y ~ D + Z)
summary(model_long)

# Regress Z on D to estimate phi1
model_ZD <- lm(Z ~ D)

# Calculate covariance between D and Z
cov_DZ_IVB <- cov(D, Z)

hat_bias_IVB <- -coef(model_long)[3]*cov_DZ_IVB
coef(summary(model_short))[2] + bias_IVB


# Sim 2
# Set seed for reproducibility
set.seed(123)

# Sample size
n <- 10000

# Parameters
beta0 <- 0
beta1 <- 1
beta2 <- 0.4  # Corresponds to gamma2 in the IVB scenario
alpha0 <- 0
alpha1 <- 1   # Ensures Cov(D, Z) is the same as in IVB

# Generate exogenous variable Z
Z <- rnorm(n, mean = 0, sd = 1)

# Generate error terms
e3 <- rnorm(n, mean = 0, sd = 1)
e1 <- rnorm(n, mean = 0, sd = 1)

# Generate D influenced by Z
D <- alpha0 + alpha1 * Z + e3

# Generate Y based on the true model including Z
Y <- beta0 + beta1 * D + beta2 * Z + e1

# Short regression: Regress Y on D (omitting Z)
model_short_OVB <- lm(Y ~ D)
summary(model_short_OVB)

# Long regression: Regress Y on D and Z (correct model)
model_long_OVB <- lm(Y ~ D + Z)
summary(model_long_OVB)
# Regress D on Z to estimate alpha1
model_DZ <- lm(D ~ Z)

# Calculate covariance between D and Z
cov_DZ_OVB <- cov(D, Z)

# Output results


