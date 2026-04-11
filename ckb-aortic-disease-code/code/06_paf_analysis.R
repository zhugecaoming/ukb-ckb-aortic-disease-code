source(here::here("code", "00_packages.R"))

load(here::here("results", "Total.RData"))  # Total

if (!"multimorbidity" %in% names(Total)) {
  stop("Variable `multimorbidity` not found in Total. Run code/05_multimorbidity_analysis.R first.")
}

data_paf <- na.omit(Total[, c(
  "AN_status", "AN_ctime", "multimorbidity",
  "bmi_calc", "alcohol_category", "age_at_study_date",
  "region_code", "highest_education", "household_income",
  "met", "is_female", "smoking_category"
)])

data_paf$is_female <- as.factor(data_paf$is_female)
data_paf$region_code <- as.factor(data_paf$region_code)
data_paf$highest_education <- as.factor(data_paf$highest_education)
data_paf$alcohol_category <- as.factor(data_paf$alcohol_category)
data_paf$household_income <- as.factor(data_paf$household_income)
data_paf$smoking_category <- as.factor(data_paf$smoking_category)

model <- survival::coxph(
  survival::Surv(AN_ctime, AN_status) ~ multimorbidity + bmi_calc + alcohol_category +
    age_at_study_date + region_code + highest_education +
    household_income + met + is_female + smoking_category,
  data = data_paf
)

coef_exp <- coef(model)["multimorbidity"]
prev <- mean(data_paf$multimorbidity == 1, na.rm = TRUE)

paf <- 1 - (1 / (1 + prev * (exp(coef_exp) - 1)))
var_coef <- vcov(model)["multimorbidity", "multimorbidity"]
se_paf <- sqrt(var_coef * (prev * exp(coef_exp) / (1 + prev * (exp(coef_exp) - 1))^2)^2)
paf_lower <- paf - 1.96 * se_paf
paf_upper <- paf + 1.96 * se_paf

result_paf <- data.frame(
  exposure = "Multimorbidity (≥2 conditions)",
  prevalence = prev,
  HR = exp(coef_exp),
  PAF = paf,
  PAF_lower = paf_lower,
  PAF_upper = paf_upper
)

print(result_paf)
write.csv(result_paf, here::here("results", "paf_multimorbidity.csv"), row.names = FALSE)
