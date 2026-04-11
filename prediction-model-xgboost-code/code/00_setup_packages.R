required_packages <- c(
  "xgboost", "pROC", "ROCit", "caret", "shapviz",
  "ggplot2", "tibble", "dplyr", "yaml"
)

missing_pkgs <- required_packages[!required_packages %in% installed.packages()[, "Package"]]
if (length(missing_pkgs) > 0) {
  stop("Please install required packages before running: ", paste(missing_pkgs, collapse = ", "))
}

invisible(lapply(required_packages, library, character.only = TRUE))
