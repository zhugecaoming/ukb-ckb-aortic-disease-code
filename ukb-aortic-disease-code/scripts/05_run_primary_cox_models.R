# 05_run_primary_cox_models.R
# Fit the primary Cox models for all 42 chronic conditions.

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

  fit <- run_cox_for_exposure(dat, exp_var)
  coef_row <- summary(fit)$coefficients[exp_var, , drop = FALSE]
  conf_row <- summary(fit)$conf.int[exp_var, , drop = FALSE]

  results[[exp_var]] <- data.frame(
    Disease = exp_var,
    N = nrow(dat),
    Events = sum(dat$AN),
    HR = conf_row[, "exp(coef)"],
    lower = conf_row[, "lower .95"],
    upper = conf_row[, "upper .95"],
    p_value = coef_row[, "Pr(>|z|)"]
  )
}

res_df <- dplyr::bind_rows(results)
res_df$FDR <- p.adjust(res_df$p_value, method = "fdr")

save_path <- file.path(cfg$results_dir, "primary_cox_results.csv")
write.csv(res_df, save_path, row.names = FALSE)
message("Saved primary Cox results to: ", save_path)
