# library(targets)
# tar_load_globals()
# tar_load(c(
#   site_data,
#   seus
# ))

plot_sites <- function(site_data, seus) {
  
  usa <- st_as_sf(maps::map("state", plot = FALSE, fill = TRUE))
  site_points <- site_data |> 
    dplyr::select(set, site, lon, lat) |> 
    st_as_sf(coords = c("lon", "lat"), dim = "XY", crs = crs(usa))
  
  ggplot() +
    geom_sf(data = usa, fill = "antiquewhite1") +
    geom_sf(data = site_points, aes(color = set, shape = set)) +
    scale_color_discrete("Simulation Set",labels = str_to_sentence) +
    scale_shape_discrete("Simulation Set", labels = str_to_sentence) +
    coord_sf(xlim = st_bbox(seus)[c(1,3)], ylim = st_bbox(seus)[c(2, 4)]) +
    theme_bw() +
    theme(
      axis.title = element_blank(),
      panel.grid.major = element_line(color = "grey50", linetype = "dashed", linewidth = 0.2),
      panel.background = element_rect(fill = "aliceblue"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
}