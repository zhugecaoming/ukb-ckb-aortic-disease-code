# 07_run_paf_models.R
# Calculate PAFs for all 42 chronic conditions using the Greenland-Drescher method.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()
cfg <- read_config()

ensure_dir(cfg$results_dir)

analysis_df <- safe_fread(file.path(cfg$data_processed_dir, "ukb_analysis_dataset.csv"))
disease_map <- read.csv("data_dictionary/chronic_conditions_42.csv", stringsAsFactors = FALSE)

results <- list()

for (i in seq_len(nrow(disease_map))) {
  exp_var <- disease_map$disease_code[i]
  date_var <- disease_map$event_date_column[i]
  if (!all(c(exp_var, date_var) %in% names(analysis_df))) next

  dat_raw <- exclude_outcome_before_exposure(analysis_df, exp_var, date_var)
  dat <- build_analysis_dataset(dat_raw, exp_var)
  paf_obj <- run_paf_for_exposure(dat, exp_var)
  results[[exp_var]] <- paf_obj$result
}

paf_df <- dplyr::bind_rows(results) %>% dplyr::arrange(dplyr::desc(PAR))
write.csv(paf_df, file.path(cfg$results_dir, "paf_results.csv"), row.names = FALSE)
message("Saved PAF results to results/paf_results.csv")
