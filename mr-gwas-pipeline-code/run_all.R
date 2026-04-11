source("code/00_setup_packages.R")
source("code/helpers.R")
source("code/01_prepare_exposures.R")
source("code/02_run_mr_batch.R")

prepared_objects <- prepare_exposures("config/config.yml")
run_mr_batch("config/config.yml", prepared = prepared_objects)
