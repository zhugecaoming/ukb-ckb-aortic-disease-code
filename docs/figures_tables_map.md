# Figures and tables map

This file is meant for manuscript-facing reproducibility. Replace any provisional numbering below with the final figure and supplementary table numbering used in the revised submission.

## Main figures

| Manuscript element | Primary code/module | Notes |
|---|---|---|
| Baseline cohort characteristics tables | `ukb-aortic-analysis/` and `ckb-aortic-disease-code/` | Confirm final table generation scripts |
| UKB association analyses | `ukb-aortic-analysis/code/03_primary_analysis/` | Cox models for overall and subtype-specific outcomes |
| CKB validation analyses | `ckb-aortic-disease-code/` | External validation of observational associations |
| PAF figure(s) | `ukb-aortic-analysis/code/03_primary_analysis/` | UKB only in current manuscript |
| MR figure(s) | `mr-gwas-pipeline-code/` | Confirm final figure numbering |
| XGBoost ROC and SHAP figure(s) | `ukb-aortic-analysis/code/05_prediction_model/` | Prefer one designated primary prediction module |
| Sex interaction figure(s) | `ukb-aortic-analysis/code/04_sensitivity_and_subgroup/` and `code/06_visualization/` | Forest plots / interaction summaries |

## Supplementary tables and figures

| Supplementary element | Primary code/module | Notes |
|---|---|---|
| Chronic condition definitions | UKB and CKB modules | Keep cohort-specific definitions clearly separated |
| Detailed Cox tables | UKB/CKB analysis modules | Include FDR-corrected results where relevant |
| Multimorbidity tables | UKB/CKB analysis modules | Verify reference category and trend tests |
| MR sensitivity results | `mr-gwas-pipeline-code/` | Ensure thresholds and instrument filters match manuscript text |
| SHAP supplementary plots | Primary prediction module only | Avoid duplicates across two prediction directories |
| Competing-risk and sex sensitivity tables | `ukb-aortic-analysis/code/04_sensitivity_and_subgroup/` | Should correspond to Methods sensitivity section |

## Final pre-submission rule

Every figure and table cited in the revised manuscript should be traceable to:
1. a single primary script or module,
2. a defined input source, and
3. a reproducible output file name.
