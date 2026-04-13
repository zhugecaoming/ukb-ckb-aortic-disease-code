source("code/00_setup/helpers.R")
check_and_load_packages(c("ggplot2", "dplyr", "readxl"))
config <- load_config()

build_custom_forest_plot <- function(data, hline = 1, ymax = NULL) {
  data$x <- factor(data$x, levels = rev(unique(data$x)))
  data$group_col <- c(rep("#e7a40e", 6), rep("#78bee5", 3), rep("#1c6891", 5), rep("#a59d70", 2), rep("#4f4a30", 6))[seq_len(nrow(data))]
  data$p_col[data$p %in% c("*", "**", "***") & data$med > 1] <- "Postive effect(P<0.05)"
  data$p_col[is.na(data$p) & data$med > 1] <- "Postive effect(P>=0.05)"
  data$p_col[data$p %in% c("*", "**", "***") & data$med <= 1] <- "Negtive effect(P<0.05)"
  data$p_col[is.na(data$p) & data$med <= 1] <- "Negtive effect(P>=0.05)"
  if (is.null(ymax)) ymax <- max(data$max, na.rm = TRUE) + 1

  ggplot2::ggplot(data) +
    ggplot2::geom_hline(yintercept = hline, linewidth = 0.3) +
    ggplot2::geom_linerange(ggplot2::aes(x, ymin = min, ymax = max, color = p_col), show.legend = FALSE) +
    ggplot2::geom_point(ggplot2::aes(x, med, color = p_col)) +
    ggplot2::geom_text(ggplot2::aes(x = x, y = max + 0.17, label = p, color = p_col), show.legend = FALSE) +
    ggplot2::scale_color_manual(values = c("Postive effect(P<0.05)" = "#d55e00", "Postive effect(P>=0.05)" = "#ffbd88", "Negtive effect(P<0.05)" = "#0072b2", "Negtive effect(P>=0.05)" = "#7acfff")) +
    ggplot2::annotate("rect", xmin = c(0.5, 6.5, 8.5, 13.5, 16.5), xmax = c(6.5, 8.5, 13.5, 16.5, 22.5), ymin = min(hline, 0.8), ymax = ymax, alpha = 0.2, fill = rev(unique(data$group_col))[seq_len(5)]) +
    ggplot2::scale_y_continuous(expand = c(0, 0)) +
    ggplot2::xlab("") +
    ggplot2::ylab("Regression Coefficient (95% CI)") +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.text.y = ggplot2::element_text(color = rev(data$group_col))) +
    ggplot2::coord_flip()
}

# Batch export using Excel inputs named data1.xlsx, data2.xlsx, ... in the configured folder.
excel_dir <- config$paths$custom_forest_xlsx_dir
if (dir.exists(excel_dir)) {
  files_in <- list.files(excel_dir, pattern = "\.xlsx$", full.names = TRUE)
  for (fp in files_in) {
    dat <- readxl::read_xlsx(fp)
    p <- build_custom_forest_plot(dat, hline = if (grepl("data1|data2", basename(fp), ignore.case = TRUE)) 0.8 else 1)
    out_name <- paste0(tools::file_path_sans_ext(basename(fp)), "_custom_forest.pdf")
    ggplot2::ggsave(file.path(config$outputs$figures_dir, out_name), p, width = 8, height = 6)
  }
  message("Exported custom forest plots from Excel inputs.")
} else {
  message("Set config$paths$custom_forest_xlsx_dir to your local Excel folder to run custom forest plots.")
}
