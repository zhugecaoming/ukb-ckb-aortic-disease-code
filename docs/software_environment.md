# Software environment and reproducibility note

## Goal

This document is meant to harmonize software-version reporting across the repository and manuscript.

## Current issue to resolve

The current repository materials indicate different software versions across modules. Before public release, these should be reconciled or explicitly explained.

## Recommended wording for the manuscript and repository

### Master statement

> Statistical analyses were conducted primarily in R (version 4.5.1). The Mendelian randomization workflow was developed and tested using R 4.3.1 with TwoSampleMR and ieugwasr, and the full public repository release documents package versions and execution environment for each module.

## Module-level environment table

| Module | Recommended version note | Key packages / tools | Action needed |
|---|---|---|---|
| `ukb-aortic-analysis/` | R 4.5.1 | survival, riskRegression, dplyr, ggplot2, etc. | Export session info or lockfile |
| `ckb-aortic-disease-code/` | Prefer harmonization with R 4.5.1 if possible | survival, dplyr, data.table, lubridate | Update README if no real incompatibility exists |
| `mr-gwas-pipeline-code/` | R 4.3.1 or clearly documented tested version | TwoSampleMR, ieugwasr, PLINK | Document exact package versions and PLINK version |
| Primary prediction module | R 4.5.1 | xgboost, pROC, shapviz, caret | Save package versions and seed settings |

## Strongly recommended additions

Add one or more of the following:
- `renv.lock`
- `sessionInfo.txt` or module-specific session info files
- PLINK version note
- seed-setting note for train/test split and model fitting

## Minimum reproducibility checklist

- remove absolute file-system paths
- document local input folder expectations
- document software versions
- document random seed(s)
- document output file names for main figures/tables
