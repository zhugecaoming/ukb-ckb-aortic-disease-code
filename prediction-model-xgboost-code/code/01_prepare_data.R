source("code/helpers.R")

load_config <- function(path = "config/config.yml") {
  if (!file.exists(path)) {
    stop("Missing config/config.yml. Copy config/config_template.yml to config/config.yml and edit it first.")
  }
  yaml::read_yaml(path)
}

prepare_model_inputs <- function(cfg) {
  input_file <- cfg$input$data_file
  if (!file.exists(input_file)) {
    stop("Input data file not found: ", input_file)
  }

  env <- new.env(parent = globalenv())
  ext <- tools::file_ext(input_file)

  if (tolower(ext) %in% c("rdata", "rda")) {
    load(input_file, envir = env)
  } else if (tolower(ext) %in% c("rds")) {
    env[[cfg$input$filtered_object_name]] <- readRDS(input_file)
  } else {
    stop("Unsupported input format. Please provide .RData or .rds input.")
  }

  df_filtered <- env[[cfg$input$filtered_object_name]]
  data1 <- env[[cfg$input$data_object_name]]
  M.names1 <- env[[cfg$input$predictor_pool_name]]
  X.names1 <- env[[cfg$input$extra_predictor_pool_name]]
  y.names <- env[[cfg$input$outcome_names_name]]

  if (is.null(df_filtered) || is.null(data1) || is.null(M.names1) || is.null(y.names)) {
    stop("One or more required objects are missing from the input file.")
  }

  drop_positions <- unlist(cfg$variables$drop_columns_by_position)
  drop_positions <- drop_positions[drop_positions <= ncol(df_filtered)]

  data1 <- as.data.frame(df_filtered)
  if (length(drop_positions) > 0) {
    data1 <- data1[, -drop_positions, drop = FALSE]
  }
  df_filtered <- as.data.frame(df_filtered)

  remove_predictors <- unlist(cfg$variables$remove_predictors)
  predictor_pool <- M.names1[!M.names1 %in% remove_predictors]

  list(
    df_filtered = df_filtered,
    data1 = data1,
    predictor_pool = predictor_pool,
    predictor_pool_extended = unique(c(predictor_pool, X.names1)),
    outcome_names = y.names
  )
}
