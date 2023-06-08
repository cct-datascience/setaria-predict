plot_dens <- function(setaria_data) {
  
  setaria_data |> 
    filter(pft == 1) |> 
    ggplot(aes(x = date, y = DENS)) +
    geom_line(alpha = 0.2, linewidth = 0.2, aes(group = site)) +
    stat_summary(fun = median, geom = "line", color = "blue", linewidth = 0.6) +
    scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
    facet_grid(ecosystem ~ phenotype, labeller = as_labeller(str_to_sentence)) +
    labs(x = "Simulation date", y = "Density (plants / m<sup>2</sup>)") +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.title.y = ggtext::element_markdown()
    )
  
}