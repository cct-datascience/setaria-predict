define_recipe <- function(data_train) {
  recipe(npp_yr10 ~ ., data = data_train) |> 
    update_role(everything(), new_role = "predictor") |> 
    update_role(npp_yr10, new_role = "outcome") |> 
    update_role(site, new_role = "id") |> 
    step_normalize(all_numeric_predictors()) |> 
    step_interact(~genotype:ecosystem) |> 
    step_dummy(all_nominal_predictors()) |> 
    step_log(all_outcomes(), id = "log_resp", skip = TRUE) |> #log transform response to improve normality of residuals.
    step_zv(all_predictors()) |> #remove predictors with zero variance
    step_pca(starts_with("bio"), threshold = 0.85) |> #maybe not necessary? RMSE is identical with and without, rsq slightly higher with pca. Check literature!
    prep(training = data_train, retain = TRUE) 
}
# define_recipe(data_train) |> bake(data_train) |> View()
#' TODO: 
#' - Consider step_pca() for bioclim variables since they are likely collinear
#'   and possibly redundant.  Look to literature to see how others use bioclim.
#' - You can `tune()` the `threshold` argument in `step_pca()` (or `num_comp`)