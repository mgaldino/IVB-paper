#!/usr/bin/env Rscript

# Gate 1, teste de contribuicao v2: verificacao numerica deterministica.
#
# Este script implementa fixtures de algebra. Ele nao usa dados reais, nao
# amostra uma populacao gaussiana e nao executa simulacao, bootstrap ou
# inferencia de cobertura. Execute somente depois da revisao review-r
# independente e da liberacao do coordenador exigidas por CLAUDE.md.

options(stringsAsFactors = FALSE, warn = 1)

script_rel_dir <- file.path(
  "quality_reports", "execution", "2026-09-15_refine_contribution",
  "gate_01", "numerical"
)
prespec_rel_dir <- file.path(
  "quality_reports", "execution", "2026-09-15_refine_contribution",
  "gate_01", "contribution"
)
expected_source_hashes <- c(
  "test_prespec_v2.md" =
    "37562fccf615793d0b589b58303e0afeb225edd73ea85e44a7bb1b7688be7097",
  "test_prespec_v2.json" =
    "12affe0250af02ada1fc4213a1067ccfe5b482fa5d7a78c52261069c7e7ff00f"
)

scalar_tolerance <- function(target) {
  1e-10 * (1 + abs(target))
}

matrix_tolerance <- function(target) {
  1e-10 * (1 + max(abs(target)))
}

sha256_file <- function(path) {
  output <- system2(
    "shasum",
    c("-a", "256", shQuote(path)),
    stdout = TRUE,
    stderr = TRUE,
    env = c("LC_ALL=C", "LANG=C")
  )
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) {
    stop(
      "shasum terminou com status ", status, " para: ", path,
      ". Saida: ", paste(output, collapse = " | "),
      call. = FALSE
    )
  }
  if (length(output) != 1L) {
    stop("Nao foi possivel calcular SHA-256 de: ", path, call. = FALSE)
  }
  fields <- strsplit(trimws(output), "[[:space:]]+")[[1L]]
  hash_fields <- fields[grepl("^[0-9A-Fa-f]{64}$", fields)]
  if (length(fields) < 2L || length(hash_fields) != 1L ||
      !identical(fields[[1L]], hash_fields[[1L]])) {
    stop(
      "Saida de shasum sem um hash SHA-256 valido para: ", path,
      ". Saida: ", output,
      call. = FALSE
    )
  }
  tolower(fields[[1L]])
}

repo_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
required_from_root <- c(
  "CLAUDE.md",
  file.path(prespec_rel_dir, names(expected_source_hashes))
)
if (!all(file.exists(file.path(repo_root, required_from_root)))) {
  stop(
    "Execute este script a partir da raiz do repositorio IVB-paper.",
    call. = FALSE
  )
}

for (source_name in names(expected_source_hashes)) {
  source_path <- file.path(repo_root, prespec_rel_dir, source_name)
  observed_hash <- sha256_file(source_path)
  if (!identical(observed_hash, expected_source_hashes[[source_name]])) {
    stop(
      "Fonte governante divergiu do freeze v2: ", source_name,
      ". Esperado ", expected_source_hashes[[source_name]],
      "; observado ", observed_hash, ".",
      call. = FALSE
    )
  }
}

