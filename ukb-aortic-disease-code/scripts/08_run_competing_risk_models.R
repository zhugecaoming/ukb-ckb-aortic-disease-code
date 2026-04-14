# 08_run_competing_risk_models.R
# Competing-risk sensitivity analysis using CSC from riskRegression.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()
cfg <- read_config()

ensure_dir(cfg$results_dir)

analysis_df <- safe_fread(file.path(cfg$data_processed_dir, "ukb_analysis_dataset.csv"))

death_path <- file.path(cfg$data_raw_dir, cfg$death_file)
death <- safe_fread(death_path) %>%
  dplyr::mutate(
    death = ifelse(!is.na(death_data1) | !is.na(death_data2), 1, 0),
    death_date = dplyr::coalesce(as.Date(death_data1), as.Date(death_data2))
  ) %>%
  dplyr::select(eid, death, death_date)

analysis_df <- merge(analysis_df, death, by = "eid", all.x = TRUE)

# Default example: hypertension, matching the original competing-risk script.
exp_var <- "hyp"
date_var <- "hyp_date"
if (!all(c(exp_var, date_var) %in% names(analysis_df))) {
  stop("The default exposure hyp/hyp_date was not found. Edit this script to choose another exposure.")
}

dat_raw <- exclude_outcome_before_exposure(analysis_df, exp_var, date_var)
fit <- run_csc_competing_risk(dat_raw, exp_var)

capture.output(summary(fit), file = file.path(cfg$results_dir, "competing_risk_summary_hyp.txt"))
message("Saved competing-risk model summary to results/competing_risk_summary_hyp.txt")
