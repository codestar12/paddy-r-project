# 02_summary.R
# Textual summary: structure, missingness, correlations with the target.
# Run: Rscript R/02_summary.R

library(here)
library(janitor)
library(readr)
library(tidyverse)

paddy <- readRDS(here("data", "paddy.rds"))
dic <- readRDS(here("data", "data_dictionary.rds"))

cat("== STRUCTURE ==\n")
cat("Rows:", nrow(paddy), "| Cols:", ncol(paddy), "\n")
cat("Categorical variables:\n")
cat(paste0("  - ", paste(unique(dic$variable[dic$type == "categorical"]), collapse = ", "), "\n"))
cat("\n== MISSINGNESS ==\n")
miss <- data.frame(
  variable = names(paddy),
  missing = vapply(paddy, function(x) sum(is.na(x)), integer(1)),
  stringsAsFactors = FALSE
)
miss <- miss[miss$missing > 0, ]
print(miss, row.names = FALSE)
cat("Total missing cells:", sum(miss$missing), "\n")

cat("\n== NUMERIC SUMMARY ==\n")
num_vars <- dic$variable[dic$type %in% c("integer", "continuous")]
print(paddy %>% select(all_of(num_vars), paddy_yield_kg) %>% summary())

cat("\n== CORRELATION WITH PADDY YIELD (numeric features) ==\n")
corr <- paddy %>%
  select(all_of(num_vars), paddy_yield_kg) %>%
  cor(use = "pairwise.complete.obs")
corr_target <- corr[, "paddy_yield_kg", drop = TRUE] %>% sort(decreasing = TRUE)
print(round(corr_target, 3))
