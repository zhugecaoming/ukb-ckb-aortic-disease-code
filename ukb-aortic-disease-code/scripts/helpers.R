# Helper functions for the UKB aortic disease analysis pipeline
# This file was refactored from the original project scripts supplied by the authors.
# It standardizes repeated steps and removes hard-coded local paths.

required_pkgs <- c(
  "data.table", "dplyr", "readxl", "survival", "AF", "riskRegression",
  "ggplot2", "rlang", "tidyr"
)

install_missing_packages <- function(pkgs = required_pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    install.packages(missing, dependencies = TRUE)
  }
}

load_required_packages <- function(pkgs = required_pkgs) {
  invisible(lapply(pkgs, library, character.only = TRUE))
}

read_config <- function(config_path = "config/analysis_config.R") {
  if (!file.exists(config_path)) {
    stop(
      "Configuration file not found: ", config_path, "\n",
      "Copy config/analysis_config_template.R to config/analysis_config.R and edit the paths."
    )
  }
  env <- new.env(parent = emptyenv())
  sys.source(config_path, envir = env)
  if (!exists("cfg", envir = env, inherits = FALSE)) {
    stop("The config file must define an object named `cfg`.")
  }
  get("cfg", envir = env, inherits = FALSE)
}

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

safe_fread <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path)
  data.table::fread(path, stringsAsFactors = FALSE)
}

safe_read_excel <- function(path, ...) {
  if (!file.exists(path)) stop("Missing input file: ", path)
  readxl::read_excel(path, ...)
}

compute_met <- function(df) {
  df$low <- 3 * df$low_day * df$low_time
  df$moderate <- 4.5 * df$moderate_day * df$moderate_time
  df$vigorous <- 8 * df$high_day * df$high_time

  keep_idx <- (df$low >= 0) | (df$moderate >= 0) | (df$vigorous >= 0)
  keep_idx[is.na(keep_idx)] <- TRUE
  df <- df[keep_idx, ]

  for (nm in c("low", "moderate", "vigorous")) {
    df[[nm]][is.na(df[[nm]])] <- 0
    df[[nm]][df[[nm]] < 0] <- 0
    df[[nm]] <- as.numeric(df[[nm]])
  }
  df$MET <- df$low + df$moderate + df$vigorous
  df
}

recode_centre <- function(region) {
  centre <- rep(NA_character_, length(region))
  centre[region %in% c(11012,11021,11011,11008,11003,11024,11020,11018,11010,11016,
                       11001,11017,11009,11013,11002,11007,11014,10003,11006,11025,
                       11026,11027,11028)] <- "1"
  centre[region %in% c(11005,11004)] <- "2"
  centre[region %in% c(11022,11023)] <- "3"
  factor(centre)
}

recode_race <- function(ethnic) {
  race <- rep(NA_character_, length(ethnic))
  race[ethnic %in% c(1,1001,1002,1003)] <- "1"
  race[ethnic %in% c(4,4001,4002,4003)] <- "2"
  race[ethnic %in% c(3,3001,3002,3003,3004,5)] <- "3"
  race[ethnic %in% c(2,2001,2002,2003,2004)] <- "4"
  race[ethnic %in% c(6,-1,-3)] <- "5"
  factor(race)
}

recode_covariates <- function(ukb, edu) {
  ukb <- merge(ukb, edu, by = "eid", all.x = TRUE)

  ukb$centre <- recode_centre(ukb$region)

  ukb$income[ukb$income %in% c("-3", "-1", -3, -1)] <- "9"
  ukb$income <- factor(ukb$income)

  ukb$edu <- pmax(ukb$edu1, ukb$edu2, ukb$edu3, ukb$edu4, ukb$edu5, ukb$edu6, na.rm = TRUE)
  ukb$edu[ukb$edu %in% c("-7", "-3", -7, -3)] <- "9"
  ukb$edu <- factor(ukb$edu)

  ukb$race <- recode_race(ukb$ethnic)

  ukb$smoke[ukb$smoke %in% c("-3", -3)] <- "9"
  ukb$smoke <- factor(as.numeric(ukb$smoke))

  ukb$drink[ukb$drink %in% c("-3", -3)] <- "9"
  ukb$drink <- factor(as.numeric(ukb$drink))

  ukb
}

build_death_flag <- function(death_df, icd_codes) {
  cause_cols <- grep("^cause", names(death_df), value = TRUE)
  death_df$death_cause <- apply(
    death_df[, cause_cols, drop = FALSE],
    1,
    function(x) if (any(x %in% icd_codes, na.rm = TRUE)) 1 else 0
  )
  dplyr::select(death_df, eid, death_data1, death_data2, death_cause)
}

