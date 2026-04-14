# MR GWAS Pipeline Code

This repository contains a cleaned and shareable version of an R-based Mendelian randomization (MR) workflow for:

1. reading exposure GWAS summary statistics,
2. filtering variants by significance,
3. LD clumping with PLINK,
4. reading outcome GWAS summary statistics,
5. harmonising exposure and outcome data,
6. running MR analyses and sensitivity analyses,
7. exporting tables and figures.

## Important note on data access

This repository **does not include any raw or individual-level data**.  
Please place your own GWAS summary statistics in the input folders after obtaining them through the appropriate access procedures.

## Repository structure

- `run_all.R`: main entry point
- `config/config_template.yml`: editable path and parameter template
- `code/00_setup_packages.R`: package checks and setup
- `code/01_prepare_exposures.R`: read exposure GWAS files and generate clumped instruments
- `code/02_run_mr_batch.R`: merge, harmonise, MR, plots, and sensitivity analyses
- `code/helpers.R`: shared helper functions
- `data-raw/README_data.md`: what to place in the data folders
- `results/`: output directory
- `docs/repository_notes.md`: project notes and usage suggestions

## Required software

- R (recommended: 4.3+)
- PLINK
- An LD reference panel compatible with your ancestry and clumping design

## Required R packages

The code expects these packages:

- `TwoSampleMR`
- `ieugwasr`
- `dplyr`
- `data.table`
- `ggplot2`
- `yaml`
- `readr`
- `tibble`

## Before running

1. Copy `config/config_template.yml` to `config/config.yml`
2. Edit the paths in `config/config.yml`
3. Put your exposure GWAS files into the exposure input folder
4. Put your outcome GWAS files into the outcome input folder
5. Confirm the column names in the config match your data

## Typical workflow

Run:

```r
source("run_all.R")
```

This will:

- prepare exposure instruments,
- perform LD clumping,
- read outcome files,
- harmonise datasets,
- run MR analyses,
- save tables and figures into `results/`.
