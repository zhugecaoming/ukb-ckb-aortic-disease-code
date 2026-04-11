source("code/00_setup_packages.R")
source("code/helpers.R")
source("code/01_prepare_exposures.R")

run_mr_batch <- function(config_path = "config/config.yml", prepared = NULL) {
  cfg <- read_config(config_path)
  results_dir <- cfg$paths$results_dir
  outcome_dir <- cfg$paths$outcome_input_dir
  min_snps <- cfg$processing$min_harmonised_snps_for_full_sensitivity

  make_output_dir(results_dir)

  if (is.null(prepared)) {
    prepared <- prepare_exposures(config_path)
  }

  clumped_objects <- prepared$clumped
  outcome_files <- list_input_files(outcome_dir, cfg$outcome_file_pattern)

  if (length(outcome_files) == 0) {
    stop("No outcome files found in: ", outcome_dir)
  }

  if (length(clumped_objects) == 0) {
    stop("No clumped exposure objects available.")
  }

  exposure_names <- names(clumped_objects)

  for (i in seq_along(outcome_files)) {
    outcome_file <- outcome_files[i]
    outcome_data <- read_outcome_gwas(outcome_file, cfg)
    outcome_name <- clean_trait_name(outcome_file, prefix_to_remove = "")
    outcome_data$outcome <- outcome_name

    safe_write_csv(
      outcome_data,
      file.path(results_dir, paste0("outcome_data_", outcome_name, ".csv"))
    )

    for (j in seq_along(exposure_names)) {
      exposure_name <- exposure_names[j]
      exp_dat <- clumped_objects[[exposure_name]]

      merge_data <- merge(exp_dat, outcome_data, by = "SNP")
      safe_write_csv(
        merge_data,
        file.path(results_dir, paste0("merge_data_", outcome_name, "_", exposure_name, ".csv"))
      )

      merge_dat_outcome <- merge_data[, -grep("exposure", colnames(merge_data)), drop = FALSE]

      dat_har <- TwoSampleMR::harmonise_data(
        exposure_dat = exp_dat,
        outcome_dat = merge_dat_outcome
      )

      safe_write_csv(
        dat_har,
        file.path(results_dir, paste0("har_data_", outcome_name, "_", exposure_name, ".csv"))
      )

      if (nrow(dat_har) == 0) {
        message("No harmonised variants for ", exposure_name, " -> ", outcome_name)
        next
      }

      mr_res <- TwoSampleMR::mr(dat_har)
      mr_or <- TwoSampleMR::generate_odds_ratios(mr_res = mr_res)

      significant <- any(mr_res$pval < 0.05, na.rm = TRUE)
      suffix <- if (significant) "" else "_ns"

      safe_write_csv(
        mr_res,
        file.path(results_dir, paste0("mr_", outcome_name, "_", exposure_name, suffix, ".csv"))
      )
      safe_write_csv(
        mr_or,
        file.path(results_dir, paste0("mr_method_", outcome_name, "_", exposure_name, suffix, ".csv"))
      )

      if (nrow(dat_har) >= min_snps) {
        result_single <- TwoSampleMR::mr_singlesnp(dat_har)

        mr_scat <- TwoSampleMR::mr_scatter_plot(mr_results = mr_res, dat_har)
        save_plot_if_exists(
          mr_scat,
          file.path(results_dir, paste0("mr_scat_", outcome_name, "_", exposure_name, ".eps"))
        )

        p2 <- TwoSampleMR::mr_forest_plot(result_single)
        save_plot_if_exists(
          p2,
          file.path(results_dir, paste0("mr_forest_", outcome_name, "_", exposure_name, ".eps"))
        )

        if (nrow(result_single) >= 30) {
          result_single_sorted <- result_single[order(result_single$p), ]
          top_30_results <- result_single_sorted[1:30, ]
          p3 <- TwoSampleMR::mr_forest_plot(top_30_results)
          save_plot_if_exists(
            p3,
            file.path(results_dir, paste0("mr_forest_top30_", outcome_name, "_", exposure_name, ".eps"))
          )
        }

        mr_he <- TwoSampleMR::mr_heterogeneity(dat_har)
        he_suffix <- if (any(mr_he$pval < 0.05, na.rm = TRUE)) "_sig" else ""
        safe_write_csv(
          mr_he,
          file.path(results_dir, paste0("mr_her_", outcome_name, "_", exposure_name, he_suffix, ".csv"))
        )

        p4 <- TwoSampleMR::mr_funnel_plot(singlesnp_results = result_single)
        save_plot_if_exists(
          p4,
          file.path(results_dir, paste0("mr_funnel_", outcome_name, "_", exposure_name, ".eps"))
        )

        mr_ple <- TwoSampleMR::mr_pleiotropy_test(dat_har)
        ple_suffix <- if (any(mr_ple$pval < 0.05, na.rm = TRUE)) "_sig" else ""
        safe_write_csv(
          mr_ple,
          file.path(results_dir, paste0("mr_ple_", outcome_name, "_", exposure_name, ple_suffix, ".csv"))
        )

        mr_leave <- TwoSampleMR::mr_leaveoneout_plot(
          leaveoneout_results = TwoSampleMR::mr_leaveoneout(dat_har)
        )
        save_plot_if_exists(
          mr_leave,
          file.path(results_dir, paste0("mr_lea_", outcome_name, "_", exposure_name, ".eps"))
        )
      }

      message("Finished: ", exposure_name, " -> ", outcome_name)
    }
  }

  invisible(TRUE)
}
