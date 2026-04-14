# 09_plot_sex_stratified_forest.R
# Plot the sex-stratified forest figure from a tidy CSV file.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()

input_file <- "example_data/example_sex_stratified_results.csv"
out_file <- "results/figures/sex_stratified_forest.png"

ensure_dir("results/figures")

data <- read.csv(input_file, stringsAsFactors = FALSE)

new_order <- c("hypertension", "coronary heart disease",
               "peripheral vascular disease", "atrial fibrillation",
               "heart failure", "stroke and TIA",
               "COPD", "osteoporosis")

data$Condition <- factor(data$Condition, levels = rev(new_order))

p_labels <- data %>%
  dplyr::filter(Gender == "Female")

p <- ggplot2::ggplot(data, ggplot2::aes(x = HR, y = Condition, color = Gender)) +
  ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.7), size = 3.2) +
  ggplot2::geom_errorbarh(
    ggplot2::aes(xmin = Lower, xmax = Upper),
    height = 0.3,
    position = ggplot2::position_dodge(width = 0.7),
    linewidth = 0.9
  ) +
  ggplot2::geom_vline(xintercept = 1, linetype = "dashed", color = "black") +
  ggplot2::geom_hline(yintercept = 1:(length(new_order) - 1) + 0.5, linetype = "dashed", color = "grey80") +
  ggplot2::geom_text(
    data = p_labels,
    ggplot2::aes(x = 6, y = Condition, label = p_val),
    inherit.aes = FALSE,
    size = 4,
    hjust = 0,
    color = "black"
  ) +
  ggplot2::annotate("text", x = 6.2, y = 8.5, label = "P for interaction", size = 4, fontface = "bold") +
  ggplot2::scale_color_manual(values = c("Female" = "red", "Male" = "blue")) +
  ggplot2::labs(x = "Hazard Ratio", y = NULL, color = "Gender") +
  ggplot2::scale_x_continuous(breaks = 1:6, limits = c(0.6, 6.5)) +
  ggplot2::theme_minimal(base_size = 13) +
  ggplot2::theme(
    legend.position = "top",
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.minor.x = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_blank(),
    axis.line.x = ggplot2::element_line(color = "black", linewidth = 0.6),
    axis.ticks.x = ggplot2::element_line(color = "black"),
    axis.text.x = ggplot2::element_text(color = "black"),
    axis.text.y = ggplot2::element_text(color = "black")
  )

ggplot2::ggsave(out_file, p, width = 8.5, height = 5.5, dpi = 300)
message("Saved figure to: ", out_file)
