# Feature selection, regression, and ANOVA analysis for the UCI Paddy dataset.
# Produces PNGs in output/ and a summary text file.
#
# Run: Rscript R/05_regression_analysis.R   (or `make all`)

library(here)
library(janitor)
library(tidyverse)
library(broom)
library(car)
library(MASS)

paddy <- readRDS(here("data", "paddy.rds"))
dir.create(here("output"), showWarnings = FALSE, recursive = TRUE)
dic <- readRDS(here("data", "data_dictionary.rds"))
numeric_vars <- dic$variable[dic$type %in% c("integer", "continuous")]
categorical_vars <- dic$variable[dic$type == "categorical"]

# ---------------------------------------------------------------- 1. Feature selection
cat("1/6 Feature selection\n")

# Correlation-based ranking: top features by |correlation| with yield
num_df <- dplyr::select(paddy, dplyr::all_of(numeric_vars))
cat_data <- dplyr::select(paddy, dplyr::all_of(categorical_vars))
target_corr <- sapply(num_df, function(x) cor(x, paddy$paddy_yield_kg, use = "pairwise.complete.obs"))
feat_corr <- tibble(feature = names(target_corr), corr = target_corr) %>%
  mutate(abs_corr = abs(corr)) %>%
  arrange(desc(abs_corr))
top15 <- feat_corr %>% slice_head(n = 15)

cat("\nTop 15 features by |correlation| with paddy_yield:\n")
print(top15, n = 15)

# Stepwise regression (AIC-based): start simple, add/remove features
set.seed(42)
start_model <- lm(paddy_yield_kg ~ seedrate_kg + hectares, data = paddy)
step_model <- stepAIC(start_model, scope = list(lower = ~ 1, upper = ~ .),
                      direction = "forward", trace = 0)
selected_features <- setdiff(names(coef(step_model)), "(Intercept)")
cat("\nStepwise model selected features:", paste(selected_features, collapse = ", "), "\n")

# ---------------------------------------------------------------- 2. Regression
cat("\n2/6 Regression\n")

# Final model with selected features
final_model <- lm(as.formula(paste("paddy_yield_kg ~", paste(selected_features, collapse = " + "))), data = paddy)
model_sum <- glance(final_model)
coefs <- tidy(final_model)
anova_tab <- car::Anova(final_model, type = 2)
pred <- predict(final_model)
actual <- paddy$paddy_yield_kg
resid <- actual - pred

cat("\nFinal model:\n")
cat("  R-squared:", round(model_sum$r.squared, 4), "\n")
cat("  Adj R-squared:", round(model_sum$adj.r.squared, 4), "\n")
cat("  F-statistic:", round(model_sum$statistic, 2),
    "p =", signif(model_sum$p.value, 3), "\n")
cat("  Predictors:", paste(selected_features, collapse = ", "), "\n")

# ---------------------------------------------------------------- 3. ANOVA (categorical features)
cat("\n3/6 ANOVA (one-way, each categorical feature vs yield)\n")
anova_cat <- map_dfr(names(cat_data), function(v) {
  m <- lm(as.formula(paste("paddy_yield_kg ~", v)), data = paddy)
  a <- car::Anova(m, type = 2) %>% slice(1)
  tibble(feature = v, Df = a$Df, `Sum Sq` = a$`Sum Sq`, `Mean Sq` = a$`Mean Sq`,
         `F value` = a$`F value`, `Pr(>F)` = a$`Pr(>F)`)
})
cat("Feature | Df | Sum Sq | Mean Sq | F value | Pr(>F)\n")
cat("--------|----|--------|---------|---------|---------\n")
print(anova_cat, n = Inf)

# ---------------------------------------------------------------- 4. Visualizations
cat("\n4/6 Visualizations\n")

# --- 4a. Feature importance: regression coefficients
cat("4a. Feature importance (coefficients)\n")
coef_plot_data <- coefs %>%
  filter(term != "(Intercept)") %>%
  arrange(abs(estimate)) %>%
  mutate(term = factor(term, levels = rev(term)))
coef_plot <- ggplot(coef_plot_data, aes(x = estimate, y = term)) +
  geom_col(aes(fill = estimate >= 0), show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "steelblue", "FALSE" = "firebrick")) +
  geom_vline(xintercept = 0, colour = "grey50", size = 0.5) +
  labs(x = "Coefficient estimate", y = NULL,
       title = paste0("Final model coefficients (R² = ", round(model_sum$r.squared, 3), ")")) +
  theme_minimal(base_size = 9)
ggsave(here("output", "11_feature_importance.png"), coef_plot, width = 9, height = 6, dpi = 120)

# --- 4b. Model comparison: R² for different feature sets
cat("4b. Model comparison\n")
models_r2 <- tibble(
  model = c("seedrate only",
            "top 3 features",
            "stepwise (AIC)",
            "full (all numeric)"),
  r2 = c(
    summary(lm(paddy_yield_kg ~ seedrate_kg, data = paddy))$r.squared,
    summary(lm(paddy_yield_kg ~ seedrate_kg + hectares + nursery_area_cents, data = paddy))$r.squared,
    model_sum$r.squared,
    summary(lm(paddy_yield_kg ~ ., data = dplyr::select(paddy, dplyr::all_of(numeric_vars))))$r.squared
  )
)
cat("\nModel comparison (R-squared):\n")
print(models_r2, n = Inf)

