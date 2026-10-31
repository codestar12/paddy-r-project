# paddy-r-project

A starter R project for the [UCI Paddy dataset](https://archive.ics.uci.edu/dataset/1186/paddy+dataset)
(2,789 observations, 44 features + a `paddy_yield` target, from a study of rice
growth factors in the Cuddalore district of Tamil Nadu, India).

## Quick start

```bash
# 1. make setup (installs R >= 4.1 if missing, then the R packages)

# 2. download the dataset, clean names and save data/paddy.rds
make data

# 3. textual summary -> prints structure, missingness and yield correlations
make explore

# 4. visualizations -> output/01–05 PNGs
make viz

# 5. analysis visualizations -> output/06–10 PNGs (yield vs rainfall, seed rate, variety, soil type, top features)
make analysis

# or everything at once
make all
```

## Project structure

```
├── data/                      # raw CSV (paddydataset.csv) + cleaned CSV and RDS
├── R/                         # 01_load_data.R, 02_summary.R, 03_visualizations.R, 04_analysis_visualizations.R
├── output/                    # generated plots and reports
├── setup.R                    # installs R + required packages
└── Makefile                   # one-command workflow
```

## The dataset

| Variable | Role | Type |
|---|---|---|
| hectares, agriblock, variety, soil_types, seedrate_kg, lp_mainfield_tonnes, nursery, nursery_area_cents, lp_nurseryarea_tonnes, dap_20days | feature | integer / categorical / continuous |
| weed28d_thiobencarb … trash_bundles (weather/chemical/yield features) | feature | continuous |
| paddy_yield_kg | target | continuous (Kg) |

See `data/data_dictionary.rds` for the full variable-by-variable table.

## Visualizations produced (`output/`)

1. `01_numeric_histograms.png` — distributions of all 32 numeric features
2. `02_categorical_bar_charts.png` — frequencies of the categorical features
3. `03_correlation_heatmap.png` — pairwise correlations between numeric features
4. `04_yield_vs_numeric.png` — paddy yield against the 8 most correlated features
5. `05_yield_by_categorical.png` — yield by categorical features (boxplots)
6. `06_yield_vs_rainfall.png` — yield vs 30-day rainfall, with a linear trend
7. `07_yield_vs_seedrate.png` — yield vs seed rate, with a linear trend
8. `08_yield_by_variety.png` — yield by variety (boxplots)
9. `09_yield_by_soil_type.png` — yield by soil type (boxplots)
10. `10_top_features_by_correlation.png` — top 15 features by absolute correlation with yield

## Suggested next steps

- Load the dataset into a model — e.g. `parsnip` + `recipes` to predict `paddy_yield`
  from the fertilizer and weather features, and check which variables matter most
- The dataset is a synthetic field trial, so strong input–output correlations do not
  imply causation; a regression model is the place to start before drawing conclusions
- Try a glass-box model (e.g. `rpart` or `earth`) and compare against a linear model
  to see which features a model actually uses
