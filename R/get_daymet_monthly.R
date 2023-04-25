get_daymet_monthly <- function(site_data) {
  site_data |>
    pmap(\(site, lat, lon, start, end, ...) {
      out <- 
        download_daymet(
          site  = site,
          lat   = lat,
          lon   = lon,
          start = year(start),
          end   = year(end)
        )
      out$data |>
        mutate(
          date = make_date(year = year, month = 1, day = 1) + days(yday - 1),
          month = month(date)
        ) |> 
        clean_names() |> 
        mutate(tavg_deg_c = (tmin_deg_c + tmax_deg_c) / 2,
               dayl_day = dayl_s / 86400) |> 
        group_by(year, month) |> 
        summarize(across(c(
          temp = tavg_deg_c,
          vpd = vp_pa,
          precip = prcp_mm_day,
          srad = srad_w_m_2,
          swe = swe_kg_m_2,
          dayl = dayl_day
        ),
        .fns = c(mean = ~mean(., na.rm = TRUE)), 
        .names = "{.fn}_{.col}")) |> 
        mutate(site = out$site) |> 
        #reconstitute date
        mutate(date = make_date(year = year, month = month, day = 1)) |> 
        select(-year, -month)
    }) |>
    list_rbind()
}