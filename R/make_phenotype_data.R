# tar_load(setaria_raw)
# tar_load_globals()


#' Extract "phenotype" simulation runs from complete raw data
#' 
#' Filters dataset to include only particular sensitivity analysis runs that map
#' to hypothetical *Setaria* phenotypes
#'
#' @param setaria_raw the setaria_raw target
#'
#' @return a tibble
#' 
make_phenotype_data <- function(setaria_raw) {
  
  setaria_raw |> 
    mutate(phenotype = case_when(
      str_detect(ensemble, "SA-median$") ~ "wildtype",
      str_detect(ensemble, "SA-SetariaWT2-quantum_efficiency-0.159$") ~ "antho",
      str_detect(ensemble, "SA-SetariaWT2-fineroot2leaf-0.841$") ~ "dwarf",
      str_detect(ensemble, "SA-SetariaWT2-stomatal_slope-0.159$") ~ "hotleaf"
    )) |> 
    filter(!is.na(phenotype)) |> 
    dplyr::select(-ensemble) |> 
    group_by(site, ecosystem, phenotype) |>
    mutate(start = min(date), end = max(date)) |> 
    ungroup()
}
