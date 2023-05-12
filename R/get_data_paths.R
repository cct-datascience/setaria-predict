get_data_paths <- function(paths, phenotype = c("wildtype", "antho", "dwarf", "hotleaf")) {
  phenotype <- match.arg(phenotype)
  
  run_regex <- 
    switch(
      phenotype,
      "wildtype" = "SA-median$",
      "antho" = "SA-SetariaWT2-quantum_efficiency-0.159$",
      "dwarf" = "SA-SetariaWT2-fineroot2leaf-0.841$",
      "hotleaf" = "SA-SetariaWT2-stomatal_slope-0.159$"
    )
  
  dir_ls(paths) |>
    # get from initial path to individual run out dirs
    dir_ls(regexp = "mixed$|pine$|prairie$") |> 
    path("out") |> 
    # get just one "phenotype"
    dir_ls(regexp = run_regex) |> 
    dir_ls(regexp = "run_data.csv")
  
}

# get_data_paths("/data/output/pecan_runs/transect/")
