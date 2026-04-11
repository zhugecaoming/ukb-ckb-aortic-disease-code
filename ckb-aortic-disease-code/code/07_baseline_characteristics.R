source(here::here("code", "00_packages.R"))

load(here::here("results", "Total.RData"))  # Total

continuous_vars <- c("age_at_study_date", "bmi_calc", "met")
categorical_vars <- c(
  "is_female", "region_code", "highest_education",
  "alcohol_category", "household_income", "smoking_category"
)

baseline_table <- data.frame()

for (var in continuous_vars) {
  if (var %in% names(Total)) {
    mean_total <- mean(Total[[var]], na.rm = TRUE)
    sd_total <- sd(Total[[var]], na.rm = TRUE)
    mean_event <- mean(Total[Total$AN_status == 1, ][[var]], na.rm = TRUE)
    sd_event <- sd(Total[Total$AN_status == 1, ][[var]], na.rm = TRUE)
    mean_noevent <- mean(Total[Total$AN_status == 0, ][[var]], na.rm = TRUE)
    sd_noevent <- sd(Total[Total$AN_status == 0, ][[var]], na.rm = TRUE)

    baseline_table <- rbind(
      baseline_table,
      data.frame(
        Variable = var,
        Total = paste0(round(mean_total, 2), " ± ", round(sd_total, 2)),
        No_event = paste0(round(mean_noevent, 2), " ± ", round(sd_noevent, 2)),
        Event = paste0(round(mean_event, 2), " ± ", round(sd_event, 2)),
        stringsAsFactors = FALSE
      )
    )
  }
}

for (var in categorical_vars) {
  if (var %in% names(Total)) {
    tbl_total <- table(Total[[var]], useNA = "ifany")
    tbl_noevent <- table(Total[Total$AN_status == 0, ][[var]], useNA = "ifany")
    tbl_event <- table(Total[Total$AN_status == 1, ][[var]], useNA = "ifany")

    for (level in names(tbl_total)) {
      n_total <- tbl_total[level]
      pct_total <- n_total / sum(tbl_total) * 100
      n_noevent <- ifelse(level %in% names(tbl_noevent), tbl_noevent[level], 0)
      pct_noevent <- n_noevent / sum(tbl_noevent) * 100
      n_event <- ifelse(level %in% names(tbl_event), tbl_event[level], 0)
      pct_event <- n_event / sum(tbl_event) * 100
      level_label <- ifelse(is.na(level), "Missing", level)

      baseline_table <- rbind(
        baseline_table,
        data.frame(
          Variable = paste0(var, "_", level_label),
          Total = paste0(n_total, " (", round(pct_total, 1), "%)"),
          No_event = paste0(n_noevent, " (", round(pct_noevent, 1), "%)"),
          Event = paste0(n_event, " (", round(pct_event, 1), "%)"),
          stringsAsFactors = FALSE
        )
      )
    }
  }
}

baseline_table <- rbind(
  data.frame(
    Variable = "N",
    Total = nrow(Total),
    No_event = sum(Total$AN_status == 0, na.rm = TRUE),
    Event = sum(Total$AN_status == 1, na.rm = TRUE),
    stringsAsFactors = FALSE
  ),
  baseline_table
)

write.csv(baseline_table, here::here("results", "baseline_characteristics.csv"), row.names = FALSE)
