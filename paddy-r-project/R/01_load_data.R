# 01_load_data.R
# Load the UCI Paddy dataset, clean column names and save a tidy tibble.
# Run: Rscript R/01_load_data.R

library(janitor)
library(readr)
library(tidyverse)

DATA_PATH <- here::here("data", "paddydataset.csv")
OUTPUT_PATH <- here::here("data", "paddy.rds")

# --- Load ---------------------------------------------------------------
paddy <- read_csv(DATA_PATH, na = c("", "NA", "NaN"), skip_empty_rows = TRUE)

# --- Clean column names ---------------------------------------------------
# 1) let janitor produce its snake_case names from the raw headers
new_names <- janitor::make_clean_names(names(paddy))
# 2) then apply a curated map to make them readable
pretty_map <- c(
  "seedrate_in_kg"           = "seedrate_kg",
  "lp_mainfield_in_tonnes"   = "lp_mainfield_tonnes",
  "nursery_area_in_cents"    = "nursery_area_cents",
  "lp_nurseryarea_in_tonnes" = "lp_nurseryarea_tonnes",
  "pest_60day_in_ml"         = "pest_60day_ml",
  "trash_in_bundles"         = "trash_bundles",
  "paddy_yield_in_kg"        = "paddy_yield_kg",
  "urea_40days"              = "urea_40days_kg",
  "potassh_50days"           = "potassh_50days_kg",
  "micronutrients_70days"    = "micronutrients_70days_kg",
  "x30d_rain_in_mm"          = "rain_30d_mm",
  "x30dai_in_mm"             = "ai_30d_days",
  "x30_50d_rain_in_mm"       = "rain_30_50d_mm",
  "x30_50dai_in_mm"          = "ai_30_50d_days",
  "x51_70d_rain_in_mm"       = "rain_51_70d_mm",
  "x51_70ai_in_mm"           = "ai_51_70d_days",
  "x71_105d_rain_in_mm"      = "rain_71_105d_mm",
  "x71_105dai_in_mm"         = "ai_71_105d_days",
  "min_temp_d1_d30"          = "min_temp_d1_d30_c",
  "max_temp_d1_d30"          = "max_temp_d1_d30_c",
  "min_temp_d31_d60"         = "min_temp_d31_d60_c",
  "max_temp_d31_d60"         = "max_temp_d31_d60_c",
  "min_temp_d61_d90"         = "min_temp_d61_d90_c",
  "max_temp_d61_d90"         = "max_temp_d61_d90_c",
  "min_temp_d91_d120"        = "min_temp_d91_d120_c",
  "max_temp_d91_d120"        = "max_temp_d91_d120_c",
  "inst_wind_speed_d1_d30_in_knots"  = "inst_wind_speed_d1_d30_knots",
  "inst_wind_speed_d31_d60_in_knots" = "inst_wind_speed_d31_d60_knots",
  "inst_wind_speed_d61_d90_in_knots" = "inst_wind_speed_d61_d90_knots",
  "inst_wind_speed_d91_d120_in_knots" = "inst_wind_speed_d91_d120_knots"
)
names(paddy) <- pretty_map[new_names]
# columns whose cleaned name is already fine keep it (avoid NA names)
unmatched <- is.na(pretty_map[new_names])
if (any(unmatched)) names(paddy)[unmatched] <- new_names[unmatched]

