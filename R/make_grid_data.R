#' Create grid of points over Southeast US states
#' @param seus an sf object
#' @param increment spacing of grid points in degrees
#'
#' @return a tibble prepped to work as input to get_daymet_monthly()
make_grid_data <- function(seus, increment = 0.5) {

  
  #create empty raster
  seusrast <- terra::rast(seus, resolution=rep(increment, 2))
  
  # rasterize the shapefile
  r <- terra::rasterize(vect(seus), seusrast, "NAME")
  
  # extract raster cell coordinates
  points <- 
    r |> 
    stars::st_as_stars() |>
    st_as_sf(as_points = TRUE)
  
  st_coordinates(points) |>
    as_tibble() |> 
    rename(lon = X, lat = Y) |> 
    #prep other columns so the output works with get_daymet_monthly()
    mutate(
      site = as.character(1:n()),
      start = lubridate::ymd("2000-06-01"),
      end = lubridate::ymd("2010-06-01")
    )
}