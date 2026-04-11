required_packages <- c(
  "TwoSampleMR",
  "ieugwasr",
  "dplyr",
  "data.table",
  "ggplot2",
  "yaml",
  "readr",
  "tibble"
)

missing_pkgs <- required_packages[!required_packages %in% installed.packages()[, "Package"]]

if (length(missing_pkgs) > 0) {
  stop(
    "Please install required packages before running: ",
    paste(missing_pkgs, collapse = ", ")
  )
}

invisible(lapply(required_packages, library, character.only = TRUE))