# Record the data dictionary: variable, role, type, description
data_dictionary <- tribble(
  ~variable, ~role,   ~type,      ~description,
  "hectares",              "feature", "integer", "Size of the agricultural block, in hectares",
  "agriblock",             "feature", "categorical", "The agriblock/location code",
  "variety",               "feature", "categorical", "Paddy variety grown (e.g. CO_43, ponmani)",
  "soil_types",            "feature", "categorical", "Soil type of the block (e.g. alluvial, clay)",
  "seedrate_kg",           "feature", "integer", "Seed rate, in kg",
  "lp_mainfield_tonnes",   "feature", "continuous", "Main field yield, in tonnes",
  "nursery",               "feature", "categorical", "Type of nursery (dry, wet, ...)",
  "nursery_area_cents",    "feature", "integer", "Nursery area, in cents",
  "lp_nurseryarea_tonnes", "feature", "continuous", "Manure used for land preparation, in tonnes",
  "dap_20days",            "feature", "integer", "DAP sowed for the first 20 days",
  "weed28d_thiobencarb",   "feature", "continuous", "Weed control (thiobencarb) at 28 days, ppm",
  "urea_40days_kg",        "feature", "continuous", "Urea applied at 40 days, kg",
  "potassh_50days_kg",     "feature", "continuous", "Potash applied at 50 days, kg",
  "micronutrients_70days_kg", "feature", "continuous", "Micronutrients applied at 70 days, kg",
  "pest_60day_ml",         "feature", "continuous", "Pest control at 60 days, ml",
  "rain_30d_mm",           "feature", "continuous", "Rainfall, days 1-30, mm",
  "ai_30d_days",           "feature", "continuous", "Days affected by irrigation, days 1-30",
  "rain_30_50d_mm",        "feature", "continuous", "Rainfall, days 30-50, mm",
  "ai_30_50d_days",        "feature", "continuous", "Days affected by irrigation, days 30-50",
  "rain_51_70d_mm",        "feature", "continuous", "Rainfall, days 51-70, mm",
  "ai_51_70d_days",        "feature", "continuous", "Days affected by irrigation, days 51-70",
  "rain_71_105d_mm",       "feature", "continuous", "Rainfall, days 71-105, mm",
  "ai_71_105d_days",       "feature", "continuous", "Days affected by irrigation, days 71-105",
  "min_temp_d1_d30_c",     "feature", "continuous", "Minimum temperature, days 1-30, deg C",
  "max_temp_d1_d30_c",     "feature", "continuous", "Maximum temperature, days 1-30, deg C",
  "min_temp_d31_d60_c",    "feature", "continuous", "Minimum temperature, days 31-60, deg C",
  "max_temp_d31_d60_c",    "feature", "continuous", "Maximum temperature, days 31-60, deg C",
  "min_temp_d61_d90_c",    "feature", "continuous", "Minimum temperature, days 61-90, deg C",
  "max_temp_d61_d90_c",    "feature", "continuous", "Maximum temperature, days 61-90, deg C",
  "min_temp_d91_d120_c",   "feature", "continuous", "Minimum temperature, days 91-120, deg C",
  "max_temp_d91_d120_c",   "feature", "continuous", "Maximum temperature, days 91-120, deg C",
  "inst_wind_speed_d1_d30_knots",     "feature", "continuous", "Wind speed, days 1-30, knots",
  "inst_wind_speed_d31_d60_knots",    "feature", "continuous", "Wind speed, days 31-60, knots",
  "inst_wind_speed_d61_d90_knots",    "feature", "continuous", "Wind speed, days 61-90, knots",
  "inst_wind_speed_d91_d120_knots",   "feature", "continuous", "Wind speed, days 91-120, knots",
  "wind_direction_d1_d30",            "feature", "categorical", "Wind direction, days 1-30 (SW, W, NNW, ...)",
  "wind_direction_d31_d60",           "feature", "categorical", "Wind direction, days 31-60",
  "wind_direction_d61_d90",           "feature", "categorical", "Wind direction, days 61-90",
  "wind_direction_d91_d120",          "feature", "categorical", "Wind direction, days 91-120",
  "relative_humidity_d1_d30",         "feature", "continuous", "Relative humidity, days 1-30, %",
  "relative_humidity_d31_d60",        "feature", "continuous", "Relative humidity, days 31-60, %",
  "relative_humidity_d61_d90",        "feature", "continuous", "Relative humidity, days 61-90, %",
  "relative_humidity_d91_d120",       "feature", "continuous", "Relative humidity, days 91-120, %",
  "trash_bundles",                    "feature", "continuous", "Trash, in bundles",
  "paddy_yield_kg",                   "target",  "continuous", "Paddy yield, in kg"
)

# Save a tidy copy for the other scripts
saveRDS(paddy, OUTPUT_PATH)
saveRDS(data_dictionary, here::here("data", "data_dictionary.rds"))

cat("Loaded", nrow(paddy), "rows x", ncol(paddy), "columns ->", OUTPUT_PATH, "\n")
