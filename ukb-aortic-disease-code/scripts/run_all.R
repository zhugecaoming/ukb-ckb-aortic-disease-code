# run_all.R
# End-to-end execution order for the UKB aortic disease analysis.

source("scripts/00_install_packages.R")
source("scripts/01_build_ukb_covariates.R")
source("scripts/02_build_aortic_subtypes.R")
source("scripts/03_build_primary_endpoint.R")
source("scripts/04_prepare_analysis_dataset.R")
source("scripts/05_run_primary_cox_models.R")
source("scripts/06_run_multimorbidity_models.R")
source("scripts/07_run_paf_models.R")
source("scripts/08_run_competing_risk_models.R")
source("scripts/09_plot_sex_stratified_forest.R")
source("scripts/10_plot_personalized_forest.R")
