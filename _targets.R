# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  # packages that your targets need to run
  packages = c("tidyverse", "fs", "janitor", "daymetr", "tidymodels", "ranger"),
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

tar_plan(
  # Data prep ---------------------------------------------------------------
  tar_files(
    ens_data_files,
    dir_ls("/data/output/pecan_runs/transect/") |>
      dir_ls(regexp = "mixed$|pine$|prairie$") |> 
      path("out") |> 
      dir_ls(regexp = "ENS-") |> 
      dir_ls(regexp = "run_data.csv")
  ),
  tar_target(ens_output, collect_ens_data(ens_data_files)),
  tar_target(ens_params, collect_ens_params("/data/output/pecan_runs/transect/")),
  tar_target(daymet_monthly, get_daymet_monthly(ens_output)),
  
  #currently this is monthly timeseries data, but that's probably not
  #appropriate for the kind of predictive model we want to build
  tar_target(ens_complete, combine_data(ens_output, ens_params, daymet_monthly)),
  tar_target(model_data, wrangle_data(ens_complete)),
  
  # Model -------------------------------------------------------------------
  #split into training and testing set
  tar_target(ens_split, initial_split(model_data, prop = 0.8)),
  tar_target(ens_train, training(ens_split)),
  tar_target(ens_test, testing(ens_split)),
  tar_target(
    ens_model,
    rand_forest(
      trees = tune(),
      mtry = tune()
    ) |> set_engine("ranger") |> set_mode("regression")
  ),
  tar_target(ens_recipe, define_recipe(ens_train)),
  tar_target(
    ens_workflow,
    workflow() |> add_recipe(ens_recipe) |> add_model(ens_model)
  ),
  tar_target(
    ens_grid,
    expand_grid(mtry = 3:5, trees = seq(500, 1500, by = 200))
  ),
  tar_target(
    ens_grid_results,
    ens_workflow |> tune_grid(resamples = vfold_cv(ens_train, v = 5), grid = ens_grid)
  ),
  tar_target(
    hyperparameters,
    select_by_pct_loss(ens_grid_results, metric = "rmse", limit = 5, trees)
  ),
  tar_target(
    fitted_model,
    ens_workflow |> finalize_workflow(hyperparameters) |> fit(ens_train)
  ),
  tar_target(
    metrics,
    fitted_model %>%
      predict(ens_test) %>%
      metric_set(rmse, mae, rsq, ccc)(ens_test$npp_summer, .pred)
  )
)
