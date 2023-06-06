# library(targets)
# tar_load_globals()
# tar_load(setaria_data)
# # Calculate proportion of biomass that is Setaria in each run
# setaria_data$pft |> unique()


plot_prop_agb <- function(setaria_data) {
  setaria_data |> 
    dplyr::select(site, ecosystem, phenotype, date, pft, AGB_PFT) |> 
    group_by(site, ecosystem, phenotype, date) |> 
    mutate(
      AGB_total = sum(AGB_PFT),
      AGB_prop = AGB_PFT/AGB_total
    ) |> 
    filter(pft == 1) |> 
    ggplot(aes(x = date, y = AGB_prop)) +
    geom_line(alpha = 0.2, linewidth = 0.2, aes(group = site)) +
    stat_summary(fun = median, geom = "line", color = "blue", linewidth = 0.6) +
    scale_y_continuous(labels = scales::label_percent()) +
    scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
    facet_grid(ecosystem ~ phenotype, scales = "free_y", labeller = as_labeller(str_to_sentence)) +
    labs(x = "Simulation date", y = "% AGB") +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
    
}
# plot_prop_agb(setaria_data)

  