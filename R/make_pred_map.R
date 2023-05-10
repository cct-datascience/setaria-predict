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
  usa <- st_as_sf(maps::map("usa", plot = FALSE, fill = TRUE))
  
  #create raster of predicted data
  pred_sf <- 
    grid_pred |> 
    dplyr::select(genotype, ecosystem, lat, lon, .pred) |> 
    mutate(NPP = exp(.pred)) |> 
    st_as_stars(coords = c("lon", "lat"), dims = c("lon", "lat", "ecosystem", "genotype"))
  
  #plot raster and state boundaries
  ggplot() +
    geom_sf(data = usa, fill = "antiquewhite1") +
    geom_stars(data = pred_sf, mapping = aes(fill = NPP), na.action = na.omit) +
    geom_sf(data = seus, fill = NA) +
    geom_sf_label() +
    facet_grid(genotype ~ ecosystem, labeller = as_labeller(str_to_sentence)) +
    coord_sf(xlim = st_bbox(seus)[c(1,3)], ylim = st_bbox(seus)[c(2, 4)]) +
    scale_fill_viridis_c(
      trans = scales::log_trans(),
      labels = scales::label_log(digits = 2),
      breaks = scales::breaks_log(n = 8)
    ) +
    scale_y_continuous(breaks = c(25, 30, 35, 40)) +
    scale_x_continuous(breaks = c(-75, -80, -85, -90)) +
    guides(
      fill = guide_colorbar(
        title = "Summer NPP in year 10 [kg/m^2/s]",
        title.position = "top",
        barwidth = unit(10, "cm"),
      )) +
    theme_bw() +
    theme(
      legend.position = "bottom",
      legend.justification = "center",
      axis.title = element_blank(),
      panel.grid.major = element_line(color = "grey50", linetype = "dashed", linewidth = 0.2),
      panel.background = element_rect(fill = "aliceblue"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
}



#' Map proportional difference from wildtype at all ecosystems for all genotypes
#'
#' This is similar to maps above, but first calculates a proportional change in
#' NPP compared to wildtype [i.e. (genotype - wildtype) / wildtype].
make_pred_map_diff <- function(grid_pred, seus) {
  
  usa <- st_as_sf(maps::map("usa", plot = FALSE, fill = TRUE))
  
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
    geom_sf(data = usa, fill = "antiquewhite1") +
    geom_stars(
      data = prop_diff_sf,
      mapping = aes(fill = prop_diff),
      na.action = na.omit
    ) +
    geom_sf(data = seus, fill = NA) +
    facet_grid(genotype ~ ecosystem, labeller = as_labeller(str_to_sentence)) +
    coord_sf(xlim = st_bbox(seus)[c(1,3)], ylim = st_bbox(seus)[c(2, 4)]) +
    colorspace::scale_fill_continuous_diverging(
      palette = "Blue-Red",
      labels = scales::percent_format(),
      breaks = scales::pretty_breaks(n = 8)
    ) +
    scale_y_continuous(breaks = c(25, 30, 35, 40)) +
    scale_x_continuous(breaks = c(-75, -80, -85, -90)) +
    guides(
      fill = guide_colorbar(
        title = "% Difference summer NPP",
        title.position = "top",
        barwidth = unit(10, "cm"),
      )
    ) +
    theme_bw() +
    theme(
      legend.position = "bottom",
      legend.justification = "center",
      axis.title = element_blank(),
      panel.grid.major = element_line(color = "grey50", linetype = "dashed", linewidth = 0.2),
      panel.background = element_rect(fill = "aliceblue"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
}

