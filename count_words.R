# Word count script for ivb_paper_psrm.Rmd
# Counts main text only (abstract through conclusion), excluding appendix/references

lines <- readLines("ivb_paper_psrm.Rmd")

# Find YAML boundaries
yaml_markers <- which(lines == "---")
body_start <- yaml_markers[2] + 1

# Find where references/appendix start
ref_line <- grep("^\\\\singlespacing", lines)
if (length(ref_line) == 0) ref_line <- grep("^\\\\bibliographystyle", lines)
cutoff <- ref_line[1]

cat("Main text: lines", body_start, "to", cutoff - 1, "\n")

# Get main text lines
main_lines <- lines[body_start:(cutoff - 1)]

# Remove R code chunks
in_chunk <- FALSE
prose_lines <- c()
for (line in main_lines) {
  if (grepl("^```", line) && grepl("\\{", line)) { in_chunk <- TRUE; next }
  if (in_chunk && grepl("^```$", line)) { in_chunk <- FALSE; next }
  if (!in_chunk) prose_lines <- c(prose_lines, line)
}

# Join text
text <- paste(prose_lines, collapse = " ")

# Strip LaTeX environments (tikzpicture, figure, table, equation, etc.)
text <- gsub("\\\\begin\\{tikzpicture\\}.*?\\\\end\\{tikzpicture\\}", "", text)
text <- gsub("\\\\begin\\{figure\\}.*?\\\\end\\{figure\\}", " ", text)
text <- gsub("\\\\begin\\{table\\}.*?\\\\end\\{table\\}", " ", text)
text <- gsub("\\\\begin\\{equation\\}.*?\\\\end\\{equation\\}", " ", text)
text <- gsub("\\\\begin\\{align\\*?\\}.*?\\\\end\\{align\\*?\\}", " ", text)
text <- gsub("\\\\begin\\{enumerate\\}.*?\\\\end\\{enumerate\\}", " ", text)
text <- gsub("\\\\begin\\{proposition\\}.*?\\\\end\\{proposition\\}", " ", text)

# Strip display math ($$...$$) and \[...\]
text <- gsub("\\$\\$.*?\\$\\$", " ", text)
text <- gsub("\\\\\\[.*?\\\\\\]", " ", text)

# Strip inline math ($...$)
text <- gsub("\\$[^$]+\\$", " MATH ", text)

# Strip LaTeX commands with arguments
text <- gsub("\\\\[a-zA-Z]+\\{[^}]*\\}", " ", text)
text <- gsub("\\\\[a-zA-Z]+\\[[^]]*\\]", " ", text)
text <- gsub("\\\\[a-zA-Z]+", " ", text)

# Remove remaining braces, brackets
text <- gsub("[{}\\[\\]~]", " ", text)
text <- gsub("\\\\", " ", text)

# Clean up whitespace
text <- gsub("\\s+", " ", text)
text <- trimws(text)

# Count
words <- length(strsplit(text, "\\s+")[[1]])

cat("\n========================================\n")
cat("WORD COUNT — Main Text (Abstract–Conclusion)\n")
cat("========================================\n")
cat("Total words:", words, "\n")
cat("Target: <= 9,000\n")
if (words <= 9000) {
  cat("Status: WITHIN BUDGET\n")
} else {
  cat("Status: OVER BUDGET by", words - 9000, "words\n")
}
cat("========================================\n")

# Section-by-section count
cat("\nSection breakdown:\n")

sec_patterns <- c(
  "Abstract" = "^abstract:",
  "1. Introduction" = "^# Introduction$",
  "2. Control Variable" = "^# The Control Variable Problem",
  "3. DAGs" = "^# DAGs and Collider Bias",
  "4. IVB Formula" = "^# The Included Variable Bias Formula",
  "5. Monte Carlo" = "^# Monte Carlo Validation",
  "6. Application" = "^# Application",
  "7. Conclusion" = "^# Conclusion"
)

sec_starts <- c()
for (nm in names(sec_patterns)) {
  idx <- grep(sec_patterns[nm], lines, ignore.case = TRUE)
  if (length(idx) > 0) sec_starts[nm] <- idx[1]
}
sec_starts <- sort(sec_starts)
sec_starts["(End)"] <- cutoff

for (i in 1:(length(sec_starts) - 1)) {
  s <- sec_starts[i]
  e <- sec_starts[i + 1] - 1
  sec_text <- lines[s:e]

  # Remove chunks
  in_ch <- FALSE
  sp <- c()
  for (line in sec_text) {
    if (grepl("^```", line) && grepl("\\{", line)) { in_ch <- TRUE; next }
    if (in_ch && grepl("^```$", line)) { in_ch <- FALSE; next }
    if (!in_ch) sp <- c(sp, line)
  }

  t <- paste(sp, collapse = " ")
  t <- gsub("\\\\begin\\{[^}]+\\}.*?\\\\end\\{[^}]+\\}", " ", t)
  t <- gsub("\\$\\$.*?\\$\\$", " ", t)
  t <- gsub("\\\\\\[.*?\\\\\\]", " ", t)
  t <- gsub("\\$[^$]+\\$", " ", t)
  t <- gsub("\\\\[a-zA-Z]+\\{[^}]*\\}", " ", t)
  t <- gsub("\\\\[a-zA-Z]+", " ", t)
  t <- gsub("[{}\\[\\]~\\\\]", " ", t)
  t <- gsub("\\s+", " ", t)
  t <- trimws(t)

  w <- length(strsplit(t, "\\s+")[[1]])
  cat(sprintf("  %-30s %5d words\n", names(sec_starts)[i], w))
}
