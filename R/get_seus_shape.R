get_seus_shape <- function() {
  #download and read in shape file for US states
  temp_zip <- tempfile(fileext = ".zip")
  download.file(
    "https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_state_500k.zip", 
    destfile = temp_zip
  )
  unzip(temp_zip, exdir = tempdir())
  us <- st_read(file.path(tempdir(), "cb_2019_us_state_500k.shp"))
  
  # filter to just southeast US
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
    st_transform(crs = "NAD83")
  seus
}