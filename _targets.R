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
    "dismo",
    "glmnet",
    "sf",
    "terra",
    "stars",
    "units",
    "ragg",
    "colorspace",
    "ggtext"
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
  tar_target(wildtype_data, collect_data(wildtype_files) |> mutate(phenotype = "wildtype")),
  tar_target(hotleaf_data, collect_data(hotleaf_files) |> mutate(phenotype = "hotleaf")),
  tar_target(dwarf_data, collect_data(dwarf_files) |> mutate(phenotype = "dwarf")),
  tar_target(antho_data, collect_data(antho_files) |> mutate(phenotype = "antho")),
  tar_target(setaria_data, bind_rows(wildtype_data, hotleaf_data, dwarf_data, antho_data)),
  
  # Get weather data
  tar_target(site_data, make_site_data(setaria_data)),
  tar_target(daymet_monthly, get_daymet_monthly(site_data)),
  tar_target(bioclim, calc_bioclim(daymet_monthly)),
  tar_target(
    model_data,
    create_model_data(setaria_data |> filter(pft == 1), bioclim)
  ),
  
  #split into training and testing set
  tar_target(
    data_split,
    initial_split(
      model_data,
      prop = 0.8 #80/20 split
    )
  ),
  tar_target(data_train, training(data_split)),
  tar_target(data_test,   testing(data_split)),
  tar_target(data_folds, vfold_cv(data_train, v = 10)),
  
  # Model -------------------------------------------------------------------
  # TODO: add some kind of penalized linear regression model to compete with RF
  
  # Set up recipe for pre-processing
  tar_target(rf_recipe, define_recipe(data_train)), 
  
  
  ## Random forest ----------------------------------------------------------
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
    rf_hyperparameters,
    select_by_pct_loss(rf_grid_results, metric = "rmse", limit = 5, trees)
  ),
  tar_target(
    rf_fit,
    rf_workflow |> 
      finalize_workflow(rf_hyperparameters) |>
      fit(data = data_train)
  ),
  
  ## Linear regression ------------------------------------------------------
  
  tar_target(
    lm_model,
    linear_reg(
      penalty = tune(), #full coefficient path is used regardless of what is set here
      mixture = tune()
    ) |> 
      set_engine("glmnet") #penalized regression
  ),
  tar_target(
    lm_workflow,
    workflow() |>
      add_recipe(rf_recipe) |> #re-use recipe
      add_model(lm_model)
  ),
  tar_target(
    lm_grid,
    tibble(penalty = 1, mixture = seq(0, 1, by = 0.1))
  ),
  tar_target(
    lm_grid_results,
    lm_workflow |> 
      tune_grid(resamples = vfold_cv(data_train, v = 5), grid = lm_grid)
  ),
  tar_target(
    lm_hyperparameters,
    select_by_pct_loss(lm_grid_results, metric = "rmse", mixture)
  ),
  tar_target(
    lm_fit,
    lm_workflow |> 
      finalize_workflow(lm_hyperparameters) |>
      fit(data = data_train)
  ),
  
  # Evaluate models ---------------------------------------------------------
  tar_target(
    rf_pred_plot,
    augment(rf_fit, data_test) |> 
      ggplot(aes(x = log_npp_yr10, y = .pred, color = phenotype)) +
      geom_point() + 
      geom_abline(alpha = 0.3, linetype = 2) +
      facet_wrap(~ecosystem, labeller = label_both) +
      theme_bw() +
      labs(x = "observed log(NPP)", y = "predicted log(NPP)")
  ),
  #do 10-fold cross-validation
  tar_target(
    rf_cv,
    rf_workflow |> 
      finalize_workflow(rf_hyperparameters) |> 
      fit_resamples(data_folds) |> 
      collect_metrics()
  ),
  tar_target(
    lm_pred_plot,
    augment(lm_fit, data_test) |> 
      ggplot(aes(x = log_npp_yr10, y = .pred, color = phenotype)) +
      geom_point() + 
      geom_abline(alpha = 0.3, linetype = 2) +
      facet_wrap(~ecosystem, labeller = label_both) +
      theme_bw() +
      labs(x = "observed log(NPP)", y = "predicted log(NPP)")
  ),
  tar_target(
    lm_cv,
    lm_workflow |> 
      finalize_workflow(lm_hyperparameters) |> 
      fit_resamples(data_folds) |> 
      collect_metrics()
  ),
  
  
  # Gridded predictions -----------------------------------------------------
  # Generate a grid of points
  tar_target(
    seus,
    get_seus_shape()
  ),
  tar_target(
    grid_data,
    make_grid_data(seus)
  ),
  # Get weather data for those points
  tar_target(
    grid_daymet,
    get_daymet_monthly(grid_data) 
  ),
  # Calculate bioclim
  tar_target(
    grid_bioclim,
    calc_bioclim(grid_daymet)
  ),
  # Create phenotype and ecosystem combinations and wrangle data
  tar_target(
    newdata,
    expand_grid(
      phenotype = c("antho", "dwarf", "hotleaf", "wildtype"),
      ecosystem = c("mixed", "pine", "prairie"),
      grid_bioclim
    )
  ),
  # Predict on those points and wrangle
  tar_target(
    grid_pred,
    left_join(
      augment(rf_fit, new_data = newdata),
      grid_data |> dplyr::select(-start, -end)
    )
  ),
  # Make map
  tar_target(
    pred_map,
    make_pred_map(grid_pred, seus)
  ),
  tar_target(
    pred_map_diff,
    make_pred_map_diff(grid_pred, seus)
  ),
  
  # Proportion AGB timeseries -----------------------------------------------
  
  tar_target(
    prop_quantiles,
    calc_prop_agb(setaria_data)
  ),
  tar_target(
    prop_agb_plot,
    plot_prop_agb(prop_quantiles)
  ),
  
  # Save figures out --------------------------------------------------------
  
  tar_file(
    pred_map_png,
    ggsave("figures/npp_map.png", pred_map)
  ),
  tar_file(
    pred_map_diff_png,
    ggsave("figures/diff_map.png", pred_map_diff)
  ),
  
  # Report ------------------------------------------------------------------
  
  # Welsch has an old version of Quarto that doesn't work
  tar_render(report, "docs/report.Rmd"),
) |> 
  tarchetypes::tar_hook_before(tidymodels_prefer())
