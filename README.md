# Chronic Conditions and Aortic Disease Risk: Code Repository

This repository contains the analysis code supporting the manuscript **“Chronic Conditions and Aortic Disease Risk: A Prospective Cohort Study with Predictive and Etiological Analyses.”** The study integrates four major analytical components:

1. **Prospective observational analyses in UK Biobank (UKB)**
2. **External validation analyses in China Kadoorie Biobank (CKB)**
3. **Mendelian randomization (MR) analyses using FinnGen and UKB summary statistics**
4. **Machine-learning prediction models in UKB using XGBoost and SHAP**

The repository is intended to support transparency and reproducibility of the manuscript-level workflow. Raw participant-level UKB and CKB data are **not** distributed in this repository because access is controlled by the respective data custodians.

## Repository modules

| Directory | Purpose | Main manuscript content |
|---|---|---|
| `ukb-aortic-disease-code/` | UKB cohort preprocessing, outcome construction, Cox models, PAF, subgroup and sensitivity analyses, visualization, and the integrated UKB prediction workflow | Main epidemiological analyses in UKB; PAF; sex interaction; competing-risk sensitivity analyses; prediction modeling |
| `ckb-aortic-disease-code/` | CKB cohort preprocessing and Cox-based external validation analyses | External validation of observational associations in CKB |
| `mr-gwas-pipeline-code/` | Summary-statistic MR workflow | Genetic support analyses using FinnGen and UKB |
| `prediction-model-xgboost-code/` | Standalone XGBoost workflow | Machine Leaning |
