combine_data <- function(ens_output, ens_params, daymet_monthly) {
  left_join(ens_output, ens_params, by = join_by(ecosystem, site, ens_num)) |> 
    left_join(daymet_monthly, join_by(site, date)) |> 
    # Keep just data for setaria (pft 1)
    filter(pft == 1) |> 
    select(
      # Data structure
      site,
      # lat,
      # lon,
      ecosystem, 
      ensemble,
      date, 
      # Response vars
      #AGB_PFT,
      NPP_PFT, 
      # Traits
      leaf_turnover_rate,
      nonlocal_dispersal,
      fineroot2leaf,
      root_turnover_rate,
      seedling_mortality,
      stomatal_slope,
      quantum_efficiency,
      Vcmax,
      r_fract,
      cuticular_cond,
      SLA,
      # Weather
      starts_with("mean_")
    )
}