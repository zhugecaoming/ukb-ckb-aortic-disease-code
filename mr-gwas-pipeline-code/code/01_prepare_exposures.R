source("code/00_setup_packages.R")
source("code/helpers.R")

prepare_exposures <- function(config_path = "config/config.yml") {
  cfg <- read_config(config_path)

  exposure_dir <- cfg$paths$exposure_input_dir
  results_dir <- cfg$paths$results_dir
  plink_bin <- cfg$paths$plink_bin
  bfile <- cfg$paths$ld_reference_prefix
  start_index <- cfg$processing$exposure_start_index
  p_threshold <- cfg$processing$exposure_p_threshold

  make_output_dir(results_dir)

  exposure_files <- list_input_files(exposure_dir, cfg$exposure_file_pattern)

  if (length(exposure_files) == 0) {
    stop("No exposure files found in: ", exposure_dir)
  }

  if (start_index < 1 || start_index > length(exposure_files)) {
    stop("Invalid exposure_start_index: ", start_index)
  }

  exposure_objects <- list()
  clumped_objects <- list()

  for (i in seq(from = start_index, to = length(exposure_files))) {
    file_path <- exposure_files[i]
    trait_name <- clean_trait_name(file_path)

    message("Preparing exposure: ", trait_name, " (", i, "/", length(exposure_files), ")")

    data <- read_exposure_gwas(file_path, cfg)
    data$exposure <- trait_name

    exposure_dat_dif <- subset(data, pval.exposure < p_threshold)
    safe_write_csv(
      exposure_dat_dif,
      file.path(results_dir, paste0("exp_data_dif_", trait_name, ".csv"))
    )

    if (nrow(exposure_dat_dif) == 0) {
      message("No variants passed p-value threshold for ", trait_name)
      next
    }

    a <- exposure_dat_dif

    if (isTRUE(cfg$clumping$enabled)) {
      ldsc_gwas <- ieugwasr::ld_clump(
        dplyr::tibble(
          rsid = a$SNP,
          pval = a$pval.exposure,
          exposure = a$exposure,
          beta.exposure = a$beta.exposure,
          se.exposure = a$se.exposure,
          eaf.exposure = a$eaf.exposure,
          id.exposure = a$id.exposure,
          other_allele.exposure = a$other_allele.exposure,
          effect_allele.exposure = a$effect_allele.exposure,
          n.exposure = a$ncase.exposure
        ),
        plink_bin = plink_bin,
        bfile = bfile
      )

      colnames(ldsc_gwas)[colnames(ldsc_gwas) == "rsid"] <- "SNP"
      ldsc_gwas$exposure <- trait_name

      safe_write_csv(
        ldsc_gwas,
        file.path(results_dir, paste0("ldsc_gwas_", trait_name, ".csv")),
        row.names = FALSE
      )

      clumped_objects[[trait_name]] <- ldsc_gwas
      exposure_objects[[trait_name]] <- data
    }
  }

  invisible(list(
    exposures = exposure_objects,
    clumped = clumped_objects
  ))
}
