#' Prep datasets for random forest model
#'
#' This calculates mean summer (Jun - Aug) NPP for the final year of the
#' simulation (2010) at each site and ecosystem.  These data are then joined
#' with bioclim variables for each site calculated using monthly means across
#' the entire simulation. These bioclim variables are to be used as predictors.
#' 
#' @param data a simulation data target for a single genotype, such as
#'   `wiltdype_data`
#' @param bioclim the bioclim target
#' @param resp the column name in `data` to be used as a response variable
#'
#' @return a tibble
#'
#' @examples
#' create_model_data(wildtype_data, bioclim)
create_model_data <- function(data, bioclim) {
  response <- data|> 
    filter(year(date) == max(year(date)) & month(date) %in% c(6,7,8)) |> 
    group_by(genotype, site, ecosystem) |> 
    summarize(npp_yr10 = mean(NPP_PFT), .groups = "drop")
  
  left_join(response, bioclim, join_by(site))
}