build_wide_icd_flag <- function(outcome_df, codes, prefix) {
  tmp <- as.data.frame(outcome_df)
  diagnosis_cols <- 2:260
  date_cols <- 261:519

  for (i in diagnosis_cols) {
    tmp[, i] <- ifelse(grepl(paste(codes, collapse = "|"), tmp[, i]), 1, 0)
    tmp[, i][is.na(tmp[, i])] <- 0
    tmp[, i] <- as.numeric(tmp[, i])
  }

  for (i in date_cols) {
    tmp[, i] <- as.numeric(as.Date(as.character(tmp[, i])))
    tmp[, i][is.na(tmp[, i])] <- 0
    tmp[, i] <- tmp[, i] * tmp[, i - 259]
    tmp[, i][tmp[, i] == 0] <- 20000
  }

  tmp[[prefix]] <- rowSums(tmp[, diagnosis_cols], na.rm = FALSE)
  tmp[[prefix]][tmp[[prefix]] >= 1] <- 1

  tmp[[paste0(prefix, "_date")]] <- apply(tmp[, date_cols], 1, min)
  tmp[[paste0(prefix, "_date")]] <- as.Date(tmp[[paste0(prefix, "_date")]], origin = "1970-01-01")
  tmp[[paste0(prefix, "_date")]][tmp[[paste0(prefix, "_date")]] == as.Date("2024-10-04")] <- as.Date("2023-10-30")

  dplyr::select(tmp, eid, !!prefix, !!paste0(prefix, "_date"))
}

build_opcs_flag <- function(opcs_source, opcs_code_sheet, prefix = "case") {
  tmp <- as.data.frame(opcs_source)
  allowed_values <- as.matrix(opcs_code_sheet)
  code_cols <- 2:127
  date_cols <- 128:253

  for (i in code_cols) {
    tmp[, i][tmp[, i] %in% allowed_values] <- 1
    tmp[, i][is.na(tmp[, i])] <- 0
    tmp[, i][tmp[, i] != 1] <- 0
    tmp[, i] <- as.numeric(tmp[, i])
  }

  for (i in date_cols) {
    tmp[, i] <- as.numeric(as.Date(as.character(tmp[, i])))
    tmp[, i][is.na(tmp[, i])] <- 0
    tmp[, i] <- tmp[, i] * tmp[, i - 126]
    tmp[, i][tmp[, i] == 0] <- 20000
  }

  tmp[[prefix]] <- rowSums(tmp[, code_cols], na.rm = FALSE)
  tmp[[prefix]][tmp[[prefix]] > 1] <- 1
  tmp$date <- apply(tmp[, date_cols], 1, min)
  tmp$date <- as.Date(tmp$date, origin = "1970-01-01")
  tmp$date[tmp$date == as.Date("2024-10-04")] <- as.Date("2023-10-30")

  dplyr::select(tmp, eid, !!prefix, date)
}

categorize_met <- function(met) {
  cut(met, breaks = c(-Inf, 600, 3000, Inf), labels = c("1", "2", "3"), right = FALSE)
}

assemble_primary_endpoint <- function(ukb, aortic_subtypes, opcs, use_existing_an = TRUE) {
  merge1 <- merge(ukb, aortic_subtypes, by = "eid", all.x = TRUE)
  merge2 <- merge(merge1, opcs, by = "eid", all.x = TRUE)

  date_vars <- grep("(^date_|_date$)|death_data|^date$", names(merge2), value = TRUE)
  for (nm in date_vars) {
    suppressWarnings(merge2[[nm]] <- as.Date(merge2[[nm]]))
  }

  an_date_cols <- intersect(
    c("date_I710","date_I711","date_I712","date_I713","date_I714",
      "date_I715","date_I716","date_I718","date_I719","date_Q253","date_M314",
      "date_I700","death_data1","death_data2","date"),
    names(merge2)
  )

  merge2$AN_date <- do.call(pmin, c(merge2[an_date_cols], na.rm = TRUE))
  merge2$AN_date[is.na(merge2$AN_date)] <- as.Date("2023-10-30")
  merge2$AN_ctime <- difftime(merge2$AN_date, merge2$data_attending, units = "weeks")

  indicator_cols <- intersect(
    c("I710","I711","I712","I713","I714","I715","I716","I718","I719","Q253","M314","I700","death_cause","case"),
    names(merge2)
  )
  merge2$AN <- ifelse(rowSums(as.data.frame(lapply(merge2[indicator_cols], function(x) as.numeric(as.character(x)))),
                              na.rm = TRUE) > 0, 1, 0)
  merge2$AN <- ifelse(is.na(merge2$AN), 0, merge2$AN)

  dplyr::filter(merge2, AN_ctime > 0)
}

