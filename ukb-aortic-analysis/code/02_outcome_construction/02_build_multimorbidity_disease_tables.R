source("code/00_setup/helpers.R")
check_and_load_packages()
config <- load_config()

Outcome <- utils::read.csv(config$paths$outcome_csv)
code_range <- seq(config$analysis$outcome_icd_code_columns[[1]], config$analysis$outcome_icd_code_columns[[2]])
date_range <- seq(config$analysis$outcome_date_columns[[1]], config$analysis$outcome_date_columns[[2]])

# Directly adapted from disease.R for the uploaded chronic disease example (B18-based outcome).
Disease <- extract_icd_outcome(
  outcome_df = Outcome,
  codes = c("^B18"),
  prefix = "opsm",
  code_cols = code_range,
  date_cols = date_range,
  censor_date = config$analysis$censor_date
)

safe_write_csv(Disease, file.path(config$outputs$tables_dir, "derived_disease_opsm.csv"))
message("Saved: derived_disease_opsm.csv")
