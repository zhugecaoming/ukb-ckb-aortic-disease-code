source(here::here("code", "00_packages.R"))
source(here::here("code", "utils_disease_classification.R"))

load(here::here("results", "Total.RData"))  # Total

exposure_diseases <- c(
  "Cancer", "Hypertension", "COPD", "Coronary heart disease", "Diabetes",
  "Stroke and TIA", "Chronic fatigue syndrome", "Chronic liver disease",
  "Osteoporosis", "Thyroid disorders", "Chronic kidney disease", "RA-OIP-SCTD",
  "Chronic sinusitis", "Endometriosis", "Prostate disorders", "Heart failure",
  "Treated constipation", "Atrial fibrillation", "Glaucoma", "Bronchiectasis",
  "ANSS", "Parkinson's disease", "Asthma", "Depression", "Migraine",
  "Treated dyspepsia", "Alcohol problems", "Peripheral vascular disease",
  "Pernicious anaemia", "Viral hepatitis", "Inflammatory bowel disease",
  "Schizophrenia or BD", "Epilepsy", "Multiple sclerosis",
  "Diverticular disease of intestine", "Meniere's disease", "Painful condition",
  "Irritable bowel syndrome", "Psoriasis or eczema", "Anorexia or bulimia",
  "OPSM", "Polycystic ovary"
)

outcomes <- c("AS", "DIS", "TAA", "AAA", "OAA", "AN")

Total$study_date <- as.Date(Total$study_date)

for (out in outcomes) {
  date_col <- paste0(out, "_date")
  if (date_col %in% names(Total)) {
    Total[[date_col]] <- as.Date(Total[[date_col]])
  }
}

for (exp in exposure_diseases) {
  date_col <- paste0("disease_date_", exp)
  if (date_col %in% names(Total)) {
    Total[[date_col]] <- to_date(Total[[date_col]])
  }
}

for (outcome in outcomes) {
  status_var <- paste0(outcome, "_status")
  if (status_var %in% names(Total)) {
    Total[[status_var]] <- as.numeric(Total[[status_var]])
  }
}

for (exp in exposure_diseases) {
  status_var <- paste0("disease_yn_", exp)
  if (status_var %in% names(Total)) {
    Total[[status_var]] <- as.numeric(Total[[status_var]])
  }
}

results <- list()

for (exposure in exposure_diseases) {
  for (outcome in outcomes) {
    cat("分析:", exposure, "→", outcome, "\n")

    exposure_col <- paste0("disease_yn_", exposure)
    exposure_date_col <- paste0("disease_date_", exposure)
    outcome_status_col <- paste0(outcome, "_status")
    outcome_time_col <- paste0(outcome, "_ctime")

    if (!exposure_col %in% names(Total)) next
    if (!exposure_date_col %in% names(Total)) next
    if (!outcome_status_col %in% names(Total)) next
    if (!outcome_time_col %in% names(Total)) next

    analysis_data <- Total[, c(
      "csid", "study_date",
      "bmi_calc", "alcohol_category", "age_at_study_date",
      "region_code", "highest_education", "household_income",
      "met", "is_female", "smoking_category",
      exposure_col, exposure_date_col,
      outcome_status_col, outcome_time_col
    )]

    names(analysis_data)[names(analysis_data) == exposure_col] <- "exposure_status"
    names(analysis_data)[names(analysis_data) == exposure_date_col] <- "exposure_date"
    names(analysis_data)[names(analysis_data) == outcome_status_col] <- "outcome_status"
    names(analysis_data)[names(analysis_data) == outcome_time_col] <- "outcome_time"

    analysis_data$exposure_date <- as.Date(analysis_data$exposure_date)

    idx_both <- analysis_data$exposure_status == 1 & analysis_data$outcome_status == 1

    if (any(idx_both, na.rm = TRUE)) {
      analysis_data$outcome_date <- analysis_data$study_date + analysis_data$outcome_time * 7
      invalid_order <- idx_both & analysis_data$exposure_date >= analysis_data$outcome_date
      n_invalid <- sum(invalid_order, na.rm = TRUE)

      if (n_invalid > 0) {
        cat("  排除暴露发生在结局之后的样本:", n_invalid, "\n")
        analysis_data <- analysis_data[!invalid_order, ]
      }
    }

    vars_for_analysis <- c(
      "exposure_status", "outcome_status", "outcome_time",
      "bmi_calc", "alcohol_category", "age_at_study_date",
      "region_code", "highest_education", "household_income",
      "met", "is_female", "smoking_category"
    )

    analysis_data <- na.omit(analysis_data[, vars_for_analysis])

    analysis_data$is_female <- as.factor(analysis_data$is_female)
    analysis_data$region_code <- as.factor(analysis_data$region_code)
    analysis_data$highest_education <- as.factor(analysis_data$highest_education)
    analysis_data$alcohol_category <- as.factor(analysis_data$alcohol_category)
    analysis_data$smoking_category <- as.factor(analysis_data$smoking_category)
    analysis_data$household_income <- as.factor(analysis_data$household_income)
    analysis_data$outcome_status <- as.numeric(analysis_data$outcome_status)
    analysis_data$outcome_time <- as.numeric(analysis_data$outcome_time)
    analysis_data$exposure_status <- as.numeric(analysis_data$exposure_status)

    n_total <- nrow(analysis_data)
    n_exposed <- sum(analysis_data$exposure_status == 1, na.rm = TRUE)
    n_outcome <- sum(analysis_data$outcome_status == 1, na.rm = TRUE)

    if (n_total < 10) next
    if (n_exposed < 5) next
    if (n_outcome < 5) next

    formula <- as.formula(paste0(
      "survival::Surv(outcome_time, outcome_status) ~ ",
      "exposure_status + ",
      "bmi_calc + ",
      "alcohol_category + ",
      "age_at_study_date + ",
      "region_code + ",
      "highest_education + ",
      "household_income + ",
      "met + ",
      "is_female + ",
      "smoking_category"
    ))

    model <- tryCatch(
      survival::coxph(formula, data = analysis_data),
      error = function(e) {
        cat("  模型拟合失败:", e$message, "\n")
        return(NULL)
      }
    )

    if (is.null(model)) next

    model_summary <- summary(model)

    if (!"exposure_status" %in% rownames(model_summary$coefficients)) next

    exposure_coef <- model_summary$coefficients["exposure_status", ]

    result_row <- data.frame(
      exposure = exposure,
      outcome = outcome,
      n = n_total,
      n_exposed = n_exposed,
      n_outcome = n_outcome,
      HR = exp(exposure_coef[1]),
      HR_lower = exp(exposure_coef[1] - 1.96 * exposure_coef[3]),
      HR_upper = exp(exposure_coef[1] + 1.96 * exposure_coef[3]),
      p_value = exposure_coef[5],
      stringsAsFactors = FALSE
    )

    results[[paste(exposure, outcome, sep = "_")]] <- result_row
  }
}

results_all <- do.call(rbind, results)
results_all$p_fdr <- p.adjust(results_all$p_value, method = "fdr")

write.csv(results_all, here::here("results", "cox_results.csv"), row.names = FALSE)
save(results_all, file = here::here("results", "cox_results.RData"))
