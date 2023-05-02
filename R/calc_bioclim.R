calc_bioclim <- function(daymet_monthly) {
  bio <- daymet_monthly |> 
    mutate(month = month(date)) |> 
    group_by(site, month) |> 
    summarize(across(c(mean_precip, min_temp, max_temp), mean),  .groups = "drop") |> 
    group_by(site) |> 
    reframe(biovars(mean_precip, min_temp, max_temp) |> as_tibble())
  
  other <- daymet_monthly |> 
    group_by(site) |> 
    summarize(across(c(mean_vpd, mean_srad), mean))
  left_join(bio, other, join_by(site))
}