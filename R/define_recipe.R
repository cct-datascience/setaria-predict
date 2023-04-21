define_recipe <- function(ens_train) {
  recipe(ens_train) |> 
    update_role(everything(), new_role = "predictor") |> 
    update_role(npp_summer, new_role = "outcome") |> 
    step_num2factor(year, levels = as.character(2000:2010)) |> 
    step_dummy(c(all_nominal_predictors(), -ens_unique)) |> 
    step_zv(all_predictors()) |> 
    step_normalize(all_numeric_predictors())
}
