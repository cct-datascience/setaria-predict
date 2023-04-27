# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
set.seed(34234)
# Set target options:
tar_option_set(
  # packages that your targets need to run
  packages = c(
    "tidyverse",
    "fs",
    "janitor",
    "daymetr",
    "tidymodels",
    "ranger",
    "multilevelmod",
    "dismo"
  ),
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
  tar_target(setaria_data, bind_rows(wildtype_data, hotleaf_data, dwarf_data, antho_data)),
  
  # Get weather data
  tar_target(site_data, make_site_data(setaria_data)),
  tar_target(daymet_monthly, get_daymet_monthly(site_data)),
  tar_target(bioclim, calc_bioclim(daymet_monthly)),
  tar_target(model_data, create_model_data(setaria_data, bioclim)), #TODO: consider including mean daylight or latitude 
  
  #split into training and testing set
  tar_target(
    data_split,
    initial_split(
      model_data,
      prop = 0.8, #80/20 split
      strata = npp_yr10 #stratify by NPP which is right-skewed
    )
  ),
  tar_target(data_train, training(data_split)),
  tar_target(data_test,   testing(data_split)),
  
  # Model -------------------------------------------------------------------
  # TODO: add some kind of penalized linear regression model to compete with RF
  
  # Set up recipe for pre-processing
  tar_target(rf_recipe, define_recipe(data_train)), 
  
  tar_target(
    rf_model,
    rand_forest(
      trees = tune(),
      mtry = tune()
    ) |> 
      set_engine("ranger") |>
      set_mode("regression")
  ),
  tar_target(
    rf_workflow,
    workflow() |>
      add_recipe(rf_recipe) |>
      add_model(rf_model)
  ),
  tar_target(
    rf_grid,
    expand_grid(mtry = 3:5, trees = seq(500, 1500, by = 200))
  ),
  tar_target(
    rf_grid_results,
    rf_workflow |> 
      tune_grid(resamples = vfold_cv(data_train, v = 5), grid = rf_grid)
  ),
  #there is a simpler way to do this in the most recent version of tidymodels
  tar_target(
    hyperparameters,
    select_by_pct_loss(rf_grid_results, metric = "rmse", limit = 5, trees)
  ),
  tar_target(
    rf_fit,
    rf_workflow |> 
      finalize_workflow(hyperparameters) |>
      fit(data = data_train)
  ),
  

# Evaluate models ---------------------------------------------------------
  tar_target(
    rf_pred_plot,
    augment(rf_fit, data_test) |> 
      ggplot(aes(x = log(npp_yr10), y = .pred, color = genotype)) +
      geom_point() + 
      geom_abline(alpha = 0.3, linetype = 2) +
      facet_wrap(~ecosystem, labeller = label_both) +
      theme_bw() +
      labs(x = "observed log(NPP)", y = "predicted log(NPP)")
  ),


# Gridded predictions -----------------------------------------------------

# Generate a grid of points
# Get weather data for those points, calculate bioclim, etc.
# Predict on those points
# Make maps
) |> 
  tarchetypes::tar_hook_before(tidymodels_prefer())
