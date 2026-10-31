# Makefile for the paddy R project
# Usage:
#   make setup         install dependencies (R + packages; installs R if missing)
#   make data          download + clean the dataset (scripts 01)
#   make explore       textual summary (script 02)
#   make viz           generate visualizations (scripts 03 + 04)
#   make regression    feature selection, regression, ANOVA (script 05)
#   make all           data + explore + viz + regression

RSCRIPT ?= Rscript

.PHONY: setup data explore viz regression all clean

# `make setup` also installs R when it is missing:
#   macOS (Homebrew)  -> brew install r
#   Linux (apt)       -> sudo apt-get install -y r-base
# Afterwards Rscript is looked up in the usual install locations, because
# Homebrew / apt may install it outside the PATH make inherits.
setup:
	@test -f setup.R || (echo "Run: curl -O setup.R" && exit 1)
	@if command -v Rscript >/dev/null 2>&1; then \
		Rscript setup.R; \
	else \
		echo "Rscript not found - installing R..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew install r; \
		elif command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get install -y r-base; \
		else \
			echo "Please install R >= 4.1 manually, then re-run: make setup"; \
			exit 1; \
		fi; \
		Rscript="$$(command -v Rscript || ls /opt/homebrew/bin/Rscript /usr/local/bin/Rscript /usr/bin/Rscript 2>/dev/null | head -1)"; \
		if [ -z "$$Rscript" ]; then \
			echo "Rscript still not found - add it to your PATH, then re-run: make setup"; \
			exit 1; \
		fi; \
		"$$Rscript" setup.R; \
	fi

data:
	$(RSCRIPT) R/01_load_data.R

explore:
	$(RSCRIPT) R/02_summary.R

viz:
	$(RSCRIPT) R/03_visualizations.R

regression:
	$(RSCRIPT) R/05_regression_analysis.R

all: setup data explore viz regression

clean:
	rm -rf output/*
	rm -f data/paddy.rds data/data_dictionary.rds