# --- 4c. Predicted vs actual
cat("4c. Predicted vs actual\n")
p_pred <- ggplot(tibble(actual = actual, predicted = pred), aes(x = actual, y = predicted)) +
  geom_point(alpha = 0.25, colour = "steelblue", size = 0.8) +
  geom_abline(slope = 1, intercept = 0, colour = "darkred", linetype = "dashed") +
  labs(x = "Actual paddy yield (Kg)", y = "Predicted paddy yield (Kg)",
       title = paste("Predicted vs actual (R² =", round(model_sum$r.squared, 3), ")")) +
  theme_minimal(base_size = 9)
ggsave(here("output", "12_predicted_vs_actual.png"), p_pred, width = 8, height = 6, dpi = 120)

# --- 4d. Residuals vs fitted + QQ
cat("4d. Residual diagnostics\n")
p_res <- ggplot(tibble(fitted = pred, resid = resid), aes(x = fitted, y = resid)) +
  geom_point(alpha = 0.25, colour = "darkorange", size = 0.8) +
  geom_hline(yintercept = 0, colour = "grey50", linetype = "dashed") +
  labs(x = "Fitted values", y = "Residuals",
       title = "Residuals vs fitted") +
  theme_minimal(base_size = 9)
ggsave(here("output", "13_residuals_vs_fitted.png"), p_res, width = 8, height = 6, dpi = 120)

p_qq <- ggplot(tibble(resid = resid), aes(sample = resid)) +
  stat_qq(colour = "steelblue") +
  stat_qq_line(colour = "darkred") +
  labs(x = "Theoretical quantiles", y = "Sample quantiles",
       title = "Normal Q-Q plot of residuals") +
  theme_minimal(base_size = 9)
ggsave(here("output", "14_residual_qq.png"), p_qq, width = 8, height = 6, dpi = 120)

# --- 4e. ANOVA results: F-statistics bar chart
cat("4e. ANOVA results\n")
p_anova <- anova_cat %>%
  mutate(feature = fct_reorder(feature, `F value`)) %>%
  ggplot(aes(x = feature, y = `F value`, fill = `Pr(>F)`)) +
  geom_col() +
  scale_fill_gradientn(colours = c("firebrick", "orange", "steelblue"),
                        labels = scales::label_pvalue(), 
                        name = "Pr(>F)") +
  coord_flip() +
  labs(x = NULL, y = "F statistic",
       title = "One-way ANOVA: F statistic per categorical feature") +
  theme_minimal(base_size = 9) +
  theme(axis.text.y = element_text(size = 6))
ggsave(here("output", "15_anova_f_statistics.png"), p_anova, width = 9, height = 7, dpi = 120)

# --- 4f. Stepwise path: number of features vs R²
cat("4f. Stepwise path\n")
# Compute R² at each step of the forward selection
path_r2 <- numeric(length(selected_features))
for (k in seq_along(selected_features)) {
  formula_k <- paste("paddy_yield_kg ~", paste(selected_features[1:k], collapse = " + "))
  path_r2[k] <- summary(lm(as.formula(formula_k), data = paddy))$r.squared
}
path_df <- tibble(step = seq_along(path_r2), r2 = path_r2, features = selected_features)
p_path <- ggplot(path_df, aes(x = step, y = r2)) +
  geom_line(colour = "steelblue") +
  geom_point(colour = "steelblue", size = 2) +
  geom_text(aes(label = features), vjust = -1, size = 6) +
  labs(x = "Number of features added", y = "R-squared",
       title = "Forward selection path: R² as features are added") +
  theme_minimal(base_size = 9)
ggsave(here("output", "16_stepwise_path.png"), p_path, width = 9, height = 6, dpi = 120)

# --- 4g. ANOVA summary table
cat("4g. ANOVA summary\n")
cat("\nFeature | F value | Pr(>F)\n")
cat("--------|---------|--------\n")
print(anova_cat[, c("feature", "F value", "Pr(>F)")], n = Inf)

cat("\nDone. Results written to output/ and analysis_summary.txt\n")

# Save a summary text file
summary_lines <- c(
  "Paddy dataset - feature selection, regression, and ANOVA summary",
  paste("Date:", Sys.time()),
  "",
  "=== Feature selection ===",
  paste("Stepwise model selected", length(selected_features), "features:"),
  paste("  ", paste(selected_features, collapse = ", ")),
  "",
  "=== Regression model ===",
  paste("R-squared:", round(model_sum$r.squared, 4)),
  paste("Adj R-squared:", round(model_sum$adj.r.squared, 4)),
  paste("F-statistic:", round(model_sum$statistic, 2), "p =", signif(model_sum$p.value, 3)),
  "",
  "=== Model comparison ===",
  paste("  seedrate only:", round(models_r2$r2[1], 4)),
  paste("  top 3 features:", round(models_r2$r2[2], 4)),
  paste("  stepwise (AIC):", round(models_r2$r2[3], 4)),
  paste("  full (all numeric):", round(models_r2$r2[4], 4)),
  "",
  "=== ANOVA (categorical features vs yield) ===",
  paste("Feature | F value | Pr(>F)"),
  paste("--------|---------|--------")
)
for (i in seq_len(nrow(anova_cat))) {
  summary_lines <- c(summary_lines,
    paste(anova_cat$feature[i], "|", round(anova_cat$`F value`[i], 6), "|", signif(anova_cat$`Pr(>F)`[i], 3))
  )
}
writeLines(summary_lines, here("output", "analysis_summary.txt"))
