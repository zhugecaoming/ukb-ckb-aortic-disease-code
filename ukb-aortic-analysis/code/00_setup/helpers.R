required_packages <- c(
  "dplyr", "data.table", "tidyverse", "ggplot2", "ggpubr", "survival",
  "survminer", "readxl", "riskRegression", "xgboost", "ROCR", "pROC",
  "ROCit", "caret", "gridExtra", "yaml", "AF", "shapviz"
)

check_and_load_packages <- function(pkgs = required_packages) {
  missing_pkgs <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
  if (length(missing_pkgs) > 0) {
    stop("Please install required packages first: ", paste(missing_pkgs, collapse = ", "))
  }
  invisible(lapply(pkgs, library, character.only = TRUE))
}

load_config <- function(path = "config/config.yml") {
  if (!file.exists(path)) {
    stop("Config file not found: ", path, "
Copy config/config_template.yml to config/config.yml first.")
  }
  yaml::read_yaml(path)
}

ensure_dir <- function(path) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
}

safe_write_csv <- function(x, path, row.names = FALSE) {
  ensure_dir(dirname(path))
  utils::write.csv(x, path, row.names = row.names)
}

compute_met <- function(df) {
  df$low <- 3 * df$low_day * df$low_time
  df$moderate <- 4.5 * df$moderate_day * df$moderate_time
  df$vigorous <- 8 * df$high_day * df$high_time
  df <- dplyr::filter(df, low >= 0 | moderate >= 0 | vigorous >= 0)
  for (v in c("low", "moderate", "vigorous")) {
    df[[v]][is.na(df[[v]])] <- 0
    df[[v]][df[[v]] < 0] <- 0
    df[[v]] <- as.numeric(df[[v]])
  }
  df$MET <- df$low + df$moderate + df$vigorous
  df
}

recode_baseline_factors <- function(ukb, edu = NULL) {
  ukb$centre[ukb$region %in% c(11012,11021,11011,11008,11003,11024,11020,11018,11010,
                               11016,11001,11017,11009,11013,11002,11007,11014,10003,
                               11006,11025,11026,11027,11028)] <- "1"
  ukb$centre[ukb$region %in% c(11005, 11004)] <- "2"
  ukb$centre[ukb$region %in% c(11022, 11023)] <- "3"

  ukb$income[ukb$income %in% c("-3", "-1")] <- "9"
  ukb$income <- as.factor(ukb$income)

  if (!is.null(edu)) {
    ukb <- merge(ukb, edu, by = "eid")
    if (all(c("edu1","edu2","edu3","edu4","edu5","edu6") %in% names(ukb))) {
      ukb$edu <- pmax(ukb$edu1, ukb$edu2, ukb$edu3, ukb$edu4, ukb$edu5, ukb$edu6, na.rm = TRUE)
      ukb$edu[ukb$edu %in% c("-7", "-3")] <- "9"
      ukb$edu <- as.factor(ukb$edu)
    }
  }

  ukb$race[ukb$ethnic %in% c(1,1001,1002,1003)] <- "1"
  ukb$race[ukb$ethnic %in% c(4,4001,4002,4003)] <- "2"
  ukb$race[ukb$ethnic %in% c(3,3001,3002,3003,3004,5)] <- "3"
  ukb$race[ukb$ethnic %in% c(2,2001,2002,2003,2004)] <- "4"
  ukb$race[ukb$ethnic %in% c(6,"-1","-3")] <- "5"
  ukb$race <- as.factor(ukb$race)

  ukb$smoke[ukb$smoke == "-3"] <- "9"
  ukb$smoke <- as.factor(as.numeric(ukb$smoke))
  ukb$drink[ukb$drink == "-3"] <- "9"
  ukb$drink <- as.factor(as.numeric(ukb$drink))
  ukb
}

categorize_met <- function(met, breaks = c(600, 3000)) {
  cut(met, breaks = c(-Inf, breaks[1], breaks[2], Inf), labels = c("1", "2", "3"), right = FALSE)
}

