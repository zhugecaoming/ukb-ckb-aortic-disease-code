# Package setup -------------------------------------------------------------

required_packages <- c(
  "dplyr",
  "tidyr",
  "data.table",
  "lubridate",
  "survival",
  "here"
)

missing_packages <- required_packages[!required_packages %in% rownames(installed.packages())]

if (length(missing_packages) > 0) {
  stop(
    "Please install required packages before running the analysis: ",
    paste(missing_packages, collapse = ", ")
  )
}

invisible(lapply(required_packages, library, character.only = TRUE))
