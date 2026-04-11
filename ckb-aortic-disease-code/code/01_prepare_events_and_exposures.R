source(here::here("code", "00_packages.R"))
source(here::here("code", "utils_disease_classification.R"))

# Load input data -----------------------------------------------------------

load(here::here("data-raw", "baseline_data.RData"))  # expects object: baseline_data
load(here::here("data-raw", "events_data.RData"))    # expects object: events_data

# Prepare event data --------------------------------------------------------

events_data <- events_data[events_data$csid %in% baseline_data$csid, ]
events_data <- events_data[, c("csid", "datedeveloped", "diagnosis")]

events_data$datedeveloped <- as.Date(events_data$datedeveloped)

events_data_clean <- events_data %>%
  dplyr::distinct(csid, diagnosis, datedeveloped, .keep_all = TRUE) %>%
  dplyr::group_by(csid, diagnosis) %>%
  dplyr::arrange(datedeveloped) %>%
  dplyr::slice(1) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(
    diagnosis_main = sub("\\..*", "", diagnosis),
    diagnosis_full = diagnosis
  )

events_data_earliest <- events_data_clean %>%
  dplyr::mutate(disease_name = classify_disease(diagnosis_full, diagnosis_main))

patient_diseases <- events_data_earliest %>%
  dplyr::filter(disease_name != "Other") %>%
  dplyr::group_by(csid, disease_name) %>%
  dplyr::summarise(diagnosis_date = min(datedeveloped), .groups = "drop")

final_events_data <- patient_diseases %>%
  tidyr::pivot_wider(
    id_cols = csid,
    names_from = disease_name,
    values_from = diagnosis_date,
    values_fill = NA
  )

disease_counts <- sapply(final_events_data[, -1], function(x) sum(!is.na(x)))
print(disease_counts)

final_events_data_long <- final_events_data %>%
  tidyr::pivot_longer(cols = -csid, names_to = "disease", values_to = "diagnosis_date")

final_events <- final_events_data_long %>%
  dplyr::mutate(
    disease_yn = ifelse(!is.na(diagnosis_date), 1, 0),
    disease_date = diagnosis_date
  ) %>%
  dplyr::select(-diagnosis_date) %>%
  tidyr::pivot_wider(
    names_from = disease,
    values_from = c(disease_yn, disease_date),
    names_sep = "_"
  )

save(events_data_earliest, file = here::here("results", "events_data_earliest.RData"))
save(final_events_data, file = here::here("results", "final_events_data.RData"))
save(final_events, file = here::here("results", "final_events.RData"))
