source("code/00_setup/helpers.R")
check_and_load_packages(c("ggplot2", "dplyr", "gridExtra"))
config <- load_config()

plot_sex_forest <- function(data, output_path, x_limit = c(0.6, 8.4)) {
  new_order <- unique(as.character(data$Condition))
  data$Condition <- factor(data$Condition, levels = rev(new_order))
  hr_labels <- data %>% dplyr::mutate(hr_label = paste0(round(HR, 2), " (", round(Lower, 2), ", ", round(Upper, 2), ")"))
  p_labels <- hr_labels %>% dplyr::filter(Gender %in% c("Male", "Female")) %>% dplyr::group_by(Condition) %>% dplyr::slice(1) %>% dplyr::ungroup()

  p <- ggplot2::ggplot(data, ggplot2::aes(x = HR, y = Condition, color = Gender)) +
    ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.7), size = 5) +
    ggplot2::geom_errorbarh(ggplot2::aes(xmin = Lower, xmax = Upper), height = 0.3, position = ggplot2::position_dodge(width = 0.7), linewidth = 1.2) +
    ggplot2::geom_vline(xintercept = 1, linetype = "dashed", color = "black") +
    ggplot2::geom_hline(yintercept = 1:(length(new_order)-1) + 0.5, linetype = "dashed", color = "grey80") +
    ggplot2::geom_text(data = hr_labels %>% dplyr::filter(Gender == "Male"), ggplot2::aes(x = x_limit[2] - 2.5, y = as.numeric(Condition) + 0.15, label = hr_label), inherit.aes = FALSE, size = 4.2, hjust = 0, color = "blue") +
    ggplot2::geom_text(data = hr_labels %>% dplyr::filter(Gender == "Female"), ggplot2::aes(x = x_limit[2] - 2.5, y = as.numeric(Condition) - 0.15, label = hr_label), inherit.aes = FALSE, size = 4.2, hjust = 0, color = "red") +
    ggplot2::geom_text(data = p_labels, ggplot2::aes(x = x_limit[2] - 1.0, y = Condition, label = paste0("P = ", p_val)), inherit.aes = FALSE, size = 4.2, hjust = 0, color = "black") +
    ggplot2::annotate("text", x = x_limit[2] - 2.2, y = length(new_order) + 0.5, label = "HR (95% CI)", size = 4, fontface = "bold") +
    ggplot2::annotate("text", x = x_limit[2] - 0.5, y = length(new_order) + 0.5, label = "P for interaction", size = 4, fontface = "bold") +
    ggplot2::scale_color_manual(values = c("Female" = "red", "Male" = "blue")) +
    ggplot2::labs(x = "Hazard Ratio", y = NULL, color = "Gender") +
    ggplot2::scale_x_continuous(breaks = 1:6, limits = x_limit) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(legend.position = "top", panel.grid.major.x = ggplot2::element_blank(), panel.grid.minor.x = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank(), axis.line.x = ggplot2::element_line(color = "black", linewidth = 0.6), axis.ticks.x = ggplot2::element_line(color = "black"), axis.text.x = ggplot2::element_text(color = "black", size = 13), axis.text.y = ggplot2::element_text(color = "black", size = 13), plot.margin = grid::unit(c(1.5, 10, 1.5, 2), "lines"))
  ggplot2::ggsave(output_path, p, width = 10, height = 6)
}

# Recreate the hard-coded example from senlin_sex.R for reference.
example_data <- data.frame(
  Condition = rep(c("hypertension", "coronary heart disease", "stroke and TIA", "osteoporosis", "COPD", "atrial fibrillation", "peripheral vascular disease", "heart failure"), each = 2),
  Gender = rep(c("Male", "Female"), times = 8),
  HR = c(2.95, 4.45, 3.17, 4.07, 1.39, 2.14, 0.95, 1.42, 1.67, 2.14, 2.31, 3.75, 2.09, 4.17, 2.18, 3.45),
  Lower = c(2.71, 3.80, 2.94, 3.51, 1.25, 1.76, 0.73, 1.16, 1.50, 1.75, 2.13, 3.18, 1.82, 3.33, 1.97, 2.79),
  Upper = c(3.22, 5.21, 3.41, 4.72, 1.54, 2.61, 1.22, 1.74, 1.86, 2.62, 2.51, 4.42, 2.41, 5.23, 2.42, 4.26),
  p_val = rep(c("<0.01", "0.03", "<0.01", "<0.01", "<0.01", "<0.01", "0.03", "0.04"), each = 2)
)
plot_sex_forest(example_data, file.path(config$outputs$figures_dir, "sex_interaction_forest_example.pdf"))
message("Saved: sex_interaction_forest_example.pdf")