extract_icd_outcome <- function(outcome_df, codes, prefix, code_cols = 2:260, date_cols = 261:519, censor_date = "2023-10-30") {
  temp <- outcome_df
  for (i in code_cols) {
    hit <- Reduce(`|`, lapply(codes, function(code) grepl(code, temp[, i])))
    temp[, i][hit] <- 1
    temp[, i][is.na(temp[, i])] <- 0
    temp[, i][temp[, i] != 1] <- 0
    temp[, i] <- as.numeric(temp[, i])
  }
  offset <- min(date_cols) - min(code_cols)
  for (i in date_cols) {
    temp[, i] <- as.numeric(as.Date(as.character(temp[, i])))
    temp[, i][is.na(temp[, i])] <- 0
    temp[, i] <- temp[, i] * temp[, (i - offset)]
    temp[, i][temp[, i] == 0] <- 20000
  }
  temp[[prefix]] <- rowSums(temp[, code_cols], na.rm = FALSE)
  temp[[prefix]][temp[[prefix]] >= 1] <- 1
  date_col <- paste0(prefix, "_date")
  temp[[date_col]] <- apply(temp[, date_cols], 1, min)
  temp[[date_col]] <- as.Date(temp[[date_col]], origin = "1970-01-01")
  temp[[date_col]][temp[[date_col]] == as.Date("2024-10-04")] <- as.Date(censor_date)
  dplyr::select(temp, eid, dplyr::all_of(prefix), dplyr::all_of(date_col))
}

build_opcs_outcome <- function(opcs_df, lookup_xlsx, code_cols = 2:127, date_cols = 128:253, censor_date = "2023-10-30") {
  allowed_values <- as.matrix(readxl::read_excel(lookup_xlsx))
  for (i in code_cols) {
    opcs_df[, i][opcs_df[, i] %in% allowed_values] <- 1
    opcs_df[, i][is.na(opcs_df[, i])] <- 0
    opcs_df[, i][opcs_df[, i] != 1] <- 0
    opcs_df[, i] <- as.numeric(opcs_df[, i])
  }
  offset <- min(date_cols) - min(code_cols)
  for (i in date_cols) {
    opcs_df[, i] <- as.numeric(as.Date(as.character(opcs_df[, i])))
    opcs_df[, i][is.na(opcs_df[, i])] <- 0
    opcs_df[, i] <- opcs_df[, i] * opcs_df[, (i - offset)]
    opcs_df[, i][opcs_df[, i] == 0] <- 20000
  }
  opcs_df$case <- rowSums(opcs_df[, code_cols], na.rm = FALSE, dims = 1)
  opcs_df$case[opcs_df$case > 1] <- 1
  opcs_df$date <- apply(opcs_df[, date_cols], 1, min)
  opcs_df$date <- as.Date(opcs_df$date, origin = "1970-01-01")
  opcs_df$date[opcs_df$date == as.Date("2024-10-04")] <- as.Date(censor_date)
  dplyr::select(opcs_df, eid, case, date)
}

build_death_cause_flag <- function(death_df, values_to_check, date1 = "death_data1", date2 = "death_data2") {
  cause_cols <- grep("^cause", names(death_df), value = TRUE)
  death_df$death_cause <- apply(death_df[, cause_cols], 1, function(x) if (any(x %in% values_to_check)) 1 else 0)
  dplyr::select(death_df, eid, !!date1, !!date2, death_cause)
}

build_allcause_death <- function(death_df) {
  death_df$death <- ifelse(!is.na(death_df$death_data1) | !is.na(death_df$death_data2), 1, 0)
  death_df <- death_df %>% dplyr::mutate(death_date = dplyr::coalesce(death_data1, death_data2))
  dplyr::select(death_df, eid, death_date, death)
}

