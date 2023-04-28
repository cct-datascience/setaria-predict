define_recipe <- function(data_train) {
  recipe(npp_yr10 ~ ., data = data_train) |> 
    update_role(everything(), new_role = "predictor") |> 
    update_role(npp_yr10, new_role = "outcome") |> 
    update_role(site, new_role = "id") |> 
    step_log(all_outcomes(), id = "log_resp", skip = TRUE) |> #log transform response to improve normality of residuals.
    step_dummy(all_nominal_predictors()) |> 
    step_zv(all_predictors()) |> #remove predictors with zero variance
    step_normalize(all_numeric_predictors()) |> 
    prep(training = data_train, retain = TRUE) #not 100% sure what this does
}

#' TODO: 
#' - Consider step_pca() for bioclim variables since they are likely collinear
#'   and possibly redundant.  Look to literature to see how others use bioclim.
#' - Add means of mean_vpd and mean_srad as predictors
#' - Consider an interaction between genotype and ecosystem as a predictor