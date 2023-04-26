define_recipe <- function(data_train) {
  recipe(npp_yr10 ~ ., data = data_train) |> 
    update_role(everything(), new_role = "predictor") |> 
    update_role(npp_yr10, new_role = "outcome") |> 
    update_role(site, new_role = "id") |> 
    step_log(all_outcomes(), id = "log_resp", skip = TRUE) |> #log transform response to improve normality of residuals.
    step_dummy(all_nominal_predictors()) |> 
    step_zv(all_predictors()) |> 
    step_normalize(all_numeric_predictors()) |> 
    prep(training = data_train, retain = TRUE) #not 100% sure what this does
}
