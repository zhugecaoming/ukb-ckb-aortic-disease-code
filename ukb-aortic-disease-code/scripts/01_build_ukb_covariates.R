# 01_build_ukb_covariates.R
# Build the cleaned UKB covariate table used by downstream analyses.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()
cfg <- read_config()

ensure_dir(cfg$data_processed_dir)

ukb <- safe_fread(file.path(cfg$data_raw_dir, cfg$baseline_file))
edu <- safe_fread(file.path(cfg$data_raw_dir, cfg$education_file))

ukb <- compute_met(ukb)
ukb <- recode_covariates(ukb, edu)

save_path <- file.path(cfg$data_processed_dir, "ukb_covariates_clean.csv")
data.table::fwrite(ukb, save_path)
message("Saved cleaned covariates to: ", save_path)
