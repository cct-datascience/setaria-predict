# tar_load(ens_complete)
wrangle_data <- function(ens_complete) {
  ens_complete |> 
    filter(month(date) %in% c(6,7,8)) |> 
    mutate(year = year(date)) |> 
    group_by(site, ecosystem, ensemble, year) |> 
    select(-date) |> 
    summarize(across(everything(),  mean),  .groups = "drop") |> 
    rename(npp_summer = NPP_PFT)
}