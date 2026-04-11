source(here::here("code", "00_packages.R"))

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

disease_status_df <- Total[, paste0("disease_yn_", exposure_diseases)]
Total$disease_count <- rowSums(disease_status_df == 1, na.rm = TRUE)

Total$disease_cat <- cut(
  Total$disease_count,
  breaks = c(-1, 0, 1, 2, 3, 4, 5, Inf),
  labels = c("0", "1", "2", "3", "4", "5", "≥6"),
  right = TRUE
)

Total$multimorbidity <- ifelse(Total$disease_count >= 2, 1, 0)

data_multi <- na.omit(Total[, c(
  "AN_status", "AN_ctime", "disease_count", "disease_cat", "multimorbidity",
  "bmi_calc", "alcohol_category", "age_at_study_date",
  "region_code", "highest_education", "household_income",
  "met", "is_female", "smoking_category"
)])

data_multi$is_female <- as.factor(data_multi$is_female)
data_multi$region_code <- as.factor(data_multi$region_code)
data_multi$highest_education <- as.factor(data_multi$highest_education)
data_multi$alcohol_category <- as.factor(data_multi$alcohol_category)
data_multi$household_income <- as.factor(data_multi$household_income)
data_multi$smoking_category <- as.factor(data_multi$smoking_category)

model1 <- survival::coxph(
  survival::Surv(AN_ctime, AN_status) ~ multimorbidity + bmi_calc + alcohol_category +
    age_at_study_date + region_code + highest_education +
    household_income + met + is_female + smoking_category,
  data = data_multi
)

coef1 <- summary(model1)$coefficients["multimorbidity", ]
result1 <- data.frame(
  exposure = "Multimorbidity (≥2 vs 0-1)",
  n = nrow(data_multi),
  n_exposed = sum(data_multi$multimorbidity == 1),
  n_event = sum(data_multi$AN_status == 1),
  HR = exp(coef1[1]),
  HR_lower = exp(coef1[1] - 1.96 * coef1[3]),
  HR_upper = exp(coef1[1] + 1.96 * coef1[3]),
  p_value = coef1[5]
)

model2 <- survival::coxph(
  survival::Surv(AN_ctime, AN_status) ~ disease_count + bmi_calc + alcohol_category +
    age_at_study_date + region_code + highest_education +
    household_income + met + is_female + smoking_category,
  data = data_multi
)

coef2 <- summary(model2)$coefficients["disease_count", ]
result2 <- data.frame(
  exposure = "Disease count (per 1 condition)",
  n = nrow(data_multi),
  n_event = sum(data_multi$AN_status == 1),
  HR = exp(coef2[1]),
  HR_lower = exp(coef2[1] - 1.96 * coef2[3]),
  HR_upper = exp(coef2[1] + 1.96 * coef2[3]),
  p_value = coef2[5]
)

model3 <- survival::coxph(
  survival::Surv(AN_ctime, AN_status) ~ disease_cat + bmi_calc + alcohol_category +
    age_at_study_date + region_code + highest_education +
    household_income + met + is_female + smoking_category,
  data = data_multi
)

coef3 <- summary(model3)$coefficients
result3 <- data.frame(
  disease_count = gsub("disease_cat", "", rownames(coef3)),
  HR = exp(coef3[, 1]),
  HR_lower = exp(coef3[, 1] - 1.96 * coef3[, 3]),
  HR_upper = exp(coef3[, 1] + 1.96 * coef3[, 3]),
  p_value = coef3[, 5]
)

data_multi$trend_score <- as.numeric(data_multi$disease_cat) - 1
model4 <- survival::coxph(
  survival::Surv(AN_ctime, AN_status) ~ trend_score + bmi_calc + alcohol_category +
    age_at_study_date + region_code + highest_education +
    household_income + met + is_female + smoking_category,
  data = data_multi
)

coef4 <- summary(model4)$coefficients["trend_score", ]
result4 <- data.frame(
  analysis = "Trend test (per category increase)",
  HR = exp(coef4[1]),
  HR_lower = exp(coef4[1] - 1.96 * coef4[3]),
  HR_upper = exp(coef4[1] + 1.96 * coef4[3]),
  p_trend = coef4[5]
)

write.csv(result1, here::here("results", "multimorbidity_binary.csv"), row.names = FALSE)
write.csv(result2, here::here("results", "disease_count_continuous.csv"), row.names = FALSE)
write.csv(result3, here::here("results", "disease_count_categorical.csv"), row.names = FALSE)
write.csv(result4, here::here("results", "trend_test.csv"), row.names = FALSE)

save(Total, file = here::here("results", "Total.RData"))
