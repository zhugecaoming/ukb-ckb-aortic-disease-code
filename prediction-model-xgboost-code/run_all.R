source("code/00_setup_packages.R")
source("code/01_prepare_data.R")
source("code/02_train_xgboost_models.R")

cfg <- load_config("config/config.yml")
run_prediction_pipeline(cfg)
