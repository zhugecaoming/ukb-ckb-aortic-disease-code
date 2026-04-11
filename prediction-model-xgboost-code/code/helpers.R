suppressPackageStartupMessages({
  library(ggplot2)
  library(pROC)
  library(ROCit)
  library(tibble)
  library(caret)
  library(shapviz)
})

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
}

save_roc_plot <- function(labels, preds, file_path, curve_color = "#1c61b6") {
  roc_obj <- pROC::roc(labels, preds)
  pdf(file_path, 5, 5, family = "serif")
  plot(
    roc_obj,
    main = "ROC Curve (XGBoost Model)",
    col = curve_color,
    lwd = 2,
    print.auc = TRUE,
    print.auc.col = "red",
    auc.polygon = TRUE,
    legacy.axes = TRUE
  )
  dev.off()
  invisible(roc_obj)
}

compute_auc_metrics <- function(labels, preds) {
  auc_val <- round(pROC::auc(response = labels, predictor = preds), 4)
  ci_val <- pROC::ci.auc(response = labels, predictor = preds)
  list(
    auc = auc_val,
    ci_lower = unname(ci_val[1]),
    ci_mid = unname(ci_val[2]),
    ci_upper = unname(ci_val[3])
  )
}

format_auc_ci <- function(x) {
  paste0(
    "AUC=", round(x$ci_mid, 3),
    ", 95% CI (", round(x$ci_lower, 3), "-", round(x$ci_upper, 3), ")"
  )
}

compute_threshold_metrics <- function(roc_obj, threshold) {
  pROC::coords(
    roc_obj,
    x = threshold,
    ret = c(
      "threshold", "sensitivity", "specificity", "accuracy",
      "ppv", "npv", "plr", "nlr"
    ),
    input = "threshold",
    transpose = FALSE
  )
}

make_shap_outputs <- function(model, train_df, output_prefix, results_dir, row_id = 10) {
  pred_matrix <- as.matrix(train_df[, !colnames(train_df) %in% c("pred", "AN_dia", "AN_ctime", "AN")])
  shap_obj <- shapviz::shapviz(model, X_pred = pred_matrix)

  p_waterfall <- shapviz::sv_waterfall(shap_obj, row_id = row_id)
  ggsave(file.path(results_dir, paste0(output_prefix, "_train_fall.pdf")), p_waterfall)

  p_force <- shapviz::sv_force(shap_obj, row_id = row_id)
  ggsave(file.path(results_dir, paste0(output_prefix, "_train_single.pdf")), p_force)

  p_bee <- shapviz::sv_importance(shap_obj, kind = "beeswarm") + theme_bw()
  ggsave(file.path(results_dir, paste0(output_prefix, "_train_bee.tif")), p_bee)

  p_import <- shapviz::sv_importance(shap_obj) + theme_bw()
  ggsave(file.path(results_dir, paste0(output_prefix, "_train_import.pdf")), p_import)

  invisible(shap_obj)
}
