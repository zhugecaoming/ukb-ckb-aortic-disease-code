# 06_run_multimorbidity_models.R
# Reproduce the multimorbidity analysis described in the Methods.

source("scripts/helpers.R")
install_missing_packages()
load_required_packages()
cfg <- read_config()

ensure_dir(cfg$results_dir)

analysis_df <- safe_fread(file.path(cfg$data_processed_dir, "ukb_analysis_dataset.csv"))
disease_map <- read.csv("data_dictionary/chronic_conditions_42.csv", stringsAsFactors = FALSE)

available_diseases <- intersect(disease_map$disease_code, names(analysis_df))
available_dates <- intersect(disease_map$event_date_column, names(analysis_df))

merge4 <- as.data.table(analysis_df)

# In the original script, multimorbidity was ultimately calculated from a 22-condition subset.
multimorbidity_subset <- intersect(
  c("hyp","cancer","asthma","dyspepsia","CHD","thy","RA","stroke","osteoporosis","COPD",
    "migraine","IBS","DDI","AF","bronch","CFS","PVD","CKD","CLD","HF","AP","TC"),
  names(merge4)
)

if (length(multimorbidity_subset) == 0) {
  stop("No multimorbidity variables from the original subset were found in the analysis dataset.")
}

merge4[, multimorbidity_raw := rowSums(.SD, na.rm = TRUE), .SDcols = multimorbidity_subset]
merge4[, multimorbidity := ifelse(multimorbidity_raw > 6, 6, ifelse(multimorbidity_raw < 1, 0, multimorbidity_raw))]

dat <- merge4 %>%
  dplyr::select(eid, age_base, sex, centre, race, edu, smoke, BMI, drink, income, AN_ctime, AN, MET, multimorbidity) %>%
  dplyr::mutate(
    sex = factor(sex),
    centre = factor(centre),
    race = factor(race),
    edu = factor(edu),
    smoke = factor(smoke),
    drink = factor(drink),
    income = factor(income),
    grp_met = categorize_met(MET),
    multimorbidity = factor(multimorbidity),
    AN = as.numeric(AN)
  ) %>%
  dplyr::select(-MET) %>%
  tidyr::drop_na()

fit <- survival::coxph(
  survival::Surv(AN_ctime, AN) ~ multimorbidity * sex + BMI + drink + age_base + centre + race + edu + smoke + income + grp_met,
  data = dat,
  ties = "breslow"
)

capture.output(summary(fit), file = file.path(cfg$results_dir, "multimorbidity_model_summary.txt"))
write.csv(dat, file.path(cfg$results_dir, "multimorbidity_analysis_dataset.csv"), row.names = FALSE)
message("Saved multimorbidity results to results/.")
