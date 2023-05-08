# library(targets)
# tar_load_globals()
# tar_load(c(
#   grid_pred,
#   seus
# ))

#' TODO
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
    scale_y_continuous(breaks = c(25, 30, 35, 40)) +
    scale_x_continuous(breaks = c(-75, -80, -85, -90)) +
    labs(fill = "Summer NPP in year 10 [kg/m^2/s]") +
    facet_grid(genotype ~ ecosystem, labeller = label_both) +
    theme_bw() +
    theme(
      legend.position = "top",
      axis.title = element_blank(),
      panel.background = element_rect(fill = "azure")
    )
  
}

# same as above but don't backtransform
make_pred_map_log <- function(grid_pred, seus) {
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
    geom_sf_label() +
    coord_sf() +
    scale_fill_viridis_c(
      trans = scales::log_trans(),
      labels = scales::label_log(digits = 2),
      breaks = scales::breaks_log(n = 4)
    ) +
    scale_y_continuous(breaks = c(25, 30, 35, 40)) +
    scale_x_continuous(breaks = c(-75, -80, -85, -90)) +
    labs(fill = "Summer NPP in year 10 [kg/m^2/s]") +
    facet_grid(genotype ~ ecosystem, labeller = label_both) +
    theme_bw() +
    theme(
      legend.position = "top",
      axis.title = element_blank(),
      panel.background = element_rect(fill = "azure")
    )
  
}

#' Map proportional difference from wildtype at all ecosystems for all genotypes
#'
#' This is similar to maps above, but first calculates a proportional change in
#' NPP compared to wildtype [i.e. (genotype - wildtype) / wildtype].
make_pred_map_diff <- function(grid_pred, seus) {
  
  prop_diff_sf <-
    grid_pred |> 
    dplyr::select(genotype, ecosystem, lat, lon, .pred) |> 
    pivot_wider(values_from = .pred, names_from = genotype) |> 
    mutate(across(c(antho, dwarf, hotleaf, wildtype), exp)) |> 
    mutate(across(c(antho, dwarf, hotleaf), \(x) (x - wildtype) / wildtype)) |> 
    dplyr::select(-wildtype) |> 
    pivot_longer(c(antho, dwarf, hotleaf), names_to = "genotype", values_to = "prop_diff") |> 
    st_as_stars(coords = c("lon", "lat"), dims = c("lon", "lat", "ecosystem", "genotype"))
  
  ggplot() +
    geom_stars(
      data = prop_diff_sf,
      mapping = aes(fill = prop_diff),
      na.action = na.omit
    ) +
    geom_sf(data = seus, fill = NA) +
    facet_grid(genotype ~ ecosystem, labeller = label_both) +
    coord_sf() +
    colorspace::scale_fill_continuous_diverging(
      palette = "Blue-Red",
      labels = scales::percent_format(),
      breaks = scales::pretty_breaks(n = 8)
    ) +
    scale_y_continuous(breaks = c(25, 30, 35, 40)) +
    scale_x_continuous(breaks = c(-75, -80, -85, -90)) +
    guides(
      fill = guide_colorbar(
        title = "% Difference in mean summer NPP compared to wildtype",
        title.position = "top",
        barwidth = unit(10, "cm"),
      )
    ) +
    theme_bw() +
    theme(
      legend.position = "top",
      legend.justification = "center",
      axis.title = element_blank(),
      panel.background = element_rect(fill = "azure")
    )
  
}