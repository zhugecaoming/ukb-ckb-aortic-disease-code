source("code/00_setup/helpers.R")
check_and_load_packages()
config <- load_config()

ukb <- data.table::fread(config$paths$baseline_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
edu <- data.table::fread(config$paths$education_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)

ukb <- compute_met(ukb)
ukb <- recode_baseline_factors(ukb, edu)

safe_write_csv(ukb, file.path(config$outputs$tables_dir, "ukb_baseline_preprocessed.csv"))
message("Saved: ukb_baseline_preprocessed.csv")