build_composite_an <- function(df, censor_date = "2023-10-30") {
  date_candidates <- c(
    "date_I710", "date_I711", "date_I712", "date_I713", "date_I714", "date_I715",
    "date_I716", "date_I718", "date_I719", "date_Q253", "date_M314", "date_I700",
    "death_data1", "death_data2", "date"
  )
  available_dates <- intersect(date_candidates, names(df))
  for (v in available_dates) df[[v]] <- as.Date(df[[v]])
  df$AN_date <- do.call(pmin, c(df[available_dates], na.rm = TRUE))
  df$AN_date[is.na(df$AN_date)] <- as.Date(censor_date)
  flag_candidates <- c("I710", "I711", "I712", "I713", "I714", "I715", "I716", "I718", "I719", "Q253", "M314", "I700", "death_cause", "case")
  available_flags <- intersect(flag_candidates, names(df))
  df$AN <- 0
  if (length(available_flags) > 0) {
    idx <- Reduce(`|`, lapply(available_flags, function(v) df[[v]] == 1))
    df$AN[idx] <- 1
  }
  df$AN <- as.numeric(df$AN)
  if ("data_attending" %in% names(df)) {
    df$AN_ctime <- as.numeric(difftime(df$AN_date, as.Date(df$data_attending), units = "weeks"))
  }
  df
}

remove_reverse_time_order <- function(df, exposure_var, exposure_date_var, outcome_date_var = "AN_date") {
  invalid_id <- df %>%
    dplyr::filter(.data[[exposure_var]] == 1) %>%
    dplyr::mutate(cctime = difftime(.data[[outcome_date_var]], .data[[exposure_date_var]], units = "weeks")) %>%
    dplyr::filter(cctime < 0) %>%
    dplyr::pull(eid)
  df %>% dplyr::filter(!eid %in% invalid_id)
}

build_analysis_dataset <- function(df, exposure_var, outcome_time = "AN_ctime", outcome_status = "AN", met_var = "MET") {
  total <- df %>%
    dplyr::select(eid, age_base, sex, centre, race, edu, smoke, BMI, drink, income,
                  dplyr::all_of(outcome_time), dplyr::all_of(outcome_status), dplyr::all_of(met_var), dplyr::all_of(exposure_var)) %>%
    dplyr::mutate(
      sex = factor(sex),
      centre = factor(centre),
      race = factor(race),
      edu = factor(edu),
      smoke = factor(smoke),
      drink = factor(drink),
      income = factor(income),
      grp_met = factor(categorize_met(.data[[met_var]])),
      !!outcome_status := as.numeric(.data[[outcome_status]])
    ) %>%
    dplyr::select(-dplyr::all_of(met_var)) %>%
    stats::na.omit()
  as.data.frame(total)
}

run_cox_model <- function(total, exposure_var, outcome_time = "AN_ctime", outcome_status = "AN", extra_covariates = NULL) {
  covars <- c(exposure_var, "sex", "age_base", "centre", "race", "edu", "smoke", "BMI", "drink", "income", "grp_met", extra_covariates)
  formula <- as.formula(paste0("survival::Surv(", outcome_time, ", ", outcome_status, ") ~ ", paste(covars, collapse = " + ")))
  survival::coxph(formula, data = total, ties = "breslow")
}

run_paf_table <- function(df, diseases, outcome_date_var = "AN_date", outcome_time = "AN_ctime", outcome_status = "AN") {
  res <- list()
  for (d in diseases) {
    date_var <- paste0(d, "_date")
    if (!all(c(d, date_var, outcome_time, outcome_status) %in% names(df))) next
    dat_raw <- remove_reverse_time_order(df, d, date_var, outcome_date_var)
    total <- build_analysis_dataset(dat_raw, exposure_var = d, outcome_time = outcome_time, outcome_status = outcome_status)
    fit <- run_cox_model(total, d, outcome_time, outcome_status)
    af <- AF::AFcoxph(fit, data = as.data.frame(total), exposure = d, times = max(total[[outcome_time]]))
    hr <- exp(stats::coef(fit)[d])
    par <- af$AF.est
    se <- sqrt(af$AF.var)
    res[[d]] <- data.frame(
      Disease = d,
      HR = hr,
      PAR = par,
      CI_low = par - 1.96 * se,
      CI_high = par + 1.96 * se,
      Events = sum(total[[outcome_status]]),
      N = nrow(total)
    )
  }
  dplyr::bind_rows(res) %>% dplyr::arrange(dplyr::desc(PAR))
}
