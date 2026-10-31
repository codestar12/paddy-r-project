# Additional analysis visualizations for the UCI Paddy dataset.
# Produces PNGs in output/.
#
# Run: Rscript R/04_analysis_visualizations.R   (or `make all`)

library(here)
library(janitor)
library(tidyverse)
library(patchwork)

paddy <- readRDS(here("data", "paddy.rds"))
dic <- readRDS(here("data", "data_dictionary.rds"))
dir.create(here("output"), showWarnings = FALSE, recursive = TRUE)

numeric_vars <- dic$variable[dic$type %in% c("integer", "continuous")]
categorical_vars <- dic$variable[dic$type == "categorical"]

# ---------------------------------------------------------------- 1. Yield vs rainfall
cat("1/5 Yield vs rainfall\n")
p1 <- ggplot(paddy, aes(x = rain_30d_mm, y = paddy_yield_kg)) +
  geom_point(alpha = 0.3, colour = "steelblue", size = 0.8) +
  geom_smooth(method = "lm", colour = "darkred", se = TRUE) +
  labs(x = "30-day rainfall (mm)", y = "Paddy yield (Kg)",
       title = "Paddy yield vs 30-day rainfall") +
  theme_minimal(base_size = 9)
ggsave(here("output", "06_yield_vs_rainfall.png"), p1, width = 8, height = 6, dpi = 120)

# ---------------------------------------------------------------- 2. Yield vs seed rate
cat("2/5 Yield vs seed rate\n")
p2 <- ggplot(paddy, aes(x = seedrate_kg, y = paddy_yield_kg)) +
  geom_point(alpha = 0.3, colour = "darkgreen", size = 0.8) +
  geom_smooth(method = "lm", colour = "darkred", se = TRUE) +
  labs(x = "Seed rate (Kg)", y = "Paddy yield (Kg)",
       title = "Paddy yield vs seed rate") +
  theme_minimal(base_size = 9)
ggsave(here("output", "07_yield_vs_seedrate.png"), p2, width = 8, height = 6, dpi = 120)

# ---------------------------------------------------------------- 3. Yield by variety
cat("3/5 Yield by variety\n")
p3 <- ggplot(paddy, aes(x = fct_infreq(variety), y = paddy_yield_kg, fill = variety)) +
  geom_boxplot(show.legend = FALSE) +
  labs(x = "Variety", y = "Paddy yield (Kg)",
       title = "Paddy yield by variety") +
  theme_minimal(base_size = 9) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7))
ggsave(here("output", "08_yield_by_variety.png"), p3, width = 10, height = 6, dpi = 120)

# ---------------------------------------------------------------- 4. Yield by soil type
cat("4/5 Yield by soil type\n")
p4 <- ggplot(paddy, aes(x = fct_infreq(soil_types), y = paddy_yield_kg, fill = soil_types)) +
  geom_boxplot(show.legend = FALSE) +
  labs(x = "Soil type", y = "Paddy yield (Kg)",
       title = "Paddy yield by soil type") +
  theme_minimal(base_size = 9) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 7))
ggsave(here("output", "09_yield_by_soil_type.png"), p4, width = 8, height = 6, dpi = 120)

# ---------------------------------------------------------------- 5. Top 15 features by correlation with yield
cat("5/5 Top 15 features by absolute correlation with yield\n")
num_df <- paddy %>% select(all_of(numeric_vars))
target_corr <- sapply(num_df, function(x) cor(x, paddy$paddy_yield_kg, use = "pairwise.complete.obs"))
corr_df <- tibble(feature = names(target_corr), corr = target_corr) %>%
  mutate(abs_corr = abs(corr),
         hjust = ifelse(corr >= 0, 1.01, -0.01)) %>%
  arrange(desc(abs_corr)) %>%
  slice_head(n = 15)
p5 <- ggplot(corr_df, aes(x = reorder(feature, abs_corr), y = corr)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = round(corr, 2), hjust = hjust), size = 3) +
  labs(x = NULL, y = "Correlation with yield",
       title = "Top 15 features by absolute correlation with paddy yield") +
  theme_minimal(base_size = 9) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 7))
ggsave(here("output", "10_top_features_by_correlation.png"), p5, width = 10, height = 8, dpi = 120)

cat("Done writing PNGs to output/\n")
