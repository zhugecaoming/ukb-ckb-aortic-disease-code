# XGBoost Prediction Model Pipeline

This repository contains a cleaned and shareable version of an R-based prediction modeling workflow using XGBoost for binary outcome prediction, ROC/AUC evaluation, and SHAP-based model interpretation.

## Overview

The original script trains XGBoost models for a set of phenotypes, evaluates model performance in training and test sets, and exports:

- ROC plots
- model performance tables
- SHAP waterfall / force / beeswarm / importance plots
- fitted model objects

## Repository structure

```text
prediction-model-xgboost-code/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ run_all.R
├─ config/
│  └─ config_template.yml
├─ code/
│  ├─ 00_setup_packages.R
│  ├─ 01_prepare_data.R
│  ├─ 02_train_xgboost_models.R
│  └─ helpers.R
├─ data-raw/
│  └─ README_data.md
├─ docs/
│  └─ repository_notes.md
├─ results/
│  └─ .gitkeep
└─ models/
   └─ .gitkeep
```

## Data availability

The original individual-level data used for model development are not distributed in this repository. If the source dataset comes from a restricted-access resource, users must obtain access through the corresponding data application procedures.

## Expected input objects

The original script depends on objects such as:

- `df_filtered`
- `data1`
- `M.names1`
- `X.names1`
- `y.names`

Before running the cleaned pipeline, you should prepare a project-specific input file and adapt the configuration file to match your own variable names.

## Main outputs

The pipeline saves results into `results/` and model objects into `models/`:

- `performance_train_<outcome>.csv`
- `performance_test_<outcome>.csv`
- `<outcome>_train_roc.pdf`
- `<outcome>_test_roc.pdf`
- `<outcome>_train_import.pdf`
- `<outcome>_train_bee.tif`
- fitted XGBoost model objects as `.rds`

## Software environment

Recommended R packages include:

- xgboost
- pROC
- ROCit
- caret
- shapviz
- ggplot2
- tibble
- dplyr
- yaml

## How to run

1. Copy `config/config_template.yml` to `config/config.yml`
2. Update the paths and variable names in `config/config.yml`
3. Prepare your input `.RData`, `.rds`, or `.csv` data object(s)
4. Run:

```r
source("run_all.R")
```
