# library(targets)
# tar_load_globals()
# tar_load(sa_output)

plot_sa_summary <- function(sa_output) {
  
  sem <- function(x) {
    sd(x) / sqrt(length(x))
  }
  
  sa_summary <- 
    sa_output |>
    group_by(ecosystem, trait) |> 
    summarize(across(c("coef.vars", "elasticities", "sensitivities"), .fns = list("mean" = mean, "SE" = sem)))
  
  ggplot(sa_summary, aes(y = trait)) +
    geom_pointrange(
      aes(
        x = elasticities_mean,
        xmin = elasticities_mean - elasticities_SE,
        xmax = elasticities_mean + elasticities_SE
      )
    ) +
    geom_vline(xintercept = 0, alpha = .5, linetype = 3) +
    facet_grid(~ecosystem, scales = "free", labeller = as_labeller(str_to_sentence)) +
    labs(caption = "Means ± SE for 9 sites", x = "Elasticity", y="")
  
}


