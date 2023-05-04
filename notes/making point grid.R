# https://stackoverflow.com/questions/65687204/quickly-filter-down-a-grid-of-sf-points-according-to-a-polygon
library(targets)
library(sf)
library(terra)
tar_load_globals()

temp_zip <- tempfile(fileext = ".zip")
download.file(
  "https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_state_500k.zip", 
  destfile = temp_zip
)
unzip(temp_zip, exdir = tempdir())
us <- st_read(file.path(tempdir(), "cb_2019_us_state_500k.shp"))

seus <- us |> 
  filter(NAME %in% c(
    "Florida",
    "Georgia",
    "South Carolina",
    "North Carolina",
    "Alabama",
    "Mississippi",
    "Tennessee"
  )) |> 
  st_transform(crs = "NAD83") #datum for US

ggplot() +
  geom_sf(data = seus)


#create empty raster
increment <- 0.5 #spacing of points in decimal degrees
seusrast <- terra::rast(seus, resolution=rep(increment, 2))

# rasterize the shapefile
r <- terra::rasterize(vect(seus), seusrast, "NAME")

# extract raster cell coordinates
points <- 
  r |> 
  stars::st_as_stars() |>
  st_as_sf(as_points = TRUE)

ggplot() +
  geom_sf(data = seus) +
  geom_sf(data = points, size = 0.01)

dim(points)
