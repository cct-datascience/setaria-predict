combine_wrangle <- function(genotype_data, daymet_monthly) {
  left_join(
    genotype_data |>
      # Keep just data for setaria (pft 1)
      filter(pft == 1),
    daymet_monthly,
    by = join_by(site, date)
    ) |> 
    select(
      # Data structure
      site,
      # lat,
      # lon,
      ecosystem, 
      date, 
      # Response vars
      #AGB_PFT,
      NPP_PFT, 
      # Weather
      starts_with("mean_")
    ) |> 
    mutate(run_id = paste(site, ecosystem, sep = "_"))
}