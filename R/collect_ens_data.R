collect_ens_data <- function(files) {
 files |> 
    read_csv() |> 
    mutate(
      ens_num = str_extract(ensemble, "(?<=ENS-)\\d+(?=-)") |> 
        parse_number()
    ) |> 
    group_by(site, ecosystem) |>
    mutate(start = min(date), end = max(date)) |> 
    ungroup()
}