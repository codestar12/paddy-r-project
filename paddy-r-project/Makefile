# Makefile for the paddy R project
# Usage:
#   make setup     install dependencies (R + packages)
#   make data      download + clean the dataset (scripts 01)
#   make explore   textual summary (script 02)
#   make viz       generate visualizations (script 03)
#   make all       data + explore + viz

RSCRIPT ?= Rscript

.PHONY: setup data explore viz all clean

setup:
	@test -f setup.R || (echo "Run: curl -O setup.R" && exit 1)
	$(RSCRIPT) setup.R

data:
	$(RSCRIPT) R/01_load_data.R

explore:
	$(RSCRIPT) R/02_summary.R

viz:
	$(RSCRIPT) R/03_visualizations.R

all: data explore viz

clean:
	rm -rf output/*
	rm -f data/paddy.rds data/data_dictionary.rds
