read_config <- function(config_path = "config/config.yml") {
  if (!file.exists(config_path)) {
    stop("Config file not found: ", config_path,
         ". Please copy config/config_template.yml to config/config.yml and edit it.")
  }
  yaml::read_yaml(config_path)
}

list_input_files <- function(folder_path, pattern = NULL) {
  if (!dir.exists(folder_path)) {
    stop("Directory not found: ", folder_path)
  }
  list.files(folder_path, pattern = pattern, full.names = TRUE)
}

make_output_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
}

clean_trait_name <- function(file_path, prefix_to_remove = "finngen_") {
  x <- sub("\\.[^.]*?$", "", basename(file_path))
  sub(prefix_to_remove, "", x)
}

read_exposure_gwas <- function(file_path, cfg) {
  cols <- cfg$columns$exposure
  mode <- cfg$exposure_read_mode

  if (mode == "finngen") {
    TwoSampleMR::read_exposure_data(
      filename = file_path,
      sep = "\t",
      snp_col = cols$snp_col,
      chr_col = cols$chr_col,
      pos_col = cols$pos_col,
      beta_col = cols$beta_col,
      se_col = cols$se_col,
      effect_allele_col = cols$effect_allele_col,
      other_allele_col = cols$other_allele_col,
      gene_col = cols$gene_col,
      eaf_col = cols$eaf_col,
      pval_col = cols$pval_col,
      phenotype_col = cols$phenotype_col
    )
  } else {
    stop("Unsupported exposure_read_mode: ", mode)
  }
}

read_outcome_gwas <- function(file_path, cfg) {
  cols <- cfg$columns$outcome
  mode <- cfg$outcome_read_mode

  if (mode == "finngen") {
    TwoSampleMR::read_outcome_data(
      filename = file_path,
      sep = "\t",
      snp_col = cols$snp_col,
      chr_col = cols$chr_col,
      pos_col = cols$pos_col,
      beta_col = cols$beta_col,
      se_col = cols$se_col,
      effect_allele_col = cols$effect_allele_col,
      other_allele_col = cols$other_allele_col,
      gene_col = cols$gene_col,
      eaf_col = cols$eaf_col,
      pval_col = cols$pval_col,
      phenotype_col = cols$phenotype_col
    )
  } else {
    stop("Unsupported outcome_read_mode: ", mode)
  }
}

safe_write_csv <- function(x, path, row.names = FALSE) {
  utils::write.csv(x, path, row.names = row.names)
}

save_plot_if_exists <- function(plot_obj, path, width = 6, height = 4) {
  if (!is.null(plot_obj) && length(plot_obj) > 0) {
    ggplot2::ggsave(filename = path, plot = plot_obj[[1]], width = width, height = height, units = "in")
  }
}
