# Methods-to-code map

This file maps manuscript methods to the current repository structure. It is written for the **current multi-module repository layout** and should be updated if the repository is later consolidated into a single unified pipeline.

## 1. Study cohorts and data sources

### UK Biobank (UKB)
- Primary module: `ukb-aortic-analysis/`
- Relevant components:
  - `code/01_data_preparation/`
  - `code/02_outcome_construction/`
  - `docs/`

### China Kadoorie Biobank (CKB)
- Primary module: `ckb-aortic-disease-code/`
- Relevant components:
  - scripts for event and exposure preparation
  - scripts for outcome construction
  - scripts for Cox analyses and multimorbidity analyses

## 2. Assessment of chronic conditions and aortic outcomes

### UKB
- Use `ukb-aortic-analysis/code/01_data_preparation/` for exposure/covariate derivation
- Use `ukb-aortic-analysis/code/02_outcome_construction/` for aortic disease definitions

### CKB
- Use `ckb-aortic-disease-code/` scripts that define chronic conditions and aortic outcomes in the CKB framework

## 3. Primary observational association analyses

### UKB
- Primary location: `ukb-aortic-analysis/code/03_primary_analysis/`
- Expected outputs:
  - Cox model estimates for overall aortic disease
  - subtype-specific hazard ratios
  - multimorbidity analyses

### CKB
- Primary location: `ckb-aortic-disease-code/` analytical scripts for Cox models and multimorbidity analyses
- Purpose:
  - external validation of the observational pattern reported in UKB

## 4. Population attributable fraction (PAF) analyses

### Manuscript scope
The revised manuscript describes PAF analyses in **UKB only**.

### Code location
- Primary location: `ukb-aortic-analysis/code/03_primary_analysis/`

### Important cleanup action
If `ckb-aortic-disease-code/` contains a PAF script, this should either:
- be removed from the public repository if it was not used for the manuscript, or
- be clearly labeled as development code that was not part of the final reported analyses.

## 5. Mendelian randomization (MR) analyses

### Code location
- Primary module: `mr-gwas-pipeline-code/`

### Manuscript alignment
This module should correspond to:
- instrument selection from GWAS summary statistics
- LD clumping
- harmonization
- IVW as primary analysis
- MR-Egger, weighted median, simple mode, and weighted mode as sensitivity analyses
- cross-dataset analyses where exposure and outcome summary statistics are derived from different sources

### Recommended action
The MR README should describe the **actual manuscript thresholds and rules**, not a generic or cleaned-template workflow.

## 6. Machine learning model establishment and feature selection

### Preferred primary location
- `ukb-aortic-analysis/code/05_prediction_model/`

### Secondary/duplicate location
- `prediction-model-xgboost-code/`

### Recommended action
Choose **one** of the above as the manuscript-primary source.
- If `ukb-aortic-analysis/code/05_prediction_model/` generated the final figures/tables, keep that as the primary source.
- Archive or remove `prediction-model-xgboost-code/`, or add a clear archival warning.

### Manuscript alignment
The primary prediction module should cover:
- candidate predictors in UKB
- complete-case selection
- random split into training and test sets
- ranking by XGBoost gain
- retention of top 10 predictors for each outcome
- final model fitting
- ROC-AUC evaluation
- SHAP-based global and individual interpretability

## 7. Stratified and sensitivity analyses

### UKB sex-stratified analyses and interaction tests
- Primary location: `ukb-aortic-analysis/code/04_sensitivity_and_subgroup/`

### Competing-risk analyses
- Primary location: `ukb-aortic-analysis/code/04_sensitivity_and_subgroup/`
- Should document use of `riskRegression::CSC`

### Sex misclassification sensitivity analyses
- Primary location: `ukb-aortic-analysis/code/04_sensitivity_and_subgroup/`
- Should explicitly state whether genetically inferred sex was used in the rerun

## 8. Visualization and manuscript figures

### Likely visualization location
- `ukb-aortic-analysis/code/06_visualization/`
- figure-generation scripts in the MR and prediction modules as applicable

### Important manuscript consistency check
Please verify the final figure numbering. In the current manuscript materials, **Figure 3 appears to be referenced for both PAF and MR-related content**, which should be corrected before submission.
