# 03_visualizations.R
# Feature visualizations for the UCI Paddy dataset.
# Produces PNGs in output/ and a combined report in output/report.png.
#
# Run: Rscript R/03_visualizations.R   (or `make all`)

library(here)
library(janitor)
library(readr)
library(tidyverse)
library(patchwork)
library(corrplot)

paddy <- readRDS(here("data", "paddy.rds"))
dic <- readRDS(here("data", "data_dictionary.rds"))
dir.create(here("output"), showWarnings = FALSE, recursive = TRUE)

numeric_vars <- dic$variable[dic$type %in% c("integer", "continuous")]
categorical_vars <- dic$variable[dic$type == "categorical"]

# ---------------------------------------------------------------- 1. Overview
cat("1/6 Overview: data dictionary\n")
dictionary_plot <- dic %>%
  mutate(type = str_replace_all(type, "_", " ")) %>%
  mutate(type = str_c(type, " ", if_else(role == "target", "(target)", ""))) %>%
  mutate(role = str_c(role, " ", role)) %>%
  ggplot(aes(x = fct_rev(fct_inorder(variable)), y = type)) +
  geom_tile(fill = "grey92", colour = "white") +
  geom_text(aes(label = role), colour = "grey40") +
  labs(x = NULL, y = NULL,
       title = "Data dictionary (44 features + 1 target)",
       subtitle = "roles and types; categorical wind directions are encoded as codes") +
  theme_minimal(base_size = 8) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "none")

# ---------------------------------------------------------------- 2. Missingness
cat("2/6 Missingness\n")
miss <- data.frame(
  variable = names(paddy),
  missing = vapply(paddy, function(x) sum(is.na(x)), integer(1)),
  stringsAsFactors = FALSE
)
miss <- miss[miss$missing > 0, ]
missing_plot <- ggplot(miss, aes(x = fct_reorder(variable, missing), y = missing)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(x = NULL, y = "missing values",
       title = "Missing values per variable") +
  theme_minimal(base_size = 9)

# ---------------------------------------------------------------- 3. Numeric distributions
cat("3/6 Numeric feature distributions\n")
num_data <- paddy %>% select(all_of(numeric_vars))
# panel of histograms
dist_plots <- map_dfr(names(num_data), function(v) {
  tibble(
    variable = v,
    value = num_data[[v]],
    fill = "steelblue"
  )
}) %>%
  ggplot(aes(value)) +
  geom_histogram(fill = "steelblue", bins = 30) +
  facet_wrap(~ variable, scales = "free_x", ncol = 5) +
  labs(x = NULL, y = "count",
       title = "Histograms of numeric features") +
  theme_minimal(base_size = 7) +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.text = element_text(size = 6))
ggsave(here("output", "01_numeric_histograms.png"), dist_plots,
       width = 18, height = 26, dpi = 120)

# ---------------------------------------------------------------- 4. Categorical bar charts
cat("4/6 Categorical feature frequencies\n")
cat_data <- paddy %>% select(all_of(categorical_vars))
cat_plot <- map_dfr(names(cat_data), function(v) {
  tibble(variable = v,
         value = names(sort(table(cat_data[[v]]), decreasing = TRUE)),
         count = as.integer(sort(table(cat_data[[v]]), decreasing = TRUE)))
}) %>%
  ggplot(aes(x = fct_reorder(value, count), y = count, fill = variable)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ variable, scales = "free_x", ncol = 3) +
  coord_flip() +
  labs(x = NULL, y = "count", title = "Bar charts of categorical features") +
  theme_minimal(base_size = 8) +
  theme(axis.text.y = element_blank())
ggsave(here("output", "02_categorical_bar_charts.png"), cat_plot,
       width = 14, height = 12, dpi = 120)

# ---------------------------------------------------------------- 5. Correlation heatmap
cat("5/6 Correlation heatmap\n")
num_df <- paddy %>% select(all_of(numeric_vars))
cor_mat <- cor(num_df, use = "pairwise.complete.obs")
corr_plot <- corrplot(cor_mat, method = "color", type = "lower",
                      tl.col = "grey30", tl.srt = 90,
                      title = "Correlation matrix of numeric features",
                      mar = c(0, 0, 2, 0))
png(here("output", "03_correlation_heatmap.png"), 1200, 1200, res = 120)
corrplot(cor_mat, method = "color", type = "lower",
         tl.col = "grey30", tl.srt = 90,
         title = "Correlation matrix of numeric features",
         mar = c(0, 0, 2, 0))
dev.off()

# ---------------------------------------------------------------- 6. Yield vs features
cat("6/6 Yield vs features\n")
target_corr <- cor(num_df, paddy$paddy_yield_kg, use = "pairwise.complete.obs")[, "paddy_yield_kg"]
top_vars <- names(sort(abs(target_corr), decreasing = TRUE))[1:8]

scatter_plots <- map_dfr(top_vars, function(v) {
  tibble(x = num_df[[v]], xvar = v)
}) %>%
  ggplot(aes(x = x, y = paddy$paddy_yield_kg)) +
  geom_point(alpha = 0.25, colour = "steelblue", size = 0.8) +
  facet_wrap(~ xvar, scales = "free_x", ncol = 4) +
  labs(x = NULL, y = "Paddy yield (Kg)",
       title = "Paddy yield against the 8 most correlated numeric features") +
  theme_minimal(base_size = 8) +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.text = element_text(size = 6))
ggsave(here("output", "04_yield_vs_numeric.png"), scatter_plots,
       width = 16, height = 14, dpi = 120)

# Yield by categorical variables (boxplots)
yield_cat <- map_dfr(names(cat_data), function(v) {
  tibble(variable = v, value = cat_data[[v]], yield = paddy$paddy_yield_kg)
}) %>%
  ggplot(aes(x = fct_reorder(value, yield, .fun = median), y = yield, fill = variable)) +
  geom_boxplot(show.legend = FALSE) +
  coord_flip() +
  labs(x = NULL, y = "Paddy yield (Kg)",
       title = "Paddy yield by categorical features (median line)") +
  theme_minimal(base_size = 8) +
  theme(axis.text.y = element_blank())
cat("Done writing PNGs to output/\n")
