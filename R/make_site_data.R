make_site_data <- function(...) {
  bind_rows(...) |> 
    group_by(site) |> 
    summarize(across(c(lon, lat, start, end), unique), .groups = "drop")
}
