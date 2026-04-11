source(here::here("code", "00_packages.R"))

load(here::here("data-raw", "baseline_data.RData"))               # baseline_data
load(here::here("results", "final_events.RData"))                 # final_events
load(here::here("results", "aortic_disease_outcomes.RData"))      # result

baseline_exp <- merge(baseline_data, final_events, by = "csid", all = TRUE)

baseline_exp <- baseline_exp %>%
  dplyr::mutate(dplyr::across(dplyr::starts_with("disease_yn_"), ~ ifelse(is.na(.), 0, .)))

baseline_exp <- baseline_exp %>%
  dplyr::mutate(
    `disease_yn_Hypertension` = ifelse(hypertension_diag == 1, 1, `disease_yn_Hypertension`),
    `disease_date_Hypertension` = ifelse(hypertension_diag == 1, study_date, `disease_date_Hypertension`),

    `disease_yn_Cancer` = ifelse(cancer_diag == 1, 1, `disease_yn_Cancer`),
    `disease_date_Cancer` = ifelse(cancer_diag == 1, study_date, `disease_date_Cancer`),

    `disease_yn_Asthma` = ifelse(asthma_diag == 1, 1, `disease_yn_Asthma`),
    `disease_date_Asthma` = ifelse(asthma_diag == 1, study_date, `disease_date_Asthma`),

    `disease_yn_Coronary heart disease` = ifelse(chd_diag == 1, 1, `disease_yn_Coronary heart disease`),
    `disease_date_Coronary heart disease` = ifelse(chd_diag == 1, study_date, `disease_date_Coronary heart disease`),

    `disease_yn_Diabetes` = ifelse(has_diabetes == 1, 1, `disease_yn_Diabetes`),
    `disease_date_Diabetes` = ifelse(has_diabetes == 1, study_date, `disease_date_Diabetes`),

    `disease_yn_RA-OIP-SCTD` = ifelse(rheum_arthritis_diag == 1, 1, `disease_yn_RA-OIP-SCTD`),
    `disease_date_RA-OIP-SCTD` = ifelse(rheum_arthritis_diag == 1, study_date, `disease_date_RA-OIP-SCTD`),

    `disease_yn_Stroke and TIA` = ifelse(stroke_or_tia_diag == 1, 1, `disease_yn_Stroke and TIA`),
    `disease_date_Stroke and TIA` = ifelse(stroke_or_tia_diag == 1, study_date, `disease_date_Stroke and TIA`),

    `disease_yn_COPD` = ifelse(has_copd == 1, 1, `disease_yn_COPD`),
    `disease_date_COPD` = ifelse(has_copd == 1, study_date, `disease_date_COPD`),

    `disease_yn_Chronic kidney disease` = ifelse(kidney_dis_diag == 1, 1, `disease_yn_Chronic kidney disease`),
    `disease_date_Chronic kidney disease` = ifelse(kidney_dis_diag == 1, study_date, `disease_date_Chronic kidney disease`),

    `disease_yn_Chronic liver disease` = ifelse(cirrhosis_hep_diag == 1, 1, `disease_yn_Chronic liver disease`),
    `disease_date_Chronic liver disease` = ifelse(cirrhosis_hep_diag == 1, study_date, `disease_date_Chronic liver disease`)
  )

save(baseline_exp, file = here::here("results", "baseline_exp.RData"))

Total <- merge(baseline_exp, result, by = "csid", all = TRUE)
diseases <- c("AS", "DIS", "TAA", "AAA", "OAA", "IAS")

for (disease in diseases) {
  status_col <- paste0(disease, "_status")
  Total[[status_col]][is.na(Total[[status_col]])] <- 0
}

censoring_date <- as.Date("2022-12-31")

for (disease in diseases) {
  date_col <- paste0(disease, "_date")
  status_col <- paste0(disease, "_status")

  Total[[date_col]][is.na(Total[[date_col]])] <- censoring_date
  Total[[date_col]][Total[[status_col]] == 0] <- censoring_date

  inconsistent <- sum(Total[[status_col]] == 1 & Total[[date_col]] == censoring_date, na.rm = TRUE)
  if (inconsistent > 0) {
    cat("Warning:", disease, "has", inconsistent, "cases with status=1 but date=censoring\n")
  }
}

for (disease in diseases) {
  status_col <- paste0(disease, "_status")
  date_col <- paste0(disease, "_date")
  problem_idx <- which(Total[[status_col]] == 1 & Total[[date_col]] == censoring_date)

  if (length(problem_idx) > 0) {
    cat(disease, ": Converting", length(problem_idx), "inconsistent cases from event to non-event\n")
    Total[[status_col]][problem_idx] <- 0
  }
}

Total$study_date <- as.Date(Total$study_date)

for (disease in diseases) {
  date_col <- paste0(disease, "_date")
  time_col <- paste0(disease, "_ctime")
  Total[[time_col]] <- as.numeric(difftime(Total[[date_col]], Total$study_date, units = "weeks"))
}

Total$AN_status <- as.numeric(
  Total$AS_status == 1 |
    Total$DIS_status == 1 |
    Total$TAA_status == 1 |
    Total$AAA_status == 1 |
    Total$OAA_status == 1 |
    Total$IAS_status == 1
)

Total$AN_date <- pmin(
  Total$AS_date, Total$DIS_date, Total$TAA_date,
  Total$AAA_date, Total$OAA_date, Total$IAS_date,
  na.rm = TRUE
)

Total$AN_ctime <- as.numeric(difftime(Total$AN_date, Total$study_date, units = "weeks"))

save(Total, file = here::here("results", "Total.RData"))
