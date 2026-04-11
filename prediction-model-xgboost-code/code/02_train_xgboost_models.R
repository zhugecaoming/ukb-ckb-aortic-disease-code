source("code/helpers.R")
source("code/01_prepare_data.R")

run_prediction_pipeline <- function(cfg) {
  set.seed(cfg$seed)

  ensure_dir(cfg$output$results_dir)
  ensure_dir(cfg$output$models_dir)

  prepared <- prepare_model_inputs(cfg)
  df_filtered <- prepared$df_filtered
  data1 <- prepared$data1
  predictor_pool <- prepared$predictor_pool
  outcome_names <- prepared$outcome_names

  outcome_binary <- cfg$variables$outcome_binary
  outcome_time <- cfg$variables$outcome_time
  fixed_covariates <- unlist(cfg$variables$fixed_covariates)
  excluded_outcomes <- unlist(cfg$variables$exclude_outcome_from_loop)
  y.names2 <- outcome_names[!outcome_names %in% excluded_outcomes]

  summary_rows <- list()

  for (i in y.names2) {
    message("Running model for phenotype: ", i)

    data2 <- data1[!(data1[[i]] == 0 & data1[[outcome_binary]] == 1), , drop = FALSE]
    data3 <- df_filtered[!(df_filtered[[i]] == 0 & df_filtered[[outcome_binary]] == 1), , drop = FALSE]

    initial_cols <- c(predictor_pool, outcome_time, outcome_binary)
    initial_cols <- initial_cols[initial_cols %in% colnames(data2)]
    data_model <- data2[, initial_cols, drop = FALSE]
    data_model <- na.omit(data_model)

    data_model$AN_dia <- data_model[[outcome_binary]] * data_model[[outcome_time]]
    data_model_use <- data_model
    data_model_use[[outcome_time]] <- ifelse(
      data_model_use[[outcome_binary]] == 1,
      data_model_use[[outcome_time]],
      -data_model_use[[outcome_time]]
    )
    data_model_use$AN_dia <- data_model_use[[outcome_binary]] * data_model_use[[outcome_time]]

    screening_model <- xgboost::xgboost(
      data = as.matrix(data_model_use[, !colnames(data_model_use) %in% c(outcome_binary, outcome_time, "AN_dia")]),
      label = data_model_use[[outcome_binary]],
      max_depth = cfg$model$max_depth,
      eta = cfg$model$eta,
      nthread = cfg$model$nthread,
      nrounds = cfg$model$nrounds_screening,
      objective = cfg$model$objective,
      eval_metric = cfg$model$eval_metric,
      verbose = 0
    )

    data_model_use$pred <- predict(screening_model, as.matrix(data_model_use[, !colnames(data_model_use) %in% c(outcome_binary, outcome_time, "AN_dia")]))

    shap_obj_all <- shapviz::shapviz(
      screening_model,
      X_pred = as.matrix(data_model_use[, !colnames(data_model_use) %in% c("pred", "AN_dia", outcome_time, outcome_binary)])
    )
    p_all <- shapviz::sv_waterfall(shap_obj_all, row_id = cfg$variables$waterfall_row_id)
    ggsave(file.path(cfg$output$results_dir, paste0(i, "_all_import.pdf")), p_all)

    importance <- xgboost::xgb.importance(model = screening_model)
    top_n <- min(cfg$model$top_n_features, nrow(importance))
    importance_top <- importance[seq_len(top_n), , drop = FALSE]
    selected_features <- unique(c(importance_top$Feature, fixed_covariates, outcome_time, outcome_binary))
    selected_features <- selected_features[selected_features %in% colnames(data3)]

    final_data <- data3[, selected_features, drop = FALSE]
    final_data <- na.omit(final_data)
    final_data$AN_dia <- final_data[[outcome_binary]] * final_data[[outcome_time]]
    final_data_use <- final_data
    final_data_use[[outcome_time]] <- ifelse(
      final_data_use[[outcome_binary]] == 1,
      final_data_use[[outcome_time]],
      -final_data_use[[outcome_time]]
    )
    final_data_use$AN_dia <- final_data_use[[outcome_binary]] * final_data_use[[outcome_time]]

    inTrain <- caret::createDataPartition(y = final_data_use[[outcome_binary]], p = cfg$model$train_fraction, list = FALSE)
    traindata <- final_data_use[inTrain, , drop = FALSE]
    testdata <- final_data_use[-inTrain, , drop = FALSE]

    final_model <- xgboost::xgboost(
      data = as.matrix(traindata[, !colnames(traindata) %in% c(outcome_binary, outcome_time, "AN_dia")]),
      label = traindata[[outcome_binary]],
      max_depth = cfg$model$max_depth,
      eta = cfg$model$eta,
      nthread = cfg$model$nthread,
      nrounds = cfg$model$nrounds_final,
      objective = cfg$model$objective,
      eval_metric = cfg$model$eval_metric,
      verbose = 0
    )

    saveRDS(final_model, file.path(cfg$output$models_dir, paste0("model_xgboost_", i, ".rds")))

    traindata$pred <- predict(final_model, as.matrix(traindata[, !colnames(traindata) %in% c(outcome_binary, outcome_time, "AN_dia")]))
    train_auc <- compute_auc_metrics(traindata[[outcome_binary]], traindata$pred)
    train_roc <- save_roc_plot(traindata[[outcome_binary]], traindata$pred, file.path(cfg$output$results_dir, paste0(i, "_train_roc.pdf")))
    best_threshold <- pROC::coords(train_roc, "best", ret = "threshold", best.method = "youden")
    train_metrics <- compute_threshold_metrics(train_roc, best_threshold$threshold)
    train_metrics$AUC <- train_auc$auc
    train_metrics$ci <- paste0(round(train_auc$ci_lower, 3), "-", round(train_auc$ci_upper, 3))
    write.csv(train_metrics, file.path(cfg$output$results_dir, paste0("performance_train_", i, ".csv")), row.names = FALSE)

    make_shap_outputs(final_model, traindata, i, cfg$output$results_dir, row_id = cfg$variables$waterfall_row_id)

    testdata$pred <- predict(final_model, as.matrix(testdata[, !colnames(testdata) %in% c(outcome_binary, outcome_time, "AN_dia")]))
    test_auc <- compute_auc_metrics(testdata[[outcome_binary]], testdata$pred)
    test_roc <- save_roc_plot(testdata[[outcome_binary]], testdata$pred, file.path(cfg$output$results_dir, paste0(i, "_test_roc.pdf")), curve_color = "red")
    test_metrics <- compute_threshold_metrics(test_roc, best_threshold$threshold)
    test_metrics$AUC <- test_auc$auc
    test_metrics$ci <- paste0(round(test_auc$ci_lower, 3), "-", round(test_auc$ci_upper, 3))
    write.csv(test_metrics, file.path(cfg$output$results_dir, paste0("performance_test_", i, ".csv")), row.names = FALSE)

    summary_rows[[i]] <- data.frame(
      phenotype = i,
      train_auc = train_auc$auc,
      test_auc = test_auc$auc,
      n_train = nrow(traindata),
      n_test = nrow(testdata),
      stringsAsFactors = FALSE
    )

    message("Completed model for phenotype: ", i)
  }

  if (length(summary_rows) > 0) {
    summary_df <- do.call(rbind, summary_rows)
    write.csv(summary_df, file.path(cfg$output$results_dir, "model_summary.csv"), row.names = FALSE)
  }
}