main <- function() {
args <- commandArgs(trailingOnly = TRUE)
allowed_args <- "--allow-rerun-local"
unknown_args <- setdiff(args, allowed_args)
if (length(unknown_args) > 0L) {
  stop("Argumento desconhecido: ", paste(unknown_args, collapse = ", "),
       call. = FALSE)
}
if (anyDuplicated(args)) {
  stop("Cada argumento pode ser fornecido apenas uma vez.", call. = FALSE)
}

results_root <- file.path(repo_root, script_rel_dir, "results")
if (file.exists(results_root) && !dir.exists(results_root)) {
  stop("O caminho results/ existe e nao e um diretorio.", call. = FALSE)
}

if (identical(args, character(0L))) {
  run_name <- "primary"
} else {
  timestamp <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
  run_name <- paste0("rerun_", timestamp, "_pid", Sys.getpid())
}
run_dir <- file.path(results_root, run_name)
if (file.exists(run_dir)) {
  stop(
    "Recusa de overwrite: o diretorio de resultados ja existe: ", run_dir,
    call. = FALSE
  )
}
created <- dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
if (!isTRUE(created) || !dir.exists(run_dir)) {
  stop("Nao foi possivel criar o diretorio de resultados.", call. = FALSE)
}

run_log <- character(0L)
log_message <- function(message) {
  stamp <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  line <- paste0(stamp, " ", message)
  run_log <<- c(run_log, line)
  message(line)
}

write_text_safe <- function(lines, filename) {
  path <- file.path(run_dir, filename)
  if (file.exists(path)) {
    stop("Recusa de overwrite durante a gravacao: ", path, call. = FALSE)
  }
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
}

write_csv_safe <- function(object, filename) {
  path <- file.path(run_dir, filename)
  if (file.exists(path)) {
    stop("Recusa de overwrite durante a gravacao: ", path, call. = FALSE)
  }
  write.csv(object, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}

run_complete <- FALSE
on.exit({
  if (!file.exists(file.path(run_dir, "run_log.txt"))) {
    writeLines(enc2utf8(c(run_log, "verification_status=NOT_COMPLETED")),
               file.path(run_dir, "run_log.txt"), useBytes = TRUE)
  }
  if (!file.exists(file.path(run_dir, "sessionInfo.txt"))) {
    writeLines(capture.output(sessionInfo()),
               file.path(run_dir, "sessionInfo.txt"), useBytes = TRUE)
  }
  if (!run_complete &&
      !file.exists(file.path(run_dir, "final_status.txt"))) {
    try(
      writeLines(
        c(
          "status=FAILED",
          "reason=execution_ended_before_authoritative_success_marker"
        ),
        file.path(run_dir, "final_status.txt"),
        useBytes = TRUE
      ),
      silent = TRUE
    )
  }
}, add = TRUE)

log_message(paste0("inicio run=", run_name))
log_message("fontes governantes conferidas contra freeze_prespec_v2.json")
log_message("escopo=fixture_algebrico_deterministico_sem_inferencia")

sign_label <- function(value, tolerance) {
  if (abs(value) <= tolerance) {
    "zero"
  } else if (value > 0) {
    "positivo"
  } else {
    "negativo"
  }
}

ols_fit <- function(data, response, predictors, model_id) {
  x <- cbind(intercept = 1, as.matrix(data[predictors]))
  storage.mode(x) <- "double"
  y <- as.numeric(data[[response]])
  rank_x <- qr(x)$rank
  if (rank_x != ncol(x)) {
    stop("Modelo sem posto completo: ", model_id, call. = FALSE)
  }
  gram <- crossprod(x)
  coefficients <- solve(gram, crossprod(x, y))
  coefficients <- setNames(as.numeric(coefficients), colnames(x))
  fitted <- as.numeric(x %*% coefficients)
  residual <- y - fitted
  list(
    id = model_id,
    row_id = as.character(data$row_id),
    x = x,
    y = y,
    coef = coefficients,
    fitted = fitted,
    residual = residual,
    rank = rank_x,
    columns = ncol(x),
    kappa_design = kappa(x, exact = TRUE),
    kappa_gram = kappa(gram, exact = TRUE)
  )
}

fit_diagnostic <- function(example, cell, procedure, fit) {
  data.frame(
    example = example,
    cell = cell,
    procedure = procedure,
    model = fit$id,
    n = length(fit$y),
    columns = fit$columns,
    rank = fit$rank,
    full_rank = fit$rank == fit$columns,
    kappa_design = fit$kappa_design,
    kappa_gram = fit$kappa_gram,
    max_abs_normal_equation = max(abs(crossprod(fit$x, fit$residual))),
    row_id_signature = paste(fit$row_id, collapse = "|"),
    stringsAsFactors = FALSE
  )
}

stacked_ols_sandwich <- function(fits) {
  n_values <- vapply(fits, function(x) length(x$y), integer(1L))
  if (length(unique(n_values)) != 1L) {
    stop("Equacoes empilhadas com numeros de linhas diferentes.", call. = FALSE)
  }
  row_signatures <- vapply(
    fits, function(x) paste(x$row_id, collapse = "|"), character(1L)
  )
  if (length(unique(row_signatures)) != 1L) {
    stop("Equacoes empilhadas com identificadores de linha diferentes.",
         call. = FALSE)
  }
  p_each <- vapply(fits, function(x) length(x$coef), integer(1L))
  total_p <- sum(p_each)
  n <- unique(n_values)
  score <- matrix(0, nrow = n, ncol = total_p)
  bread_inverse <- matrix(0, nrow = total_p, ncol = total_p)
  parameter_names <- character(total_p)
  cursor <- 1L
  for (fit_name in names(fits)) {
    fit <- fits[[fit_name]]
    index <- cursor:(cursor + length(fit$coef) - 1L)
    score[, index] <- sweep(fit$x, 1L, fit$residual, `*`)
    bread_inverse[index, index] <- solve(crossprod(fit$x))
    parameter_names[index] <- paste0(fit_name, "::", names(fit$coef))
    cursor <- max(index) + 1L
  }
  colnames(score) <- parameter_names
  rownames(bread_inverse) <- parameter_names
  colnames(bread_inverse) <- parameter_names
  coefficient_if <- bread_inverse %*% t(score)
  covariance <- coefficient_if %*% t(coefficient_if)
  rownames(covariance) <- parameter_names
  colnames(covariance) <- parameter_names
  list(
    covariance = covariance,
    coefficient_if = coefficient_if,
    parameter_names = parameter_names
  )
}

zero_gradient <- function(stack) {
  setNames(numeric(length(stack$parameter_names)), stack$parameter_names)
}

set_gradient <- function(gradient, values) {
  missing_names <- setdiff(names(values), names(gradient))
  if (length(missing_names) > 0L) {
    stop("Parametro ausente no gradiente: ",
         paste(missing_names, collapse = ", "), call. = FALSE)
  }
  gradient[names(values)] <- as.numeric(values)
  gradient
}

gradient_matrix <- function(rows) {
  result <- do.call(rbind, rows)
  storage.mode(result) <- "double"
  result
}

contrast_from_gradient <- function(stack, gradient) {
  covariance <- gradient %*% stack$covariance %*% t(gradient)
  influence <- gradient %*% stack$coefficient_if
  list(covariance = covariance, influence = influence)
}

make_base_contrasts <- function() {
  x1 <- rep(0:1, each = 4L)
  x2 <- rep(rep(0:1, each = 2L), times = 2L)
  x3 <- rep(0:1, times = 4L)
  data.frame(
    row_id = sprintf("x%d%d%d", x1, x2, x3),
    x1 = x1,
    x2 = x2,
    x3 = x3,
    e_L = (-1)^x1,
    e_D = (-1)^x2,
    e_Z = (-1)^x3,
    e_Y = (-1)^(x1 + x2),
    stringsAsFactors = FALSE
  )
}

base_contrasts <- make_base_contrasts()
contrast_matrix <- as.matrix(base_contrasts[c("e_L", "e_D", "e_Z", "e_Y")])
contrast_gram <- crossprod(contrast_matrix) / nrow(contrast_matrix)

make_e1_fixture <- function(cell_id, q, b, r) {
  fixture <- base_contrasts
  fixture$example <- "E1"
  fixture$cell <- cell_id
  fixture$q <- q
  fixture$b <- b
  fixture$r <- r
  fixture$L <- fixture$e_L
  fixture$D <- fixture$L + fixture$e_D
  fixture$Z <- fixture$D + fixture$e_Z
  fixture$Y <- q * fixture$D + b * fixture$L + r * fixture$Z + fixture$e_Y
  fixture[c(
    "example", "cell", "row_id", "x1", "x2", "x3",
    "e_L", "e_D", "e_Z", "e_Y", "q", "b", "r", "L", "D", "Z", "Y"
  )]
}

e1_cells <- data.frame(
  cell = c("E1-central", "E1-menos", "E1-mais", "E1-nulo"),
  q = c(1 / 2, 1 / 2, 1 / 2, 1),
  b = c(1, 4 / 5, 6 / 5, 0),
  r = c(1 / 2, 1 / 2, 1 / 2, 0),
  stringsAsFactors = FALSE
)

# Oraculo declarativo transcrito da ficha congelada, separado da funcao que
# classifica os contrastes calculados. Os certificados causais abaixo sao
# entradas analiticas fornecidas; este script nao descobre nem seleciona DAGs.
e1_action_oracle <- data.frame(
  cell = c("E1-central", "E1-menos", "E1-mais", "E1-nulo"),
  descriptive_target = c(
    "compensacao", "compensacao", "compensacao",
    "sem_compensacao_material"
  ),
  causal_target = c(
    rep("modelos_CET_certificados=B", 3L),
    "modelos_CET_certificados=B|C|U"
  ),
  certificate_target = c(
    rep(
      "classe_defendida:B=CET_total;U=efeito_direto;C=sem_certificado_CET",
      3L
    ),
    "subclasse_sem_L_para_Y_e_Z_para_Y:B|C|U=CET_total"
  ),
  stringsAsFactors = FALSE
)

e1_causal_inputs <- data.frame(
  cell = c("E1-central", "E1-menos", "E1-mais", "E1-nulo"),
  causal_action = c(
    rep("modelos_CET_certificados=B", 3L),
    "modelos_CET_certificados=B|C|U"
  ),
  conditional_certificates = c(
    rep(
      "classe_defendida:B=CET_total;U=efeito_direto;C=sem_certificado_CET",
      3L
    ),
    "subclasse_sem_L_para_Y_e_Z_para_Y:B|C|U=CET_total"
  ),
  input_status = rep(
    "certificados_analiticos_fornecidos_e_conferidos", 4L
  ),
  stringsAsFactors = FALSE
)

e1_expected <- function(q, b, r) {
  c(
    CET_total = q + r,
    beta_B = q + r,
    beta_C = q + b / 2,
    beta_U = q,
    d_add = -r,
    d_lag = -b / 2,
    signed_removal = b / 2,
    d_total = b / 2 - r
  )
}

run_e1_p <- function(data) {
  fits <- list(
    B = ols_fit(data, "Y", c("D", "L"), "B"),
    C = ols_fit(data, "Y", c("D", "Z"), "C"),
    U = ols_fit(data, "Y", c("D", "L", "Z"), "U")
  )
  beta_b <- fits$B$coef[["D"]]
  beta_c <- fits$C$coef[["D"]]
  beta_u <- fits$U$coef[["D"]]
  quantities <- c(
    beta_B = beta_b,
    beta_C = beta_c,
    beta_U = beta_u,
    d_add = beta_u - beta_b,
    d_lag = beta_u - beta_c,
    signed_removal = beta_c - beta_u,
    d_total = beta_c - beta_b
  )
  list(fits = fits, quantities = quantities)
}

run_e1_c0 <- function(data) {
  fits <- list(
    B = ols_fit(data, "Y", c("D", "L"), "B"),
    C = ols_fit(data, "Y", c("D", "Z"), "C")
  )
  quantities <- c(
    beta_B = fits$B$coef[["D"]],
    beta_C = fits$C$coef[["D"]],
    d_total = fits$C$coef[["D"]] - fits$B$coef[["D"]]
  )
  list(fits = fits, quantities = quantities)
}

run_e1_cplus <- function(data) {
  fits <- list(
    B = ols_fit(data, "Y", c("D", "L"), "B"),
    C = ols_fit(data, "Y", c("D", "Z"), "C"),
    U = ols_fit(data, "Y", c("D", "L", "Z"), "U"),
    aux_Z = ols_fit(data, "Z", c("D", "L"), "aux_Z"),
    aux_L = ols_fit(data, "L", c("D", "Z"), "aux_L")
  )
  theta_z <- fits$U$coef[["Z"]]
  theta_l <- fits$U$coef[["L"]]
  pi_z <- fits$aux_Z$coef[["D"]]
  pi_l <- fits$aux_L$coef[["D"]]
  d_add <- -theta_z * pi_z
  d_lag <- -theta_l * pi_l
  quantities <- c(
    beta_B = fits$B$coef[["D"]],
    beta_C = fits$C$coef[["D"]],
    beta_U = fits$U$coef[["D"]],
    theta_Z_U = theta_z,
    pi_Z_given_L = pi_z,
    theta_L_U = theta_l,
    pi_L_given_Z = pi_l,
    d_add = d_add,
    d_lag = d_lag,
    signed_removal = -d_lag,
    d_total = d_add - d_lag
  )
  stack <- stacked_ols_sandwich(fits)

  p_d_add <- set_gradient(
    zero_gradient(stack), c("U::D" = 1, "B::D" = -1)
  )
  p_d_lag <- set_gradient(
    zero_gradient(stack), c("U::D" = 1, "C::D" = -1)
  )
  p_d_total <- set_gradient(
    zero_gradient(stack), c("C::D" = 1, "B::D" = -1)
  )
  gradient_p <- gradient_matrix(list(
    d_add = p_d_add, d_lag = p_d_lag, d_total = p_d_total
  ))

  cp_d_add <- set_gradient(
    zero_gradient(stack),
    c("U::Z" = -pi_z, "aux_Z::D" = -theta_z)
  )
  cp_d_lag <- set_gradient(
    zero_gradient(stack),
    c("U::L" = -pi_l, "aux_L::D" = -theta_l)
  )
  cp_d_total <- cp_d_add - cp_d_lag
  gradient_cplus <- gradient_matrix(list(
    d_add = cp_d_add, d_lag = cp_d_lag, d_total = cp_d_total
  ))

  list(
    fits = fits,
    quantities = quantities,
    stack = stack,
    gradient_p = gradient_p,
    gradient_cplus = gradient_cplus,
    covariance_p = contrast_from_gradient(stack, gradient_p),
    covariance_cplus = contrast_from_gradient(stack, gradient_cplus)
  )
}

compensation_action <- function(quantities) {
  s <- 1 / 8
  m <- 1 / 4
  is_compensation <-
    abs(quantities[["d_total"]]) <= s &&
    abs(quantities[["d_add"]]) >= m &&
    abs(quantities[["signed_removal"]]) >= m &&
    quantities[["d_add"]] * quantities[["signed_removal"]] < 0
  if (is_compensation) "compensacao" else "sem_compensacao_material"
}

descriptive_loss_from_oracle <- function(
    observed_action, target_action, scored = TRUE,
    observed_value = NA_real_, target_value = NA_real_) {
  if (!scored) return(NA_integer_)
  if (identical(observed_action, "nao_determinado") &&
      !identical(target_action, "nao_determinado")) {
    return(1L)
  }
  if (!identical(observed_action, target_action)) return(4L)
  if (!is.na(target_value)) {
    if (is.na(observed_value)) return(1L)
    if (abs(observed_value - target_value) > scalar_tolerance(target_value)) {
      return(4L)
    }
  }
  0L
}

causal_loss_from_oracle <- function(
    observed_action, observed_certificates,
    target_action, target_certificates) {
  if (identical(observed_action, target_action) &&
      identical(observed_certificates, target_certificates)) {
    0L
  } else if (identical(observed_action, "nao_determinado")) {
    1L
  } else {
    4L
  }
}

make_e2_fixtures <- function() {
  errors <- base_contrasts[c("row_id", "e_L", "e_D", "e_Z")]
  names(errors) <- c("row_id", "contrast_1", "contrast_2", "contrast_3")

  gm <- errors
  gm$example <- "E2"
  gm$graph <- "G_M"
  gm$error_1 <- gm$contrast_1
  gm$error_2 <- gm$contrast_2
  gm$error_3 <- gm$contrast_3
  gm$D <- gm$error_1
  gm$Z <- gm$D + gm$error_2
  gm$Y <- gm$D + gm$Z + gm$error_3

  gf <- errors
  gf$example <- "E2"
  gf$graph <- "G_F"
  gf$error_1 <- sqrt(2) * gf$contrast_1
  gf$error_2 <- sqrt(1 / 2) * gf$contrast_2
  gf$error_3 <- gf$contrast_3
  gf$Z <- gf$error_1
  gf$D <- gf$Z / 2 + gf$error_2
  gf$Y <- gf$D + gf$Z + gf$error_3

  keep <- c(
    "example", "graph", "row_id", "contrast_1", "contrast_2",
    "contrast_3", "error_1", "error_2", "error_3", "D", "Z", "Y"
  )
  list(G_M = gm[keep], G_F = gf[keep])
}

e2_gm_under_do_D <- function(d, e_z = 0, e_y = 0) {
  z <- d + e_z
  y <- d + z + e_y
  c(D = d, Z = z, Y = y)
}

e2_gf_under_do_D <- function(d, u_z = 0, u_y = 0) {
  # A intervencao substitui a equacao de assignment de D; Z permanece u_z.
  z <- u_z
  y <- d + z + u_y
  c(D = d, Z = z, Y = y)
}

e2_expected <- c(
  beta_S = 2,
  beta_T = 1,
  theta_Z_T = 1,
  pi_Z = 1,
  delta = -1
)

e2_action_oracle <- data.frame(
  graph = c("G_M", "G_F"),
  descriptive_target = rep("shift_descritivo", 2L),
  descriptive_value_target = rep(-1, 2L),
  causal_target = rep("somente_descritivo", 2L),
  certificate_target = rep(
    paste0(
      "G_M:S=CET_total,T=efeito_direto;",
      "G_F:T=CET_total,S=confundido"
    ),
    2L
  ),
  stringsAsFactors = FALSE
)

e2_causal_inputs <- data.frame(
  graph = c("G_M", "G_F"),
  causal_action = rep("somente_descritivo", 2L),
  conditional_certificates = rep(
    paste0(
      "G_M:S=CET_total,T=efeito_direto;",
      "G_F:T=CET_total,S=confundido"
    ),
    2L
  ),
  input_status = rep(
    "certificados_analiticos_fornecidos_e_conferidos", 2L
  ),
  stringsAsFactors = FALSE
)

run_e2_p <- function(data) {
  fits <- list(
    S = ols_fit(data, "Y", "D", "S"),
    T = ols_fit(data, "Y", c("D", "Z"), "T")
  )
  quantities <- c(
    beta_S = fits$S$coef[["D"]],
    beta_T = fits$T$coef[["D"]],
    delta = fits$T$coef[["D"]] - fits$S$coef[["D"]]
  )
  list(fits = fits, quantities = quantities)
}

run_e2_c0 <- function(data) {
  run_e2_p(data)
}

run_e2_cplus <- function(data) {
  fits <- list(
    S = ols_fit(data, "Y", "D", "S"),
    T = ols_fit(data, "Y", c("D", "Z"), "T"),
    aux_Z = ols_fit(data, "Z", "D", "aux_Z")
  )
  theta_z <- fits$T$coef[["Z"]]
  pi_z <- fits$aux_Z$coef[["D"]]
  quantities <- c(
    beta_S = fits$S$coef[["D"]],
    beta_T = fits$T$coef[["D"]],
    theta_Z_T = theta_z,
    pi_Z = pi_z,
    delta = -theta_z * pi_z
  )
  stack <- stacked_ols_sandwich(fits)
  p_delta <- set_gradient(
    zero_gradient(stack), c("T::D" = 1, "S::D" = -1)
  )
  cp_delta <- set_gradient(
    zero_gradient(stack),
    c("T::Z" = -pi_z, "aux_Z::D" = -theta_z)
  )
  gradient_p <- gradient_matrix(list(delta = p_delta))
  gradient_cplus <- gradient_matrix(list(delta = cp_delta))
  list(
    fits = fits,
    quantities = quantities,
    stack = stack,
    gradient_p = gradient_p,
    gradient_cplus = gradient_cplus,
    covariance_p = contrast_from_gradient(stack, gradient_p),
    covariance_cplus = contrast_from_gradient(stack, gradient_cplus)
  )
}

projection_rows <- list()
action_rows <- list()
sign_rows <- list()
diagnostic_rows <- list()
covariance_check_rows <- list()
covariance_matrix_rows <- list()
gradient_rows <- list()
validation_rows <- list()
input_consistency_rows <- list()

add_validation <- function(example, cell, check_id, observed, target,
                           tolerance, pass, detail) {
  validation_rows[[length(validation_rows) + 1L]] <<- data.frame(
    example = example,
    cell = cell,
    check_id = check_id,
    observed = as.character(observed),
    target = as.character(target),
    tolerance = as.character(tolerance),
    pass = isTRUE(pass),
    detail = detail,
    stringsAsFactors = FALSE
  )
}

add_projection <- function(example, cell, graph, procedure, quantity,
                           expected, computed, field_status = "reportado") {
  if (identical(field_status, "reportado")) {
    tolerance <- scalar_tolerance(expected)
    error <- abs(computed - expected)
    check_status <- if (error <= tolerance) "PASS" else "FAIL"
  } else {
    tolerance <- NA_real_
    error <- NA_real_
    check_status <- "nao_pontuado"
  }
  projection_rows[[length(projection_rows) + 1L]] <<- data.frame(
    example = example,
    cell = cell,
    graph = graph,
    procedure = procedure,
    quantity = quantity,
    expected_from_algebra = expected,
    computed_output = computed,
    abs_error = error,
    tolerance = tolerance,
    field_status = field_status,
    check_status = check_status,
    stringsAsFactors = FALSE
  )
}

add_covariance_matrix <- function(example, cell, graph, procedure, matrix_name,
                                  value) {
  for (i in seq_len(nrow(value))) {
    for (j in seq_len(ncol(value))) {
      covariance_matrix_rows[[length(covariance_matrix_rows) + 1L]] <<-
        data.frame(
          example = example,
          cell = cell,
          graph = graph,
          procedure = procedure,
          matrix = matrix_name,
          row = rownames(value)[i],
          column = colnames(value)[j],
          value = value[i, j],
          stringsAsFactors = FALSE
        )
    }
  }
}

add_gradient_rows <- function(example, cell, graph, procedure, gradient,
                              estimates) {
  nonzero <- which(abs(gradient) > 0, arr.ind = TRUE)
  if (nrow(nonzero) == 0L) return(invisible(NULL))
  for (k in seq_len(nrow(nonzero))) {
    i <- nonzero[k, 1L]
    j <- nonzero[k, 2L]
    gradient_rows[[length(gradient_rows) + 1L]] <<- data.frame(
      example = example,
      cell = cell,
      graph = graph,
      procedure = procedure,
      contrast = rownames(gradient)[i],
      parameter = colnames(gradient)[j],
      derivative = gradient[i, j],
      theta_or_pi_estimates = estimates,
      stringsAsFactors = FALSE
    )
  }
}

add_validation(
  "E1", "all", "orthogonal_fixture_contrasts",
  max(abs(contrast_gram - diag(4))), 0,
  matrix_tolerance(diag(4)),
  max(abs(contrast_gram - diag(4))) <= matrix_tolerance(diag(4)),
  "E_fixture'E_fixture/8 = I_4"
)

e1_fixture_list <- list()
for (cell_index in seq_len(nrow(e1_cells))) {
  cell <- e1_cells[cell_index, ]
  fixture <- make_e1_fixture(cell$cell, cell$q, cell$b, cell$r)
  e1_fixture_list[[cell$cell]] <- fixture
  expected <- e1_expected(cell$q, cell$b, cell$r)
  p <- run_e1_p(fixture)
  c0 <- run_e1_c0(fixture)
  cplus <- run_e1_cplus(fixture)

  for (procedure_name in c("C0", "Cplus", "P")) {
    procedure_fits <- switch(
      procedure_name, C0 = c0$fits, Cplus = cplus$fits, P = p$fits
    )
    row_signatures <- vapply(
      procedure_fits,
      function(fit) paste(fit$row_id, collapse = "|"),
      character(1L)
    )
    input_consistency_rows[[length(input_consistency_rows) + 1L]] <-
      data.frame(
        example = "E1",
        cell = cell$cell,
        procedure = procedure_name,
        same_rows = length(unique(row_signatures)) == 1L,
        common_intercept = all(vapply(
          procedure_fits,
          function(fit) all(fit$x[, "intercept"] == 1),
          logical(1L)
        )),
        common_D_values = all(vapply(
          procedure_fits,
          function(fit) {
            if (!"D" %in% colnames(fit$x)) return(TRUE)
            identical(as.numeric(fit$x[, "D"]), as.numeric(fixture$D))
          },
          logical(1L)
        )),
        transformation = "identidade",
        stringsAsFactors = FALSE
      )
  }

  for (fit in p$fits) {
    diagnostic_rows[[length(diagnostic_rows) + 1L]] <-
      fit_diagnostic("E1", cell$cell, "P", fit)
  }
  for (fit in c0$fits) {
    diagnostic_rows[[length(diagnostic_rows) + 1L]] <-
      fit_diagnostic("E1", cell$cell, "C0", fit)
  }
  for (fit in cplus$fits) {
    diagnostic_rows[[length(diagnostic_rows) + 1L]] <-
      fit_diagnostic("E1", cell$cell, "Cplus", fit)
  }

  for (quantity in names(expected)) {
    if (quantity == "CET_total") next
    p_value <- if (quantity %in% names(p$quantities)) {
      p$quantities[[quantity]]
    } else {
      NA_real_
    }
    if (!is.na(p_value)) {
      add_projection("E1", cell$cell, "known_class", "P",
                     quantity, expected[[quantity]], p_value)
    }
    cp_value <- if (quantity %in% names(cplus$quantities)) {
      cplus$quantities[[quantity]]
    } else {
      NA_real_
    }
    if (!is.na(cp_value)) {
      add_projection("E1", cell$cell, "known_class", "Cplus",
                     quantity, expected[[quantity]], cp_value)
    }
    if (quantity %in% names(c0$quantities)) {
      add_projection("E1", cell$cell, "known_class", "C0",
                     quantity, expected[[quantity]], c0$quantities[[quantity]])
    } else {
      add_projection("E1", cell$cell, "known_class", "C0",
                     quantity, expected[[quantity]], NA_real_,
                     field_status = "campo_nao_reportado")
    }
  }
  cplus_aux_expected <- c(
    theta_Z_U = cell$r,
    pi_Z_given_L = 1,
    theta_L_U = cell$b,
    pi_L_given_Z = 1 / 2
  )
  for (quantity in names(cplus_aux_expected)) {
    add_projection(
      "E1", cell$cell, "known_class", "Cplus", quantity,
      cplus_aux_expected[[quantity]], cplus$quantities[[quantity]]
    )
  }

  oracle <- e1_action_oracle[e1_action_oracle$cell == cell$cell, ]
  causal_input <- e1_causal_inputs[e1_causal_inputs$cell == cell$cell, ]
  if (nrow(oracle) != 1L || nrow(causal_input) != 1L) {
    stop("Oraculo E1 ausente ou duplicado para: ", cell$cell, call. = FALSE)
  }
  p_action <- compensation_action(p$quantities)
  cp_action <- compensation_action(cplus$quantities)
  for (procedure in c("C0", "Cplus", "P")) {
    action <- if (procedure == "C0") "campo_nao_reportado" else if (
      procedure == "Cplus"
    ) cp_action else p_action
    descriptive_scored <- procedure != "C0"
    descriptive_loss <- descriptive_loss_from_oracle(
      action,
      oracle$descriptive_target[[1L]],
      scored = descriptive_scored
    )
    causal_loss <- causal_loss_from_oracle(
      causal_input$causal_action[[1L]],
      causal_input$conditional_certificates[[1L]],
      oracle$causal_target[[1L]],
      oracle$certificate_target[[1L]]
    )
    action_rows[[length(action_rows) + 1L]] <- data.frame(
      example = "E1",
      cell = cell$cell,
      graph_set = "classe_E1_fornecida",
      procedure = procedure,
      descriptive_result = action,
      expected_descriptive_result = oracle$descriptive_target[[1L]],
      descriptive_numeric_value = NA_real_,
      expected_descriptive_numeric_value = NA_real_,
      causal_action = causal_input$causal_action[[1L]],
      expected_causal_action = oracle$causal_target[[1L]],
      conditional_certificates =
        causal_input$conditional_certificates[[1L]],
      expected_conditional_certificates =
        oracle$certificate_target[[1L]],
      descriptive_loss = descriptive_loss,
      causal_loss = causal_loss,
      descriptive_target_source = "oraculo_declarativo_ficha_v2",
      causal_target_source = "oraculo_declarativo_ficha_v2",
      causal_output_source = causal_input$input_status[[1L]],
      component_omission_status = if (procedure == "C0") {
        "nao_pontuado"
      } else {
        "componentes_reportados"
      },
      information_gain_claim = "nenhum_ganho_informacional_atribuido",
      stringsAsFactors = FALSE
    )
  }

  for (procedure in c("P", "Cplus")) {
    values <- if (procedure == "P") p$quantities else cplus$quantities
    for (quantity in c("d_add", "signed_removal", "d_total")) {
      expected_sign <- sign_label(
        expected[[quantity]], scalar_tolerance(expected[[quantity]])
      )
      computed_sign <- sign_label(
        values[[quantity]], scalar_tolerance(expected[[quantity]])
      )
      sign_rows[[length(sign_rows) + 1L]] <- data.frame(
        example = "E1",
        cell = cell$cell,
        graph = "known_class",
        procedure = procedure,
        quantity = quantity,
        expected_sign = expected_sign,
        computed_sign = computed_sign,
        check_status = if (identical(expected_sign, computed_sign)) "PASS" else "FAIL",
        stringsAsFactors = FALSE
      )
    }
  }

  cov_p <- cplus$covariance_p$covariance
  cov_cp <- cplus$covariance_cplus$covariance
  if_p <- cplus$covariance_p$influence
  if_cp <- cplus$covariance_cplus$influence
  cov_tolerance <- matrix_tolerance(cov_p)
  cov_difference <- max(abs(cov_p - cov_cp))
  if_difference <- max(abs(if_p - if_cp))

  coefficient_indices <- c("B::D", "C::D", "U::D")
  coefficient_covariance <- cplus$stack$covariance[
    coefficient_indices, coefficient_indices, drop = FALSE
  ]
  a_matrix <- rbind(
    d_add = c(-1, 0, 1),
    d_lag = c(0, -1, 1)
  )
  colnames(a_matrix) <- coefficient_indices
  linear_transform <- a_matrix %*% coefficient_covariance %*% t(a_matrix)
  total_vector <- matrix(c(-1, 1, 0), nrow = 1L,
                         dimnames = list("d_total", coefficient_indices))
  total_variance <- total_vector %*% coefficient_covariance %*% t(total_vector)
  a_difference <- max(abs(linear_transform - cov_p[c("d_add", "d_lag"),
                                                    c("d_add", "d_lag")]))
  total_difference <- abs(total_variance[1, 1] - cov_p["d_total", "d_total"])

  covariance_check_rows[[length(covariance_check_rows) + 1L]] <- data.frame(
    example = "E1",
    cell = cell$cell,
    graph = "known_class",
    check = c(
      "same_stacked_sandwich_P_vs_Cplus",
      "same_implied_influence_P_vs_Cplus",
      "A_V_A_matches_direct_contrasts",
      "a_V_a_matches_total_contrast"
    ),
    max_abs_difference = c(
      cov_difference, if_difference, a_difference, total_difference
    ),
    tolerance = c(cov_tolerance, cov_tolerance, cov_tolerance, cov_tolerance),
    pass = c(
      cov_difference <= cov_tolerance,
      if_difference <= cov_tolerance,
      a_difference <= cov_tolerance,
      total_difference <= cov_tolerance
    ),
    scope = "transporte_algebrico_HC0_no_fixture_sem_inferencia",
    stringsAsFactors = FALSE
  )
  add_covariance_matrix("E1", cell$cell, "known_class", "P",
                        "contrast_covariance", cov_p)
  add_covariance_matrix("E1", cell$cell, "known_class", "Cplus",
                        "contrast_covariance", cov_cp)
  add_covariance_matrix("E1", cell$cell, "known_class", "linear_A_V_At",
                        "d_add_d_lag_covariance", linear_transform)
  estimates_label <- paste0(
    "theta_Z=", format(cplus$quantities[["theta_Z_U"]], digits = 17),
    ";pi_Z=", format(cplus$quantities[["pi_Z_given_L"]], digits = 17),
    ";theta_L=", format(cplus$quantities[["theta_L_U"]], digits = 17),
    ";pi_L=", format(cplus$quantities[["pi_L_given_Z"]], digits = 17)
  )
  add_gradient_rows("E1", cell$cell, "known_class", "P",
                    cplus$gradient_p, estimates_label)
  add_gradient_rows("E1", cell$cell, "known_class", "Cplus_product",
                    cplus$gradient_cplus, estimates_label)

  add_validation(
    "E1", cell$cell, "P_equals_Cplus_all_shared_quantities",
    max(abs(p$quantities[names(expected)[-1L]] -
              cplus$quantities[names(expected)[-1L]])),
    0, matrix_tolerance(expected[-1L]),
    max(abs(p$quantities[names(expected)[-1L]] -
              cplus$quantities[names(expected)[-1L]])) <=
      matrix_tolerance(expected[-1L]),
    "coeficientes e contrastes compartilhados"
  )
  add_validation(
    "E1", cell$cell, "direct_endpoint_identity",
    abs(cplus$quantities[["d_total"]] -
          (cplus$quantities[["beta_C"]] - cplus$quantities[["beta_B"]])),
    0, scalar_tolerance(expected[["d_total"]]),
    abs(cplus$quantities[["d_total"]] -
          (cplus$quantities[["beta_C"]] - cplus$quantities[["beta_B"]])) <=
      scalar_tolerance(expected[["d_total"]]),
    "d_total=d_add-d_lag=beta_C-beta_B"
  )
}

e2_fixtures <- make_e2_fixtures()
gm_map <- rbind(
  D = c(1, 0, 0),
  Z = c(1, 1, 0),
  Y = c(2, 1, 1)
)
gf_map <- rbind(
  D = c(1 / 2, 1, 0),
  Z = c(1, 0, 0),
  Y = c(3 / 2, 1, 1)
)
sigma_gm <- gm_map %*% diag(c(1, 1, 1)) %*% t(gm_map)
sigma_gf <- gf_map %*% diag(c(2, 1 / 2, 1)) %*% t(gf_map)
sigma_expected <- matrix(
  c(1, 1, 2, 1, 2, 3, 2, 3, 6),
  nrow = 3L, byrow = TRUE,
  dimnames = list(c("D", "Z", "Y"), c("D", "Z", "Y"))
)

observable_covariance_rows <- list()
for (graph in c("G_M", "G_F")) {
  fixture <- e2_fixtures[[graph]]
  observed_matrix <- crossprod(as.matrix(fixture[c("D", "Z", "Y")])) /
    nrow(fixture)
  structural_matrix <- if (graph == "G_M") sigma_gm else sigma_gf
  for (source in c("structural_transform", "fixture_moments")) {
    value <- if (source == "structural_transform") {
      structural_matrix
    } else {
      observed_matrix
    }
    for (i in seq_len(nrow(value))) {
      for (j in seq_len(ncol(value))) {
        observable_covariance_rows[[length(observable_covariance_rows) + 1L]] <-
          data.frame(
            graph = graph,
            source = source,
            row = rownames(sigma_expected)[i],
            column = colnames(sigma_expected)[j],
            value = value[i, j],
            expected = sigma_expected[i, j],
            abs_error = abs(value[i, j] - sigma_expected[i, j]),
            stringsAsFactors = FALSE
          )
      }
    }
  }
  matrix_error <- max(abs(structural_matrix - sigma_expected))
  fixture_error <- max(abs(observed_matrix - sigma_expected))
  add_validation(
    "E2", graph, "structural_covariance_equals_common_matrix",
    matrix_error, 0, matrix_tolerance(sigma_expected),
    matrix_error <= matrix_tolerance(sigma_expected),
    "transformacao linear exata das variancias dos erros"
  )
  add_validation(
    "E2", graph, "fixture_covariance_equals_common_matrix",
    fixture_error, 0, matrix_tolerance(sigma_expected),
    fixture_error <= matrix_tolerance(sigma_expected),
    "produto interno dividido por oito; nao e amostra gaussiana"
  )

  p <- run_e2_p(fixture)
  c0 <- run_e2_c0(fixture)
  cplus <- run_e2_cplus(fixture)
  for (procedure_name in c("C0", "Cplus", "P")) {
    procedure_fits <- switch(
      procedure_name, C0 = c0$fits, Cplus = cplus$fits, P = p$fits
    )
    row_signatures <- vapply(
      procedure_fits,
      function(fit) paste(fit$row_id, collapse = "|"),
      character(1L)
    )
    input_consistency_rows[[length(input_consistency_rows) + 1L]] <-
      data.frame(
        example = "E2",
        cell = graph,
        procedure = procedure_name,
        same_rows = length(unique(row_signatures)) == 1L,
        common_intercept = all(vapply(
          procedure_fits,
          function(fit) all(fit$x[, "intercept"] == 1),
          logical(1L)
        )),
        common_D_values = all(vapply(
          procedure_fits,
          function(fit) {
            if (!"D" %in% colnames(fit$x)) return(TRUE)
            identical(as.numeric(fit$x[, "D"]), as.numeric(fixture$D))
          },
          logical(1L)
        )),
        transformation = "identidade",
        stringsAsFactors = FALSE
      )
  }
  for (fit in p$fits) {
    diagnostic_rows[[length(diagnostic_rows) + 1L]] <-
      fit_diagnostic("E2", graph, "P", fit)
  }
  for (fit in c0$fits) {
    diagnostic_rows[[length(diagnostic_rows) + 1L]] <-
      fit_diagnostic("E2", graph, "C0", fit)
  }
  for (fit in cplus$fits) {
    diagnostic_rows[[length(diagnostic_rows) + 1L]] <-
      fit_diagnostic("E2", graph, "Cplus", fit)
  }

  for (quantity in names(e2_expected)) {
    if (quantity %in% names(p$quantities)) {
      add_projection("E2", graph, graph, "P", quantity,
                     e2_expected[[quantity]], p$quantities[[quantity]])
    }
    if (quantity %in% names(cplus$quantities)) {
      add_projection("E2", graph, graph, "Cplus", quantity,
                     e2_expected[[quantity]], cplus$quantities[[quantity]])
    }
    if (quantity %in% names(c0$quantities)) {
      add_projection("E2", graph, graph, "C0", quantity,
                     e2_expected[[quantity]], c0$quantities[[quantity]])
    } else {
      add_projection("E2", graph, graph, "C0", quantity,
                     e2_expected[[quantity]], NA_real_,
                     field_status = "campo_nao_reportado")
    }
  }

  oracle <- e2_action_oracle[e2_action_oracle$graph == graph, ]
  causal_input <- e2_causal_inputs[e2_causal_inputs$graph == graph, ]
  if (nrow(oracle) != 1L || nrow(causal_input) != 1L) {
    stop("Oraculo E2 ausente ou duplicado para: ", graph, call. = FALSE)
  }
  for (procedure in c("C0", "Cplus", "P")) {
    observed_delta <- if (procedure == "C0") {
      c0$quantities[["delta"]]
    } else if (procedure == "Cplus") {
      cplus$quantities[["delta"]]
    } else {
      p$quantities[["delta"]]
    }
    descriptive_loss <- descriptive_loss_from_oracle(
      "shift_descritivo",
      oracle$descriptive_target[[1L]],
      scored = TRUE,
      observed_value = observed_delta,
      target_value = oracle$descriptive_value_target[[1L]]
    )
    causal_loss <- causal_loss_from_oracle(
      causal_input$causal_action[[1L]],
      causal_input$conditional_certificates[[1L]],
      oracle$causal_target[[1L]],
      oracle$certificate_target[[1L]]
    )
    action_rows[[length(action_rows) + 1L]] <- data.frame(
      example = "E2",
      cell = graph,
      graph_set = "G_M|G_F",
      procedure = procedure,
      descriptive_result = "shift_descritivo",
      expected_descriptive_result = oracle$descriptive_target[[1L]],
      descriptive_numeric_value = observed_delta,
      expected_descriptive_numeric_value =
        oracle$descriptive_value_target[[1L]],
      causal_action = causal_input$causal_action[[1L]],
      expected_causal_action = oracle$causal_target[[1L]],
      conditional_certificates =
        causal_input$conditional_certificates[[1L]],
      expected_conditional_certificates =
        oracle$certificate_target[[1L]],
      descriptive_loss = descriptive_loss,
      causal_loss = causal_loss,
      descriptive_target_source = "oraculo_declarativo_ficha_v2",
      causal_target_source = "oraculo_declarativo_ficha_v2",
      causal_output_source = causal_input$input_status[[1L]],
      component_omission_status = if (procedure == "C0") {
        "theta_e_pi_nao_reportados_sem_pontuacao"
      } else {
        "componentes_reportados"
      },
      information_gain_claim = "nenhum_ganho_informacional_atribuido",
      stringsAsFactors = FALSE
    )
  }

  for (procedure in c("P", "Cplus")) {
    delta_value <- if (procedure == "P") {
      p$quantities[["delta"]]
    } else {
      cplus$quantities[["delta"]]
    }
    expected_sign <- sign_label(e2_expected[["delta"]],
                                scalar_tolerance(e2_expected[["delta"]]))
    computed_sign <- sign_label(delta_value,
                                scalar_tolerance(e2_expected[["delta"]]))
    sign_rows[[length(sign_rows) + 1L]] <- data.frame(
      example = "E2",
      cell = graph,
      graph = graph,
      procedure = procedure,
      quantity = "delta",
      expected_sign = expected_sign,
      computed_sign = computed_sign,
      check_status = if (identical(expected_sign, computed_sign)) "PASS" else "FAIL",
      stringsAsFactors = FALSE
    )
  }

  cov_p <- cplus$covariance_p$covariance
  cov_cp <- cplus$covariance_cplus$covariance
  if_p <- cplus$covariance_p$influence
  if_cp <- cplus$covariance_cplus$influence
  cov_tolerance <- matrix_tolerance(cov_p)
  covariance_check_rows[[length(covariance_check_rows) + 1L]] <- data.frame(
    example = "E2",
    cell = graph,
    graph = graph,
    check = c(
      "same_stacked_sandwich_P_vs_Cplus",
      "same_implied_influence_P_vs_Cplus"
    ),
    max_abs_difference = c(
      max(abs(cov_p - cov_cp)),
      max(abs(if_p - if_cp))
    ),
    tolerance = c(cov_tolerance, cov_tolerance),
    pass = c(
      max(abs(cov_p - cov_cp)) <= cov_tolerance,
      max(abs(if_p - if_cp)) <= cov_tolerance
    ),
    scope = "transporte_algebrico_HC0_no_fixture_sem_inferencia",
    stringsAsFactors = FALSE
  )
  add_covariance_matrix("E2", graph, graph, "P",
                        "delta_covariance", cov_p)
  add_covariance_matrix("E2", graph, graph, "Cplus",
                        "delta_covariance", cov_cp)
  estimates_label <- paste0(
    "theta_Z=", format(cplus$quantities[["theta_Z_T"]], digits = 17),
    ";pi_Z=", format(cplus$quantities[["pi_Z"]], digits = 17)
  )
  add_gradient_rows("E2", graph, graph, "P",
                    cplus$gradient_p, estimates_label)
  add_gradient_rows("E2", graph, graph, "Cplus_product",
                    cplus$gradient_cplus, estimates_label)

  shared <- c("beta_S", "beta_T", "delta")
  shared_difference <- max(abs(p$quantities[shared] -
                                 cplus$quantities[shared]))
  add_validation(
    "E2", graph, "P_equals_Cplus_all_shared_quantities",
    shared_difference, 0, matrix_tolerance(e2_expected[shared]),
    shared_difference <= matrix_tolerance(e2_expected[shared]),
    "coeficientes e shift compartilhados"
  )
}

gm_do_0 <- e2_gm_under_do_D(0)
gm_do_1 <- e2_gm_under_do_D(1)
gf_do_0 <- e2_gf_under_do_D(0)
gf_do_1 <- e2_gf_under_do_D(1)
interventional_effect_table <- data.frame(
  graph = c("G_M", "G_F"),
  D_from = c(0, 0),
  D_to = c(1, 1),
  Y_under_D_from = c(gm_do_0[["Y"]], gf_do_0[["Y"]]),
  Y_under_D_to = c(gm_do_1[["Y"]], gf_do_1[["Y"]]),
  computed_total_effect = c(
    gm_do_1[["Y"]] - gm_do_0[["Y"]],
    gf_do_1[["Y"]] - gf_do_0[["Y"]]
  ),
  target_total_effect = c(2, 1),
  source = rep("equacoes_SCM_sinteticas_sob_do_D", 2L),
  stringsAsFactors = FALSE
)
interventional_effect_table$abs_error <- abs(
  interventional_effect_table$computed_total_effect -
    interventional_effect_table$target_total_effect
)
interventional_effect_table$tolerance <- vapply(
  interventional_effect_table$target_total_effect,
  scalar_tolerance,
  numeric(1L)
)
interventional_effect_table$pass <-
  interventional_effect_table$abs_error <=
  interventional_effect_table$tolerance
for (i in seq_len(nrow(interventional_effect_table))) {
  add_validation(
    "E2", interventional_effect_table$graph[i],
    "total_effect_from_structural_do_D_response",
    interventional_effect_table$computed_total_effect[i],
    interventional_effect_table$target_total_effect[i],
    interventional_effect_table$tolerance[i],
    interventional_effect_table$pass[i],
    "resposta a D:0->1 nas equacoes do SCM sintetico conhecido"
  )
}
cet_difference <- abs(diff(interventional_effect_table$computed_total_effect))
add_validation(
  "E2", "G_M_vs_G_F", "different_do_D_total_effects",
  cet_difference, 1, scalar_tolerance(1),
  abs(cet_difference - 1) <= scalar_tolerance(1),
  "diferenca entre efeitos recalculados pelas equacoes G_M e G_F"
)
sigma_difference <- max(abs(sigma_gm - sigma_gf))
add_validation(
  "E2", "G_M_vs_G_F", "equal_observable_covariance",
  sigma_difference, 0, matrix_tolerance(sigma_expected),
  sigma_difference <= matrix_tolerance(sigma_expected),
  "mesma matriz observavel; DAG nao selecionado pelo shift"
)

projection_table <- do.call(rbind, projection_rows)
action_table <- do.call(rbind, action_rows)
sign_table <- do.call(rbind, sign_rows)
diagnostic_table <- do.call(rbind, diagnostic_rows)
covariance_check_table <- do.call(rbind, covariance_check_rows)
covariance_matrix_table <- do.call(rbind, covariance_matrix_rows)
gradient_table <- do.call(rbind, gradient_rows)
validation_table <- do.call(rbind, validation_rows)
observable_covariance_table <- do.call(rbind, observable_covariance_rows)
e1_fixture_table <- do.call(rbind, e1_fixture_list)
e2_fixture_table <- rbind(e2_fixtures$G_M, e2_fixtures$G_F)
input_consistency_table <- do.call(rbind, input_consistency_rows)

for (i in seq_len(nrow(action_table))) {
  is_unscored_c0_omission <-
    action_table$example[i] == "E1" && action_table$procedure[i] == "C0"
  descriptive_pass <- if (is_unscored_c0_omission) {
    is.na(action_table$descriptive_loss[i]) &&
      action_table$component_omission_status[i] == "nao_pontuado"
  } else {
    !is.na(action_table$descriptive_loss[i]) &&
      action_table$descriptive_loss[i] == 0L
  }
  add_validation(
    action_table$example[i], action_table$cell[i],
    paste0("descriptive_action_", action_table$procedure[i], "_vs_oracle"),
    action_table$descriptive_result[i],
    action_table$expected_descriptive_result[i],
    if (is_unscored_c0_omission) "nao_pontuado" else "regra_0_1_4",
    descriptive_pass,
    if (is_unscored_c0_omission) {
      "omissao C0 preservada sem perda"
    } else {
      paste0("perda_calculada=", action_table$descriptive_loss[i])
    }
  )
  add_validation(
    action_table$example[i], action_table$cell[i],
    paste0("causal_action_", action_table$procedure[i], "_vs_oracle"),
    paste(
      action_table$causal_action[i],
      action_table$conditional_certificates[i],
      sep = " | "
    ),
    paste(
      action_table$expected_causal_action[i],
      action_table$expected_conditional_certificates[i],
      sep = " | "
    ),
    "regra_0_4",
    action_table$causal_loss[i] == 0L,
    paste0(
      "perda_calculada=", action_table$causal_loss[i],
      "; certificados sao inputs analiticos, nao descoberta causal"
    )
  )
}

for (i in seq_len(nrow(projection_table))) {
  if (projection_table$field_status[i] == "reportado") {
    add_validation(
      projection_table$example[i], projection_table$cell[i],
      paste0(
        "projection_", projection_table$procedure[i], "_",
        projection_table$quantity[i]
      ),
      projection_table$abs_error[i], 0,
      projection_table$tolerance[i],
      projection_table$check_status[i] == "PASS",
      "output confrontado com projecao derivada da algebra"
    )
  }
}
validation_table <- do.call(rbind, validation_rows)

all_ranks_pass <- all(diagnostic_table$full_rank)
all_conditioning_finite <- all(
  is.finite(diagnostic_table$kappa_design) &
    is.finite(diagnostic_table$kappa_gram)
)
all_input_consistency <- all(
  input_consistency_table$same_rows &
    input_consistency_table$common_intercept &
    input_consistency_table$common_D_values &
    input_consistency_table$transformation == "identidade"
)
all_normal_equations_pass <- all(
  diagnostic_table$max_abs_normal_equation <=
    scalar_tolerance(diagnostic_table$max_abs_normal_equation * 0)
)
valid_loss_values <- all(
  action_table$descriptive_loss[!is.na(action_table$descriptive_loss)] %in%
    c(0L, 1L, 4L)
) && all(action_table$causal_loss %in% c(0L, 1L, 4L))
all_scored_actions_correct <- all(
  action_table$descriptive_loss[!is.na(action_table$descriptive_loss)] == 0L
) && all(action_table$causal_loss == 0L)
add_validation(
  "all", "all", "all_condition_numbers_finite",
  all_conditioning_finite, TRUE, 0, all_conditioning_finite,
  "condicionamento registrado sem excluir celulas"
)
add_validation(
  "all", "all", "same_rows_and_common_transformations",
  all_input_consistency, TRUE, 0, all_input_consistency,
  "identificadores, intercepto, tratamento e transformacao comum"
)
add_validation(
  "all", "all", "all_designs_full_rank",
  all_ranks_pass, TRUE, 0, all_ranks_pass,
  "nenhuma celula removida por posto ou resultado"
)
add_validation(
  "all", "all", "all_normal_equations_within_tolerance",
  max(diagnostic_table$max_abs_normal_equation), 0,
  scalar_tolerance(0), all_normal_equations_pass,
  "equacoes normais de OLS"
)
add_validation(
  "all", "all", "loss_values_follow_frozen_scale",
  valid_loss_values, TRUE, 0, valid_loss_values,
  "perdas calculadas pertencem a 0, 1 ou 4; omissao C0 E1 fica NA"
)
add_validation(
  "all", "all", "all_scored_actions_match_oracle",
  all_scored_actions_correct, TRUE, 0, all_scored_actions_correct,
  "acerto contra oraculo declarativo, alem do acordo P/Cplus"
)

action_pc <- subset(action_table, procedure %in% c("P", "Cplus"))
action_groups <- split(
  seq_len(nrow(action_pc)),
  interaction(action_pc$example, action_pc$cell, drop = TRUE)
)
action_equivalence <- all(vapply(
  action_groups,
  function(index) {
    rows <- action_pc[index, ]
    length(unique(rows$descriptive_result)) == 1L &&
      length(unique(rows$causal_action)) == 1L &&
      length(unique(rows$conditional_certificates)) == 1L
  },
  logical(1L)
))
add_validation(
  "all", "all", "P_Cplus_action_equivalence",
  action_equivalence, TRUE, 0, action_equivalence,
  "mesmas acoes descritivas e causais com a mesma informacao"
)

validation_table <- do.call(rbind, validation_rows)
covariance_pass <- all(covariance_check_table$pass)
projection_pass <- all(
  projection_table$check_status[projection_table$field_status == "reportado"] ==
    "PASS"
)
sign_pass <- all(sign_table$check_status == "PASS")
overall_pass <- all(validation_table$pass) && covariance_pass &&
  projection_pass && sign_pass

procedure_comparison <- data.frame(
  comparison = c(
    "P_vs_Cplus_projections",
    "P_vs_Cplus_actions",
    "all_scored_actions_vs_frozen_oracle",
    "P_vs_Cplus_covariance_transform",
    "C0_component_fields",
    "tested_domain_conclusion"
  ),
  result = c(
    if (projection_pass) "iguais_dentro_da_tolerancia" else "divergentes",
    if (action_equivalence) "iguais" else "divergentes",
    if (all_scored_actions_correct) "corretas" else "ao_menos_uma_incorreta",
    if (covariance_pass) "iguais_dentro_da_tolerancia" else "divergentes",
    "campo_nao_reportado_sem_perda",
    if (overall_pass) {
      "equivalencia_do_procedimento_testado_no_dominio_de_posto_completo"
    } else {
      "identidade_numerica_falhou"
    }
  ),
  information_gain_claim = rep(
    "nenhum_ganho_informacional_atribuido", 6L
  ),
  stringsAsFactors = FALSE
)

write_csv_safe(e1_fixture_table, "synthetic_fixture_e1.csv")
write_csv_safe(e2_fixture_table, "synthetic_fixture_e2.csv")
write_csv_safe(projection_table, "expected_vs_computed_projections.csv")
write_csv_safe(action_table, "actions_and_losses.csv")
write_csv_safe(sign_table, "sign_checks.csv")
write_csv_safe(input_consistency_table, "input_consistency.csv")
write_csv_safe(diagnostic_table, "rank_and_conditioning.csv")
write_csv_safe(observable_covariance_table, "e2_observable_covariances.csv")
write_csv_safe(interventional_effect_table, "e2_interventional_effects.csv")
write_csv_safe(covariance_check_table, "covariance_transform_checks.csv")
write_csv_safe(covariance_matrix_table, "covariance_matrices.csv")
write_csv_safe(gradient_table, "product_gradients.csv")
write_csv_safe(procedure_comparison, "procedure_comparison.csv")
write_csv_safe(validation_table, "validation_checks.csv")

log_message(paste0("celulas_E1_preservadas=", nrow(e1_cells)))
log_message("grafos_E2_preservados=2")
log_message(paste0("validation_checks=", nrow(validation_table)))
log_message(paste0("overall_pass=", overall_pass))
computed_pass <- isTRUE(overall_pass)

write_text_safe(
  c(
    run_log,
    paste0(
      "verification_checks=",
      if (computed_pass) "PASS" else "FAILED"
    ),
    "delivery_status=PENDING_FINALIZATION"
  ),
  "run_log.txt"
)
write_text_safe(capture.output(sessionInfo()), "sessionInfo.txt")

required_output_names <- c(
  "synthetic_fixture_e1.csv",
  "synthetic_fixture_e2.csv",
  "expected_vs_computed_projections.csv",
  "actions_and_losses.csv",
  "sign_checks.csv",
  "input_consistency.csv",
  "rank_and_conditioning.csv",
  "e2_observable_covariances.csv",
  "e2_interventional_effects.csv",
  "covariance_transform_checks.csv",
  "covariance_matrices.csv",
  "product_gradients.csv",
  "procedure_comparison.csv",
  "validation_checks.csv",
  "run_log.txt",
  "sessionInfo.txt"
)
output_files <- file.path(run_dir, required_output_names)
if (!all(file.exists(output_files))) {
  stop("Saida obrigatoria ausente antes do manifesto.", call. = FALSE)
}
output_manifest <- data.frame(
  file = basename(output_files),
  sha256 = vapply(output_files, sha256_file, character(1L)),
  bytes = as.numeric(file.info(output_files)$size),
  manifest_scope = rep(
    "required_outputs_excluding_manifest_self_and_final_status",
    length(output_files)
  ),
  stringsAsFactors = FALSE
)
write_csv_safe(output_manifest, "output_manifest.csv")
output_manifest_hash <- sha256_file(file.path(run_dir, "output_manifest.csv"))

if (!computed_pass) {
  write_text_safe(
    c(
      "status=FAILED",
      "reason=prespecified_validation_failed",
      paste0("output_manifest_sha256=", output_manifest_hash),
      "manifest_excludes=output_manifest.csv|final_status.txt"
    ),
    "final_status.txt"
  )
  stop(
    "FAIL-STOP: ao menos uma identidade ou acao pre-especificada falhou. ",
    "Consulte validation_checks.csv; nenhuma celula foi removida.",
    call. = FALSE
  )
}

write_text_safe(
  c(
    "status=PASS",
    "reason=all_prespecified_checks_and_required_outputs_completed",
    paste0("output_manifest_sha256=", output_manifest_hash),
    "manifest_excludes=output_manifest.csv|final_status.txt"
  ),
  "final_status.txt"
)
run_complete <- TRUE
message("PASS: verificacao deterministica concluida em ", run_dir)
}

main()
