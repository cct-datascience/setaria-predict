collect_ens_params <- function(path) {
  outdirs <-  
    dir_ls(path) |>
    dir_ls(regexp = "mixed$|pine$|prairie$")
  params <- 
    outdirs |> 
    dir_ls(regexp = "ensemble.samples.NOENSEMBLEID.Rdata") |> 
    map(\(x) {
      load(x)
      ens.samples$SetariaWT2 |>
        as_tibble(rownames = "ens_num") |>
        mutate(ens_num = as.numeric(ens_num))
    }) |> 
    list_rbind(names_to = "path") |> 
    mutate(
      ecosystem = path_split(path) |> map_chr(-2),
      site = path_split(path) |> map_chr(-3)
    ) |> 
    select(-path) |> 
    select(site, ecosystem, everything())
}