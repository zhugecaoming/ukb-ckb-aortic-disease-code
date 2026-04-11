# Utility functions ---------------------------------------------------------

classify_disease <- function(diagnosis_code, diagnosis_main) {
  dplyr::case_when(
    diagnosis_main %in% c("I10", "I11", "I12", "I13", "I14", "I15") ~ "Hypertension",
    diagnosis_main == "R52" ~ "Painful condition",
    grepl("^C", diagnosis_main) ~ "Cancer",
    diagnosis_main %in% c(paste0("D", sprintf("%02d", 0:48))) ~ "Cancer",
    diagnosis_code %in% c("J45.0", "J45.1", "J45.8", "J45.9", "J46") ~ "Asthma",
    diagnosis_main == "K30" ~ "Treated dyspepsia",
    diagnosis_main %in% c(paste0("I", 20:25)) ~ "Coronary heart disease",
    diagnosis_main %in% c(paste0("E", sprintf("%02d", 0:7))) ~ "Thyroid disorders",
    diagnosis_main %in% c(paste0("E", 10:14)) ~ "Diabetes",
    diagnosis_main == "F32" ~ "Depression",
    diagnosis_main %in% c("L40", "L20") ~ "Psoriasis or eczema",
    diagnosis_main %in% c("N41", "N42") ~ "Prostate disorders",
    (diagnosis_main %in% c(paste0("M", sprintf("%02d", 5:14))) | diagnosis_main == "L94") ~ "RA-OIP-SCTD",
    (diagnosis_main %in% c(paste0("I", 60:69)) | diagnosis_main == "G45") ~ "Stroke and TIA",
    diagnosis_main == "M81" ~ "Osteoporosis",
    diagnosis_main == "J44" ~ "COPD",
    diagnosis_main == "G43" ~ "Migraine",
    diagnosis_main == "K58" ~ "Irritable bowel syndrome",
    diagnosis_main == "H40" ~ "Glaucoma",
    diagnosis_main == "K57" ~ "Diverticular disease of intestine",
    diagnosis_main %in% c("F41", "F43", "F45", "F48") ~ "ANSS",
    diagnosis_main == "I48" ~ "Atrial fibrillation",
    (diagnosis_main %in% c("K50", "K51") | diagnosis_code == "K52.3") ~ "Inflammatory bowel disease",
    diagnosis_main == "G40" ~ "Epilepsy",
    diagnosis_main == "J32" ~ "Chronic sinusitis",
    diagnosis_main == "N80" ~ "Endometriosis",
    diagnosis_main == "D51" ~ "Pernicious anaemia",
    diagnosis_code == "H81.0" ~ "Meniere's disease",
    diagnosis_main == "J47" ~ "Bronchiectasis",
    diagnosis_main == "R53" ~ "Chronic fatigue syndrome",
    diagnosis_main == "I73" ~ "Peripheral vascular disease",
    diagnosis_main %in% c("F20", "F31") ~ "Schizophrenia or BD",
    diagnosis_main == "G20" ~ "Parkinson's disease",
    (diagnosis_main %in% c("N18", "N03") | diagnosis_code == "N13.2") ~ "Chronic kidney disease",
    diagnosis_main == "G35" ~ "Multiple sclerosis",
    diagnosis_main %in% c(paste0("B", 15:19)) ~ "Viral hepatitis",
    diagnosis_main %in% c(paste0("K", 70:77)) ~ "Chronic liver disease",
    diagnosis_main == "I50" ~ "Heart failure",
    (diagnosis_main == "F10" & diagnosis_code != "F10.0") ~ "Alcohol problems",
    diagnosis_code == "K59.0" ~ "Treated constipation",
    diagnosis_code == "E28.2" ~ "Polycystic ovary",
    diagnosis_main == "F50" ~ "Anorexia or bulimia",
    diagnosis_main == "F19" ~ "OPSM",
    TRUE ~ "Other"
  )
}

to_date <- function(x) {
  x <- as.character(x)
  x[x %in% c("", "NA", "NULL", "NaT")] <- NA
  numeric_x <- suppressWarnings(as.numeric(x))

  if (!all(is.na(numeric_x))) {
    excel_origin <- as.Date("1899-12-30")
    result <- excel_origin + numeric_x
    result[is.na(numeric_x)] <- NA
    return(result)
  }

  tryCatch(as.Date(x), error = function(e) NA)
}
