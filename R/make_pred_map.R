# library(targets)
# tar_load_globals()
# tar_load(c(
#   grid_pred,
#   seus
# ))

#' TODO
#' Plot % differences from wildtype with separate panel for NPP of wildtype
#' Maybe show on log scale?
#' Other response variables:
#' - proportion of biomass
#' - density
make_pred_map <- function(grid_pred, seus) {
  #create raster of predicted data
  pred_sf <- 
    grid_pred |> 
    dplyr::select(genotype, ecosystem, lat, lon, .pred) |> 
    mutate(NPP = exp(.pred)) |> 
    st_as_stars(coords = c("lon", "lat"), dims = c("lon", "lat", "ecosystem", "genotype"))
  
  #plot raster and state boundaries
  ggplot() +
    geom_stars(data = pred_sf, mapping = aes(fill = NPP), na.action = na.omit) +
    geom_sf(data = seus, fill = NA) +
    coord_sf() +
    scale_fill_viridis_c() +
    labs(fill = "Summer NPP in year 10 [kg/m^2/s]") +
    facet_grid(genotype ~ ecosystem, labeller = label_both) +
    theme(legend.position = "top")
  
}