# library(targets)
# tar_load_globals()
# tar_load(setaria_data)
# # Calculate proportion of biomass that is Setaria in each run
# setaria_data$pft |> unique()

calc_prop_agb <- function(setaria_data) {
  prop_data <- 
    setaria_data |> 
    dplyr::select(site, ecosystem, phenotype, date, pft, AGB_PFT) |> 
    group_by(site, ecosystem, phenotype, date) |> 
    mutate(
      AGB_total = sum(AGB_PFT),
      AGB_prop = AGB_PFT/AGB_total
    ) |> 
    filter(pft == 1) 
  
  prop_quantiles <- 
    prop_data |> 
    group_by(ecosystem, phenotype, date) |> #calc across sites
    reframe(quantile(AGB_prop, probs = c(0.25, 0.5, 0.75)) |>
              enframe() |>
              pivot_wider())
  
  # return
  prop_quantiles
}

plot_prop_agb <- function(prop_quantiles) {
  ggplot(prop_quantiles, aes(x = date)) +
    facet_grid(ecosystem~phenotype, scales = "free_y", labeller = label_both) +
    geom_ribbon(aes(ymin = `25%`, ymax = `75%`), alpha = 0.5) +
    geom_line(aes(y = `50%`), linewidth = 0.25) +
    scale_y_continuous(labels = scales::label_percent()) +
    scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
    labs(x = "Simulation date", y = "% AGB") +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
}