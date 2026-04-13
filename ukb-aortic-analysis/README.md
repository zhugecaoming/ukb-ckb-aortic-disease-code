# UKB Aortic Disease Analysis Code

This repository organizes the UK Biobank analysis code for the aortic disease project into one uploadable GitHub repository. The code now directly integrates the original analytical logic into the main scripts rather than keeping the original files as a separate archive.

## Included analyses

- baseline preprocessing and covariate derivation
- ICD-10 and OPCS-based construction of composite and subtype aortic disease outcomes
- chronic disease table construction for multimorbidity exposures
- main Cox survival analyses for composite and subtype outcomes
- population attributable fraction (PAF) analyses
- competing risk analysis using `riskRegression::CSC`
- sex subgroup and interaction forest plots
- XGBoost prediction modeling with ROC/AUC and SHAP outputs
- presentation-ready custom forest plots

## Repository structure

- `code/00_setup/`: shared helper functions and package checks
- `code/01_data_preparation/`: baseline data preprocessing
- `code/02_outcome_construction/`: UKB outcome and disease construction
- `code/03_primary_analysis/`: main survival analyses and PAF tables
- `code/04_sensitivity_and_subgroup/`: competing risk and sex subgroup analyses
- `code/05_prediction_model/`: XGBoost prediction workflow
- `code/06_visualization/`: publication-style forest plots
- `config/`: local path configuration template
- `data-raw/`: placeholder only; raw UKB data are not included
- `results/`: exported tables and figures
- `models/`: saved model objects

## Data availability

This repository does **not** include raw UK Biobank participant-level data. The analysis requires approved UK Biobank access. Replace the local paths in `config/config.yml` with your own approved data locations.

## How to use

1. Copy `config/config_template.yml` to `config/config.yml`
2. Update all paths in `config/config.yml`
3. Run `source("run_all.R")` or run scripts step by step
4. Review output files under `results/` and `models/`

## Notes

- The code keeps the original project logic but removes hard-coded Windows desktop paths from the public version.
- Some source scripts reused the same preprocessing blocks. Those shared steps are now centralized in helper functions.
- Before public release, run the full pipeline locally and confirm variable names, column positions, and date parsing against your secured UKB extracts.

## Manuscript-ready code availability text

> The analysis code is available in this GitHub repository. Because the study uses UK Biobank participant-level data, the raw data are not publicly distributed with the code and must be accessed through approved UK Biobank procedures.
