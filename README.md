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
| `ukb-aortic-analysis/` | UKB cohort preprocessing, outcome construction, Cox models, PAF, subgroup and sensitivity analyses, visualization, and the integrated UKB prediction workflow | Main epidemiological analyses in UKB; PAF; sex interaction; competing-risk sensitivity analyses; prediction modeling |
| `ckb-aortic-disease-code/` | CKB cohort preprocessing and Cox-based external validation analyses | External validation of observational associations in CKB |
| `mr-gwas-pipeline-code/` | Summary-statistic MR workflow | Genetic support analyses using FinnGen and UKB |
| `prediction-model-xgboost-code/` | Standalone XGBoost workflow | **Recommended action:** archive or remove after confirming that `ukb-aortic-analysis/code/05_prediction_model/` is the primary manuscript pipeline |

## Recommended interpretation of this repository

At present, the repository contains both an **integrated prediction workflow** inside `ukb-aortic-analysis/` and a **standalone prediction module** in `prediction-model-xgboost-code/`. For manuscript clarity, only **one** prediction entry point should remain as the primary source for the final figures and tables. If the integrated UKB workflow is the one used for the manuscript, the standalone module should be either:

- removed from the public repository, or
- clearly labeled as an archival/development version that is **not** the primary source for manuscript figures.

## Mapping from Methods to code

A concise mapping from manuscript sections to repository modules is provided in:

- `docs/methods_to_code_map.md`
- `docs/figures_tables_map.md`

These files should be kept consistent with the final revised manuscript.

## Data access and restrictions

This repository does **not** include:

- raw UK Biobank participant-level data
- raw China Kadoorie Biobank participant-level data
- restricted summary data that cannot be redistributed under source-specific terms

Please see `docs/data_access.md` for a manuscript-ready description of what is and is not shared.

## Suggested workflow for reviewers or readers

### UKB observational analyses

Use the scripts in `ukb-aortic-analysis/` for:

- baseline data preprocessing
- chronic condition construction
- aortic outcome derivation
- Cox proportional hazards analyses
- multimorbidity analyses
- PAF estimation in UKB
- sex-stratified and sensitivity analyses
- integrated prediction modeling

### CKB validation analyses

Use the scripts in `ckb-aortic-disease-code/` for:

- harmonized chronic condition and aortic outcome analyses in CKB
- external validation of the observational association pattern

### MR analyses

Use `mr-gwas-pipeline-code/` for:

- genetic instrument selection
- LD clumping
- harmonization of exposure and outcome summary statistics
- IVW and sensitivity MR methods
- export of MR tables and figures

### Machine-learning prediction

Use **one designated primary module only** for final manuscript regeneration.

## Reproducibility notes

- The manuscript-wide statistical analyses should be documented under a single software note in `docs/software_environment.md`.
- The MR module currently reflects a somewhat different R version recommendation from the cohort-analysis modules; these should be reconciled in the final public release.
- All local absolute paths should be removed before final submission.
- A repository release with a permanent identifier (for example, Zenodo) is strongly recommended before publication.

## Recommended pre-submission cleanup

Before resubmission, please complete the checklist in:

- `docs/repository_cleanup_checklist.md`

## Suggested root-level files to add

This repository should include the following root-level files before final submission:

- `README.md` (this file)
- `LICENSE`
- `CITATION.cff`
- `.gitignore`
- release tag for the revision used in the paper

## Citation

Please update `CITATION.cff` with the final author list, DOI (if available), and release tag corresponding to the version cited in the manuscript.
