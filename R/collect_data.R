collect_data <- function(files) {
 files |> 
    read_csv() |> 
    group_by(site, ecosystem) |>
    mutate(start = min(date), end = max(date)) |> 
    ungroup() |> 
    filter(pft == 1) |> #keep only Setaria
    rename(sa_run = ensemble)
}