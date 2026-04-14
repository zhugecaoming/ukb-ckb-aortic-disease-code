# 03_build_primary_endpoint.R
# Build the overall incident aortic disease endpoint by combining ICD-10, death, and OPCS4-derived events.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()
cfg <- read_config()

ensure_dir(cfg$data_processed_dir)

ukb <- safe_fread(file.path(cfg$data_processed_dir, "ukb_covariates_clean.csv"))
aortic_subtypes <- safe_fread(file.path(cfg$data_processed_dir, "ukb_aortic_subtypes.csv"))

# Optional support file used in the original master script.
aortic_cause_path <- file.path(cfg$data_raw_dir, cfg$aortic_cause_file)
if (file.exists(aortic_cause_path)) {
  ukb_aortic_cause <- safe_fread(aortic_cause_path)
  ukb <- merge(ukb, ukb_aortic_cause, by = "eid", all.x = TRUE)
}

opcs_source <- safe_fread(file.path(cfg$data_raw_dir, cfg$opcs_source_file))
opcs_codes <- safe_read_excel(file.path(cfg$data_raw_dir, cfg$opcs_codes_file))
opcs <- build_opcs_flag(opcs_source, opcs_codes, prefix = "case")

endpoint <- assemble_primary_endpoint(ukb, aortic_subtypes, opcs)

save_path <- file.path(cfg$data_processed_dir, "ukb_primary_aortic_endpoint.csv")
data.table::fwrite(endpoint, save_path)
message("Saved primary endpoint to: ", save_path)
