source(here::here("code", "00_packages.R"))

load(here::here("results", "events_data_earliest.RData"))  # expects object: events_data_earliest

outcome_data <- events_data_earliest[, c("csid", "datedeveloped", "diagnosis", "diagnosis_main")]

aortic_diseases <- list(
  AS = list(name = "atherosclerosis", codes = c("I70.0")),
  DIS = list(name = "dissection", codes = c("I71.0")),
  TAA = list(name = "thoracic_aneurysm", codes = c("I71.1", "I71.2")),
  AAA = list(name = "abdominal_aneurysm", codes = c("I71.3", "I71.4")),
  OAA = list(name = "other_aneurysm", codes = c("I71.5", "I71.6", "I71.8", "I71.9")),
  IAS = list(name = "inflammatory_syndrome", codes = c("M31.4"))
)

outcome_data$datedeveloped <- as.Date(outcome_data$datedeveloped)
result <- data.frame(csid = unique(outcome_data$csid))

for (disease_code in names(aortic_diseases)) {
  disease_codes <- aortic_diseases[[disease_code]]$codes
  disease_records <- outcome_data[outcome_data$diagnosis %in% disease_codes, ]

  if (nrow(disease_records) > 0) {
    earliest_dates <- disease_records %>%
      dplyr::group_by(csid) %>%
      dplyr::summarise(
        !!paste0(disease_code, "_date") := min(datedeveloped, na.rm = TRUE),
        .groups = "drop"
      )
    result <- dplyr::left_join(result, earliest_dates, by = "csid")
  } else {
    result[[paste0(disease_code, "_date")]] <- NA
  }

  date_col <- paste0(disease_code, "_date")
  status_col <- paste0(disease_code, "_status")
  result[[status_col]] <- as.numeric(!is.na(result[[date_col]]))
}

censoring_date <- as.Date("2022-12-31")

for (disease_code in names(aortic_diseases)) {
  date_col <- paste0(disease_code, "_date")
  result[[date_col]][is.na(result[[date_col]])] <- censoring_date
}

for (disease_code in names(aortic_diseases)) {
  status_col <- paste0(disease_code, "_status")
  n_cases <- sum(result[[status_col]] == 1, na.rm = TRUE)
  cat(disease_code, ":", n_cases, "cases\n")
}

save(result, file = here::here("results", "aortic_disease_outcomes.RData"))
