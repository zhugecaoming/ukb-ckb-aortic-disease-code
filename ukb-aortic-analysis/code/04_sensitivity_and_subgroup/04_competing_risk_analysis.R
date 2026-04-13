source("code/00_setup/helpers.R")
check_and_load_packages()
config <- load_config()

main_path <- file.path(config$outputs$tables_dir, "analysis_dataset_main.csv")
if (!file.exists(main_path)) {
  stop("Run code/03_primary_analysis/03_aortic_disease_main_analysis.R first.")
}
merge3 <- utils::read.csv(main_path)

death_all <- data.table::fread(config$paths$death_allcause_csv, sep = ",", header = TRUE, stringsAsFactors = FALSE)
death_1 <- build_allcause_death(death_all)
merge4 <- merge(merge3, death_1, by = "eid", all.x = TRUE)
merge4$death_date[is.na(merge4$death_date)] <- config$analysis$death_censor_fallback
merge4$death_date <- as.Date(merge4$death_date)
merge4$AN_date <- as.Date(merge4$AN_date)
merge4$data_attending <- as.Date(merge4$data_attending)
merge4 <- merge4 %>%
  dplyr::mutate(
    time = as.numeric(difftime(pmin(death_date, AN_date, na.rm = TRUE), data_attending, units = "days") / 365.25),
    status = dplyr::case_when(
      AN == 1 & death == 1 ~ 1,
      AN == 1 ~ 1,
      death == 1 ~ 2,
      TRUE ~ 0
    )
  )

exposure_var <- if ("hyp" %in% names(merge4)) "hyp" else config$analysis$disease_exposures[[1]]
if (!paste0(exposure_var, "_date") %in% names(merge4)) {
  stop("Exposure date column not found for competing risk example: ", exposure_var)
}
merge4 <- remove_reverse_time_order(merge4, exposure_var, paste0(exposure_var, "_date"), "AN_date")

analysis_data <- merge4 %>%
  dplyr::select(eid, time, status, dplyr::all_of(exposure_var), age_base, sex, centre, race, edu, smoke, BMI, drink, income, MET) %>%
  stats::na.omit() %>%
  dplyr::mutate(
    sex = as.factor(sex),
    centre = as.factor(centre),
    race = as.factor(race),
    edu = as.factor(edu),
    smoke = as.factor(smoke),
    drink = as.factor(drink),
    income = as.factor(income),
    grp_met = factor(categorize_met(MET))
  )

formula <- as.formula(paste0("riskRegression::Hist(time, status) ~ ", exposure_var, " + sex + age_base + centre + race + edu + smoke + BMI + drink + income + grp_met"))
model_csc <- riskRegression::CSC(formula = formula, data = analysis_data, cause = 1)
summary_table <- capture.output(summary(model_csc))
writeLines(summary_table, con = file.path(config$outputs$tables_dir, "competing_risk_model_summary.txt"))
message("Saved: competing_risk_model_summary.txt")
