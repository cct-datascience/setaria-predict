calc_bioclim <- function(daymet_monthly) {
  daymet_monthly |> 
    mutate(month = month(date)) |> 
    group_by(site, month) |> 
    summarize(across(c(mean_precip, min_temp, max_temp), mean),  .groups = "drop") |> 
    group_by(site) |> 
    reframe(biovars(mean_precip, min_temp, max_temp) |> as_tibble())
}