exclude_outcome_before_exposure <- function(df, exposure_var, exposure_date_var, outcome_date_var = "AN_date") {
  invalid_id <- df %>%
    dplyr::filter(.data[[exposure_var]] == 1) %>%
    dplyr::mutate(cctime = difftime(.data[[outcome_date_var]], .data[[exposure_date_var]], units = "weeks")) %>%
    dplyr::filter(cctime < 0) %>%
    dplyr::pull(eid)
  dplyr::filter(df, !eid %in% invalid_id)
}

build_analysis_dataset <- function(df, exposure_var) {
  out <- df %>%
    dplyr::select(eid, age_base, sex, centre, race, edu, smoke, BMI, drink,
                  income, AN_ctime, AN, MET, !!rlang::sym(exposure_var)) %>%
    dplyr::mutate(
      sex = factor(sex),
      centre = factor(centre),
      race = factor(race),
      edu = factor(edu),
      smoke = factor(smoke),
      drink = factor(drink),
      income = factor(income),
      grp_met = categorize_met(MET),
      AN = as.numeric(AN)
    ) %>%
    dplyr::select(-MET) %>%
    tidyr::drop_na()
  out
}

run_cox_for_exposure <- function(df, exposure_var, include_sex = TRUE, interaction_term = NULL) {
  rhs_terms <- c(
    exposure_var,
    if (include_sex) "sex" else NULL,
    "age_base", "centre", "race", "edu", "smoke", "BMI", "drink", "income", "grp_met"
  )
  if (!is.null(interaction_term)) rhs_terms[1] <- interaction_term
  fml <- as.formula(paste0("survival::Surv(AN_ctime, AN) ~ ", paste(rhs_terms, collapse = " + ")))
  survival::coxph(fml, data = df, ties = "breslow")
}

run_paf_for_exposure <- function(df, exposure_var) {
  fit <- run_cox_for_exposure(df, exposure_var)
  af <- AF::AFcoxph(
    object = fit,
    data = as.data.frame(df),
    exposure = exposure_var,
    times = max(df$AN_ctime)
  )
  list(
    fit = fit,
    af = af,
    result = data.frame(
      Disease = exposure_var,
      HR = unname(exp(coef(fit)[exposure_var])),
      PAR = af$AF.est,
      CI_low = af$AF.est - 1.96 * sqrt(af$AF.var),
      CI_high = af$AF.est + 1.96 * sqrt(af$AF.var),
      Events = sum(df$AN),
      N = nrow(df)
    )
  )
}

run_csc_competing_risk <- function(df, exposure_var, death_var = "death", death_date_var = "death_date") {
  tmp <- df
  tmp[[death_date_var]][is.na(tmp[[death_date_var]])] <- as.Date("2023-11-01")
  tmp$time <- as.numeric(difftime(
    pmin(tmp[[death_date_var]], tmp$AN_date, na.rm = TRUE),
    tmp$data_attending,
    units = "days"
  ) / 365.25)
  tmp$status <- dplyr::case_when(
    tmp$AN == 1 & tmp[[death_var]] == 1 ~ 1,
    tmp$AN == 1 ~ 1,
    tmp[[death_var]] == 1 ~ 2,
    TRUE ~ 0
  )
  analysis_data <- tmp %>%
    dplyr::select(eid, time, status, !!rlang::sym(exposure_var),
                  age_base, sex, centre, race, edu, smoke, BMI, drink, income, MET) %>%
    dplyr::mutate(
      sex = factor(sex),
      centre = factor(centre),
      race = factor(race),
      edu = factor(edu),
      smoke = factor(smoke),
      drink = factor(drink),
      income = factor(income),
      grp_met = categorize_met(MET)
    ) %>%
    tidyr::drop_na()

  riskRegression::CSC(
    formula = as.formula(
      paste0("riskRegression::Hist(time, status) ~ ", exposure_var,
             " + sex + age_base + centre + race + edu + smoke + BMI + drink + income + grp_met")
    ),
    data = analysis_data,
    cause = 1
  )
}
