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
  packages = c("tidyverse", "fs", "janitor", "daymetr", "tidymodels", "ranger", "multilevelmod"),
  format = "rds" # default storage format
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

tar_plan(
  # Data prep ---------------------------------------------------------------
  tar_files(
    wildtype_files,
    get_data_paths(c("/data/output/pecan_runs/transect/", "/data/output/pecan_runs/seus_sample"), "wildtype")
  ),
  tar_files(
    hotleaf_files,
    get_data_paths(c("/data/output/pecan_runs/transect/", "/data/output/pecan_runs/seus_sample"), "hotleaf")
  ),
  tar_files(
    dwarf_files,
    get_data_paths(c("/data/output/pecan_runs/transect/", "/data/output/pecan_runs/seus_sample"), "dwarf")
  ),
  tar_files(
    antho_files,
    get_data_paths(c("/data/output/pecan_runs/transect/", "/data/output/pecan_runs/seus_sample"), "antho")
  ),
  tar_target(wildtype_data, collect_data(wildtype_files) |> mutate(genotype = "wildtype")),
  tar_target(hotleaf_data, collect_data(hotleaf_files) |> mutate(genotype = "hotleaf")),
  tar_target(dwarf_data, collect_data(dwarf_files) |> mutate(genotype = "dwarf")),
  tar_target(antho_data, collect_data(antho_files) |> mutate(genotype = "antho")),
  
  # Get weather data
  tar_target(site_data, make_site_data(hotleaf_data, dwarf_data, antho_data)),
  tar_target(daymet_monthly, get_daymet_monthly(site_data)),
  
  # for starters, just use one genotype for modeling as a test.  Eventually use
  # static branching with tar_map() to do all this better
  
  # currently this is monthly timeseries data, which might not be appropriate
  # for random forest modeling without an autoregressive term.  Might be able to
  # add autoregression with recipes?
  tar_target(wildtype_full, combine_wrangle(wildtype_data, daymet_monthly)),
  

  # Model -------------------------------------------------------------------
  #split into training and testing set
  tar_target(
    wildtype_split,
    group_initial_split(
      wildtype_full,
      group = run_id, #keep timeseries together in test and training
      prop = 0.8, #80/20 split
      # strata = npp_summer #stratify by NPP which is right-skewed
    )
  ),
  tar_target(wildtype_train, training(wildtype_split)),
  tar_target(wildtype_test,  testing(wildtype_split)),
  # tar_target(
  #   rf_model,
  #   rand_forest(
  #     trees = tune(),
  #     mtry = tune()
  #   ) |> set_engine("ranger") |> set_mode("regression")
  # ),
  # tar_target(
  #   lmer_model,
  #   linear_reg() |> set_engine("lmer") |> set_mode("regression")
  # ),
  # tar_target(ens_recipe, define_recipe(ens_train)),
  # tar_target(
  #   rf_workflow,
  #   workflow() |> 
  #     add_recipe(ens_recipe) |>
  #     add_model(rf_model, formula = npp_summer ~ .)
  # ),
  # tar_target(
  #   lmer_workflow,
  #   workflow() |> 
  #     add_recipe(ens_recipe) |>
  #     add_model(lmer_model, formula = npp_summer ~ . + (1|ens_unique))
  # ),
  # tar_target(
  #   lmer_fit,
  #   lmer_workflow |> fit(ens_train)
  # ),
  # tar_target(
  #   rf_grid,
  #   expand_grid(mtry = 3:5, trees = seq(500, 1500, by = 200))
  # ),
  # tar_target(
  #   rf_grid_results,
  #   rf_workflow |> tune_grid(resamples = vfold_cv(ens_train, v = 5), grid = rf_grid)
  # ),
  # tar_target(
  #   hyperparameters,
  #   select_by_pct_loss(rf_grid_results, metric = "rmse", limit = 5, trees)
  # ),
  # tar_target(
  #   rf_fit,
  #   rf_workflow |> finalize_workflow(hyperparameters) |> fit(ens_train)
  # ),
  # ## I don't think this is the correct way to do this
  # # tar_target(
  # #   metrics,
  # #   rf_fit %>%
  # #     predict(ens_test) %>%
  # #     metric_set(rmse, mae, rsq, ccc)(ens_test$npp_summer, .pred)
  # # )
) |> 
  tarchetypes::tar_hook_before(tidymodels_prefer())
