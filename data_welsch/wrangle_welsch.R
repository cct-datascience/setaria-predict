#' After copying select data from Welsch's /data/ directory, this script
#' combines those many small files into a single .arrow dataset that can serve
#' as a starting point for the modeling pipeline. 
library(fs)
library(tidyverse)
library(arrow)
library(pins)
library(rsconnect)

df_transect <-
  dir_ls("data_welsch/transect", recurse = TRUE, glob = "*.csv") |> 
  read_csv()

df_sample <-
  dir_ls("data_welsch/seus_sample", recurse = TRUE, glob = "*.csv") |> 
  read_csv()

df <- bind_rows("transect" = df_transect, "sample" = df_sample, .id = "set")

write_parquet(df, "data/all_runs.parquet")

# Get .Rdata files for SA

base_path <- "data_welsch/transect"
sites <- dir_ls(base_path, recurse = 1, regexp = "mixed$|prairie$|pine$")

sa_output <-
  map(sites, \(.x) {
    sa_results <- .x |> 
      dir_ls(regexp = "sensitivity\\.results") 
    if(length(sa_results)==1) {
      load(sa_results)
      sensitivity.results$SetariaWT2$variance.decomposition.output |>
        bind_rows(.id = "x") |>
        pivot_longer(-x, names_to = "trait") |>
        pivot_wider(names_from = x, values_from = value)
    }
  }) |> 
  bind_rows(.id = "dir") |> 
  mutate(
    ecosystem = dir |> path_split() |> map_chr(4),
    site = dir |> path_split() |> map_chr(3)
  ) |> 
  select(site, ecosystem, everything()) |>
  select(-dir) |> 
  mutate(trait = case_when(
    trait == "leaf_turnover_rate"   ~ "Leaf turnover rate",
    trait == "nonlocal_dispersal"   ~ "Seed dispersal",
    trait == "fineroot2leaf"        ~ "Fine root allocation",
    trait == "root_turnover_rate"   ~ "Root turnover rate",
    trait == "seedling_mortality"   ~ "Seedling mortality",
    trait == "stomatal_slope"       ~ "Stomatal slope",
    trait == "quantum_efficiency"   ~ "Quantum efficiency",
    trait == "Vcmax"                ~ "Vcmax",
    trait == "r_fract"              ~ "Reproductive allocation",
    trait == "cuticular_cond"       ~ "Cuticular conductance",
    trait == "SLA"                  ~ "Specific leaf area",
    TRUE ~ trait
  ))

write_csv(sa_output, "data/sa_output.csv")
