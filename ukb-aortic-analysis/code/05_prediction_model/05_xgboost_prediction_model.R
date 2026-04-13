source("code/00_setup/helpers.R")
check_and_load_packages(c("xgboost", "ROCR", "pROC", "ROCit", "caret", "ggplot2", "shapviz", "tibble"))
config <- load_config()
set.seed(config$seed)

if (!file.exists(config$paths$model_input_rdata)) {
  message("Prediction model input not found. Update config$paths$model_input_rdata before running this script.")
} else {
  load(config$paths$model_input_rdata)

  # Integrated directly from model.txt.
  data1 <- as.data.frame(df_filtered[, -c(332:337)])
  df_filtered <- as.data.frame(df_filtered)
  M.names2 <- M.names1[M.names1 != "thy.y"]
  M.names2 <- M.names2[M.names2 != "E033"]
  M.names3 <- M.names2
  y.names2 <- y.names[y.names != "AN_ctime"]

  for (i in y.names2) {
    data2 <- data1[!(data1[[i]] == 0 & data1$AN == 1), ]
    data3 <- df_filtered[!(df_filtered[[i]] == 0 & df_filtered$AN == 1), ]
    data_model <- data2[, colnames(data1) %in% c(M.names3, "AN_ctime", "AN")]
    data_model <- na.omit(data_model)
    data_model$AN_dia <- data_model$AN * data_model$AN_ctime

    data_model_use <- data_model
    data_model_use$AN_ctime <- ifelse(data_model_use$AN == 1, data_model_use$AN_ctime, -data_model_use$AN_ctime)
    data_model_use$AN_dia <- data_model_use$AN * data_model_use$AN_ctime
    traindata <- data_model_use

    model_xgboost <- xgboost::xgboost(
      data = as.matrix(traindata[, !colnames(traindata) %in% c("AN", "AN_ctime", "AN_dia")]),
      label = traindata$AN,
      max_depth = 5,
      eta = 0.1,
      nthread = 2,
      nrounds = 100,
      objective = "binary:logistic",
      eval_metric = "logloss",
      verbose = 0
    )

    traindata$pred <- stats::predict(model_xgboost, as.matrix(traindata[, !colnames(traindata) %in% c("AN", "AN_ctime", "AN_dia")]))
    shap_xgboost <- shapviz::shapviz(model_xgboost, X_pred = as.matrix(traindata[, !colnames(traindata) %in% c("pred", "AN_dia", "AN_ctime", "AN")]))
    ggplot2::ggsave(file.path(config$outputs$figures_dir, paste0(i, "_all_import.pdf")), shapviz::sv_waterfall(shap_xgboost, row_id = 10), width = 7, height = 5)

    importance <- xgboost::xgb.importance(model = model_xgboost)
    importance_top <- importance[1:10, ]
    data_model <- data3[, c(importance_top$Feature, "Hypo", "Notoxic", "Thyrotoxicosis", "Disorder", "AN_ctime", "AN")]
    data_model <- na.omit(data_model)
    data_model$AN_dia <- data_model$AN * data_model$AN_ctime
    data_model_use <- data_model
    data_model_use$AN_ctime <- ifelse(data_model_use$AN == 1, data_model_use$AN_ctime, -data_model_use$AN_ctime)
    data_model_use$AN_dia <- data_model_use$AN * data_model_use$AN_ctime

    inTrain <- caret::createDataPartition(y = data_model_use[, "AN"], p = 0.7, list = FALSE)
    traindata <- data_model_use[inTrain, ]
    testdata <- data_model_use[-inTrain, ]

    model_xgboost <- xgboost::xgboost(
      data = as.matrix(traindata[, !colnames(traindata) %in% c("AN", "AN_ctime", "AN_dia")]),
      label = traindata$AN,
      max_depth = 5,
      eta = 0.1,
      nthread = 2,
      nrounds = 50,
      objective = "binary:logistic",
      eval_metric = "logloss",
      verbose = 0
    )
    saveRDS(model_xgboost, file.path(config$outputs$models_dir, paste0("model_xgboost_", i, ".rds")))

    traindata$pred <- stats::predict(model_xgboost, as.matrix(traindata[, !colnames(traindata) %in% c("AN", "AN_ctime", "AN_dia")]))
    roc_obj <- pROC::roc(traindata$AN, traindata$pred)
    best_threshold <- pROC::coords(roc_obj, "best", ret = "threshold", best.method = "youden")
    best_metrics <- pROC::coords(roc_obj, x = best_threshold$threshold, ret = c("threshold", "sensitivity", "specificity", "accuracy", "ppv", "npv", "plr", "nlr"), input = "threshold", transpose = FALSE)
    best_metrics$AUC <- round(pROC::auc(response = traindata$AN, predictor = traindata$pred), 4)
    ci_train <- pROC::ci(response = traindata$AN, predictor = traindata$pred)
    best_metrics$ci <- paste0(round(ci_train[1], 3), "-", round(ci_train[3], 3))
    safe_write_csv(best_metrics, file.path(config$outputs$tables_dir, paste0("performance_train_", i, ".csv")))
    grDevices::pdf(file.path(config$outputs$figures_dir, paste0(i, "_train_roc.pdf")), 5, 5, family = "serif")
    plot(roc_obj, main = "ROC Curve (XGBoost Model)", col = "#1c61b6", lwd = 2, print.auc = TRUE, print.auc.col = "red", auc.polygon = TRUE, legacy.axes = TRUE)
    grDevices::dev.off()

    shap_xgboost <- shapviz::shapviz(model_xgboost, X_pred = as.matrix(traindata[, !colnames(traindata) %in% c("pred", "AN_dia", "AN_ctime", "AN")]))
    ggplot2::ggsave(file.path(config$outputs$figures_dir, paste0(i, "_train_fall.pdf")), shapviz::sv_waterfall(shap_xgboost, row_id = 10), width = 7, height = 5)
    ggplot2::ggsave(file.path(config$outputs$figures_dir, paste0(i, "_train_single.pdf")), shapviz::sv_force(shap_xgboost, row_id = 10), width = 7, height = 5)
    ggplot2::ggsave(file.path(config$outputs$figures_dir, paste0(i, "_train_bee.tif")), shapviz::sv_importance(shap_xgboost, kind = "beeswarm") + ggplot2::theme_bw(), width = 8, height = 6)
    ggplot2::ggsave(file.path(config$outputs$figures_dir, paste0(i, "_train_import.pdf")), shapviz::sv_importance(shap_xgboost) + ggplot2::theme_bw(), width = 8, height = 6)

    testdata$pred <- stats::predict(model_xgboost, as.matrix(testdata[, !colnames(testdata) %in% c("AN", "AN_ctime", "AN_dia")]))
    roc_test <- pROC::roc(testdata$AN, testdata$pred)
    test_metrics <- pROC::coords(roc_test, x = best_threshold$threshold, ret = c("threshold", "sensitivity", "specificity", "accuracy", "ppv", "npv", "plr", "nlr"), input = "threshold", transpose = FALSE)
    test_metrics$AUC <- round(pROC::auc(response = testdata$AN, predictor = testdata$pred), 4)
    ci_test <- pROC::ci(response = testdata$AN, predictor = testdata$pred)
    test_metrics$ci <- paste0(round(ci_test[1], 3), "-", round(ci_test[3], 3))
    safe_write_csv(test_metrics, file.path(config$outputs$tables_dir, paste0("performance_test_", i, ".csv")))
    grDevices::pdf(file.path(config$outputs$figures_dir, paste0(i, "_test_roc.pdf")), 5, 5, family = "serif")
    plot(roc_test, main = "ROC Curve (XGBoost Model)", col = "red", lwd = 2, print.auc = TRUE, print.auc.col = "red", auc.polygon = TRUE, legacy.axes = TRUE)
    grDevices::dev.off()
    message("Completed prediction model for ", i)
  }
}
