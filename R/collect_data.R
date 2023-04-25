collect_data <- function(files) {
 files |> 
    read_csv() |> 
    group_by(site, ecosystem) |>
    mutate(start = min(date), end = max(date)) |> 
    ungroup() |> 
    rename(sa_run = ensemble)
}