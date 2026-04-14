# 02_build_aortic_subtypes.R
# Derive aortic subtype indicators and first-event dates from the wide ICD-10 outcome matrix.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()
cfg <- read_config()

ensure_dir(cfg$data_processed_dir)

outcome <- safe_fread(file.path(cfg$data_raw_dir, cfg$outcome_file))
death <- safe_fread(file.path(cfg$data_raw_dir, cfg$death_file))

subtype_specs <- list(
  list(name = "I700", codes = c("I700")),
  list(name = "I710", codes = c("I710")),
  list(name = "I711", codes = c("I711", "I712")),
  list(name = "I713", codes = c("I713", "I714")),
  list(name = "Iqt",  codes = c("I715", "I716", "I718", "I719"))
)

subtype_results <- list()
death_results <- list()

for (spec in subtype_specs) {
  subtype_results[[spec$name]] <- build_wide_icd_flag(outcome, spec$codes, spec$name)
  death_results[[spec$name]] <- build_death_flag(death, spec$codes) %>%
    dplyr::rename(!!paste0(spec$name, "_death_cause") := death_cause)
}

aortic_subtypes <- Reduce(function(x, y) merge(x, y, by = "eid", all = TRUE), subtype_results)

save_path <- file.path(cfg$data_processed_dir, "ukb_aortic_subtypes.csv")
data.table::fwrite(aortic_subtypes, save_path)

# Save one representative death-flag file per subtype for traceability.
for (nm in names(death_results)) {
  data.table::fwrite(
    death_results[[nm]],
    file.path(cfg$data_processed_dir, paste0("death_flag_", nm, ".csv"))
  )
}

message("Saved aortic subtype file to: ", save_path)
