# Repository notes

This cleaned repository was reconstructed from a single original script containing:

- data preparation
- repeated phenotype-specific model fitting
- XGBoost training and internal validation
- ROC/AUC evaluation
- threshold-based performance metrics
- SHAP interpretation and plot export

## What was improved

- removed absolute local working-directory paths
- converted ad hoc workflow into a reusable project structure
- separated setup, data preparation, and model training
- added a configuration template
- standardized output locations
- prepared the repository for GitHub upload

## Before public release

Please verify:

1. your variable names match the config
2. your input objects are loaded correctly
3. your fixed covariates are available
4. your outcome coding is correct
5. no sensitive data files are tracked by Git
