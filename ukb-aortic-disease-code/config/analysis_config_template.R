# Copy this file to config/analysis_config.R and edit the local paths.
cfg <- list(
  data_raw_dir = "data-raw",          # local-only directory; do not upload restricted participant-level data
  data_processed_dir = "data-processed",
  results_dir = "results",
  figures_dir = file.path("results", "figures"),

  baseline_file = "ukb_baseline.csv",
  education_file = "ukb_education.csv",
  death_file = "ukb_death_registry.csv",
  outcome_file = "ukb_hes_outcomes.csv",
  opcs_source_file = "ukb_opcs_source.csv",
  opcs_codes_file = "ukb_opcs4_codes.xlsx",
  chronic_conditions_file = "ukb_chronic_conditions.csv",
  aortic_cause_file = "ukb_aortic_cause.csv",
  gene_sex_file = "ukb_gene_sex.csv",
  factor_file = "ukb_factor.csv",
  medication_file = "ukb_medication.csv"
)
