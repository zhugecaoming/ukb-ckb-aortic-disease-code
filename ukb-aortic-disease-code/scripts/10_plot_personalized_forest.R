# 10_plot_personalized_forest.R
# Generalized version of the personalized forest-plot script.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()

input_file <- "example_data/example_personalized_forest_input.csv"
out_file <- "results/figures/personalized_forest_example.png"

ensure_dir("results/figures")

data <- read.csv(input_file, stringsAsFactors = FALSE)
data$x <- factor(data$x, levels = rev(unique(data$x)))

data$p_col <- NA_character_
data$p_col[data$p %in% c("*","**","***") & data$med > 1] <- "Positive effect (P < 0.05)"
data$p_col[is.na(data$p) & data$med > 1] <- "Positive effect (P >= 0.05)"
data$p_col[data$p %in% c("*","**","***") & data$med <= 1] <- "Negative effect (P < 0.05)"
data$p_col[is.na(data$p) & data$med <= 1] <- "Negative effect (P >= 0.05)"

p <- ggplot2::ggplot(data) +
  ggplot2::geom_hline(yintercept = 1, linewidth = 0.3) +
  ggplot2::geom_linerange(ggplot2::aes(x = x, ymin = min, ymax = max, color = p_col), show.legend = FALSE) +
  ggplot2::geom_point(ggplot2::aes(x = x, y = med, color = p_col)) +
  ggplot2::geom_text(ggplot2::aes(x = x, y = max + 0.15, label = p, color = p_col), show.legend = FALSE) +
  ggplot2::scale_color_manual(
    values = c(
      "Positive effect (P < 0.05)" = "#d55e00",
      "Positive effect (P >= 0.05)" = "#ffbd88",
      "Negative effect (P < 0.05)" = "#0072b2",
      "Negative effect (P >= 0.05)" = "#7acfff"
    )
  ) +
  ggplot2::annotate(
    "rect",
    xmin = c(0.5, 6.5, 8.5, 13.5, 16.5),
    xmax = c(6.5, 8.5, 13.5, 16.5, 22.5),
    ymin = 0,
    ymax = max(data$max, na.rm = TRUE) + 0.6,
    alpha = 0.2,
    fill = rev(unique(data$group_col))
  ) +
  ggplot2::scale_y_continuous(expand = c(0, 0)) +
  ggplot2::xlab("") +
  ggplot2::ylab("Regression Coefficient (95% CI)") +
  ggplot2::theme_bw() +
  ggplot2::theme(axis.text.x = ggplot2::element_text(color = rev(unique(data$group_col)))) +
  ggplot2::coord_flip()

ggplot2::ggsave(out_file, p, width = 8.5, height = 6.5, dpi = 300)
message("Saved figure to: ", out_file)
