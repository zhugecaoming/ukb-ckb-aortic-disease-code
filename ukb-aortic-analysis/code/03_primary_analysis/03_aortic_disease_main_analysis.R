source("code/00_setup/helpers.R")
check_and_load_packages()
config <- load_config()

ukb <- data.table::fread(config$paths$baseline_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
ukb <- compute_met(ukb)
ukb <- recode_baseline_factors(ukb, data.table::fread(config$paths$education_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE))

# Death cause file used in the original composite outcome script.
death_cause <- data.table::fread(config$paths$death_cause_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
death_cause <- dplyr::select(death_cause, eid, dplyr::everything())

# Derived outcome components.
outcome_files <- list(
  file.path(config$outputs$tables_dir, "outcome_I700.csv"),
  file.path(config$outputs$tables_dir, "outcome_I710.csv"),
  file.path(config$outputs$tables_dir, "outcome_I711_I712.csv"),
  file.path(config$outputs$tables_dir, "outcome_I713_I714.csv"),
  file.path(config$outputs$tables_dir, "outcome_I715_I716_I718_I719.csv"),
  file.path(config$outputs$tables_dir, "outcome_OPCS.csv")
)
outcome_tables <- lapply(outcome_files[file.exists(outcome_files)], utils::read.csv)
outcome_merged <- Reduce(function(x, y) merge(x, y, by = "eid", all = TRUE), outcome_tables)

merge1 <- merge(ukb, death_cause, by = "eid")
merge2 <- merge(merge1, outcome_merged, by = "eid", all.x = TRUE)
merge2 <- build_composite_an(merge2, config$analysis$censor_date)
merge2_1 <- dplyr::filter(merge2, AN_ctime > 0)

# Optional extra covariate tables, following the original script.
if (file.exists(config$paths$factor_csv)) {
  factor_df <- data.table::fread(config$paths$factor_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
  merge2_1 <- merge(merge2_1, factor_df, by = "eid", all.x = TRUE)
}
if (file.exists(config$paths$disease_csv)) {
  disease_df <- data.table::fread(config$paths$disease_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
  merge3 <- merge(merge2_1, disease_df, by = "eid", all.x = TRUE)
} else {
  merge3 <- merge2_1
}
if (file.exists(config$paths$medication_csv)) {
  med_df <- data.table::fread(config$paths$medication_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
  merge3 <- merge(merge3, med_df, by = "eid", all.x = TRUE)
}
if (file.exists(config$paths$gene_sex_csv)) {
  gene_df <- data.table::fread(config$paths$gene_sex_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
  merge3 <- merge(merge3, gene_df, by = "eid", all.x = TRUE)
  if ("22001-0.0" %in% names(merge3)) merge3$gene_sex <- merge3[["22001-0.0"]]
}

safe_write_csv(merge3, file.path(config$outputs$tables_dir, "analysis_dataset_main.csv"))

# Example single-exposure model mirroring the original script.
default_exposure <- if ("hyp" %in% names(merge3)) "hyp" else config$analysis$disease_exposures[[1]]
if (default_exposure %in% names(merge3)) {
  if (paste0(default_exposure, "_date") %in% names(merge3)) {
    merge4 <- remove_reverse_time_order(merge3, default_exposure, paste0(default_exposure, "_date"), "AN_date")
  } else {
    merge4 <- merge3
  }
  Total <- build_analysis_dataset(merge4, default_exposure, "AN_ctime", "AN")
  fit <- run_cox_model(Total, default_exposure)
  coef_table <- as.data.frame(summary(fit)$coefficients)
  coef_table$term <- rownames(coef_table)
  safe_write_csv(coef_table, file.path(config$outputs$tables_dir, "cox_main_single_exposure.csv"))
}

# PAF loop directly integrated from the uploaded main script.
paf_table <- run_paf_table(merge3, config$analysis$disease_exposures, outcome_date_var = "AN_date")
safe_write_csv(paf_table, file.path(config$outputs$tables_dir, "PAF_composite_AN.csv"))
message("Saved: analysis_dataset_main.csv, cox_main_single_exposure.csv, PAF_composite_AN.csv")
