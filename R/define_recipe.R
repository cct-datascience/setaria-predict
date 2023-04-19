define_recipe <- function(ens_train) {
  recipe(npp_summer ~ ., data = ens_train) |> 
    step_dummy(all_nominal_predictors()) |> 
    step_zv(all_predictors()) |> 
    step_normalize(all_numeric_predictors())
}