# 04_prepare_analysis_dataset.R
# Merge the primary endpoint with the chronic-condition table used for the 42-condition analyses.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()
cfg <- read_config()

ensure_dir(cfg$data_processed_dir)

endpoint <- safe_fread(file.path(cfg$data_processed_dir, "ukb_primary_aortic_endpoint.csv"))
disease <- safe_fread(file.path(cfg$data_raw_dir, cfg$chronic_conditions_file))

analysis_df <- merge(endpoint, disease, by = "eid", all.x = TRUE)

# Optional sensitivity-analysis file
gene_sex_path <- file.path(cfg$data_raw_dir, cfg$gene_sex_file)
if (file.exists(gene_sex_path)) {
  gene_sex <- safe_fread(gene_sex_path)
  analysis_df <- merge(analysis_df, gene_sex, by = "eid", all.x = TRUE)
}

save_path <- file.path(cfg$data_processed_dir, "ukb_analysis_dataset.csv")
data.table::fwrite(analysis_df, save_path)
message("Saved merged analysis dataset to: ", save_path)
