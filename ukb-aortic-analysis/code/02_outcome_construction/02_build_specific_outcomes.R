source("code/00_setup/helpers.R")
check_and_load_packages()
config <- load_config()

Outcome <- utils::read.csv(config$paths$outcome_csv)
code_range <- seq(config$analysis$outcome_icd_code_columns[[1]], config$analysis$outcome_icd_code_columns[[2]])
date_range <- seq(config$analysis$outcome_date_columns[[1]], config$analysis$outcome_date_columns[[2]])

res_i700 <- extract_icd_outcome(Outcome, c("I700"), "I700", code_range, date_range, config$analysis$censor_date)
res_i710 <- extract_icd_outcome(Outcome, c("I710"), "I710", code_range, date_range, config$analysis$censor_date)

# Keep the same code grouping logic as the uploaded scripts.
res_i711 <- dplyr::full_join(
  extract_icd_outcome(Outcome, c("I711"), "I711", code_range, date_range, config$analysis$censor_date),
  extract_icd_outcome(Outcome, c("I712"), "I712", code_range, date_range, config$analysis$censor_date),
  by = "eid"
)
res_i713 <- dplyr::full_join(
  extract_icd_outcome(Outcome, c("I713"), "I713", code_range, date_range, config$analysis$censor_date),
  extract_icd_outcome(Outcome, c("I714"), "I714", code_range, date_range, config$analysis$censor_date),
  by = "eid"
)
res_iqt <- Reduce(function(x, y) dplyr::full_join(x, y, by = "eid"), list(
  extract_icd_outcome(Outcome, c("I715"), "I715", code_range, date_range, config$analysis$censor_date),
  extract_icd_outcome(Outcome, c("I716"), "I716", code_range, date_range, config$analysis$censor_date),
  extract_icd_outcome(Outcome, c("I718"), "I718", code_range, date_range, config$analysis$censor_date),
  extract_icd_outcome(Outcome, c("I719"), "I719", code_range, date_range, config$analysis$censor_date)
))

# OPCS supplement from Aortic Disease.R / Competing risk model.R
opcs <- utils::read.csv(config$paths$opcs_csv)
opcs_res <- build_opcs_outcome(
  opcs_df = opcs,
  lookup_xlsx = config$paths$opcs_lookup_xlsx,
  code_cols = seq(config$analysis$opcs_code_columns[[1]], config$analysis$opcs_code_columns[[2]]),
  date_cols = seq(config$analysis$opcs_date_columns[[1]], config$analysis$opcs_date_columns[[2]]),
  censor_date = config$analysis$censor_date
)

safe_write_csv(res_i700, file.path(config$outputs$tables_dir, "outcome_I700.csv"))
safe_write_csv(res_i710, file.path(config$outputs$tables_dir, "outcome_I710.csv"))
safe_write_csv(res_i711, file.path(config$outputs$tables_dir, "outcome_I711_I712.csv"))
safe_write_csv(res_i713, file.path(config$outputs$tables_dir, "outcome_I713_I714.csv"))
safe_write_csv(res_iqt, file.path(config$outputs$tables_dir, "outcome_I715_I716_I718_I719.csv"))
safe_write_csv(opcs_res, file.path(config$outputs$tables_dir, "outcome_OPCS.csv"))
message("Saved subtype outcomes and OPCS supplement.")
