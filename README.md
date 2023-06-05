
<!-- README.md is generated from README.Rmd. Please edit that file -->

# setaria-predict

<!-- badges: start -->
<!-- badges: end -->

The goal of setaria-predict is to train a model using simulation output
from ED2 to create an ED2 “emulator” of sorts. Then, we can use this
model to predict the growth of *Setaria* at new locations.

We will use runs from the sensitivity analysis as stand-ins for
different *Setaria* genotypes and train models using site location
and/or weather data as predictors, then predict aboveground biomass or
NPP of *Setaria* at new sites.

## Reproducibility

This project uses
[`renv`](https://rstudio.github.io/renv/articles/renv.html) for package
management. When opening this repo as an RStudio Project for the first
time, `renv` should automatically install itself and prompt you to run
`renv::restore()` to install all package dependencies.

This project uses the [`targets`
package](https://docs.ropensci.org/targets/) for workflow management.
Run `targets::tar_make()` from the console to run the workflow and
reproduce all results.

The data for this project is on the Welsch server, so you probably won’t
be able to reproduce this workflow outside of that environment.

**Targets workflow:**

``` mermaid
graph LR
  subgraph legend
    direction LR
    x0a52b03877696646([""Outdated""]):::outdated --- x7420bd9270f8d27d([""Up to date""]):::uptodate
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
  end
  subgraph Graph
    direction LR
    x691fe2667432a68c>"make_phenotype_data"]:::uptodate --> x84746b2e0f9f6b50(["setaria_data"]):::outdated
    xba8bb58288d54f0e(["setaria_raw"]):::outdated --> x84746b2e0f9f6b50(["setaria_data"]):::outdated
    x4b7f0494130845c9(["grid_data"]):::uptodate --> x1e2f629700cdf2b0(["grid_pred"]):::outdated
    x80f8daf00aa10777(["newdata"]):::uptodate --> x1e2f629700cdf2b0(["grid_pred"]):::outdated
    x251ec748a49d82a0(["rf_fit"]):::outdated --> x1e2f629700cdf2b0(["grid_pred"]):::outdated
    x27f4571812c133e6>"make_site_data"]:::uptodate --> x2032b88ecc3ceb3d(["site_data"]):::outdated
    x84746b2e0f9f6b50(["setaria_data"]):::outdated --> x2032b88ecc3ceb3d(["site_data"]):::outdated
    xbea1d239f1152dfe>"get_seus_shape"]:::uptodate --> xae0bb90779bc5978(["seus"]):::uptodate
    xe79aca23d28071ab(["data_split"]):::outdated --> xaa3dacfc0774d27e(["data_train"]):::outdated
    xaa3dacfc0774d27e(["data_train"]):::outdated --> xfe69c4366ba0129f(["lm_fit"]):::outdated
    x541d164e38df8517(["lm_hyperparameters"]):::outdated --> xfe69c4366ba0129f(["lm_fit"]):::outdated
    x7d700859457f5791(["lm_workflow"]):::outdated --> xfe69c4366ba0129f(["lm_fit"]):::outdated
    x9d9a71525b73affe>"make_grid_data"]:::uptodate --> x4b7f0494130845c9(["grid_data"]):::uptodate
    xae0bb90779bc5978(["seus"]):::uptodate --> x4b7f0494130845c9(["grid_data"]):::uptodate
    xe79aca23d28071ab(["data_split"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x4b7f0494130845c9(["grid_data"]):::uptodate --> xe0fba61fbc506510(["report"]):::outdated
    x0dd52ca5681d2dec(["lm_cv"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x82c80750d3c3aa91(["lm_pred_plot"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x40f6344f44be00c4(["pred_map"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x221c4544dec83bd3(["pred_map_diff"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x03f8f197baa464a7(["rf_cv"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x7ee10909b9e9ca92(["rf_pred_plot"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    x2c6a769cc6041606(["rf_recipe"]):::outdated --> xe0fba61fbc506510(["report"]):::outdated
    xae0bb90779bc5978(["seus"]):::uptodate --> xe0fba61fbc506510(["report"]):::outdated
    x2dc7e80e5e9b239f(["rf_grid_results"]):::outdated --> x6f6ea77a33e65215(["rf_hyperparameters"]):::outdated
    xe79aca23d28071ab(["data_split"]):::outdated --> x13288cb0758ce97d(["data_test"]):::outdated
    x40f6344f44be00c4(["pred_map"]):::outdated --> xd1d5de95fb768940(["pred_map_png"]):::outdated
    x37844348174eff01(["setaria_raw_hash"]):::started --> xba8bb58288d54f0e(["setaria_raw"]):::outdated
    xc226421a0b14850a>"plot_prop_agb"]:::uptodate --> x25a132700f092ff0(["prop_agb_plot"]):::outdated
    x1b1230a63dce64ae(["prop_quantiles"]):::outdated --> x25a132700f092ff0(["prop_agb_plot"]):::outdated
    x8165fe9985c10a4a(["rf_model"]):::uptodate --> x31fafe63f123d72c(["rf_workflow"]):::outdated
    x2c6a769cc6041606(["rf_recipe"]):::outdated --> x31fafe63f123d72c(["rf_workflow"]):::outdated
    x88226e7f0f4662b1(["data_folds"]):::outdated --> x03f8f197baa464a7(["rf_cv"]):::outdated
    x6f6ea77a33e65215(["rf_hyperparameters"]):::outdated --> x03f8f197baa464a7(["rf_cv"]):::outdated
    x31fafe63f123d72c(["rf_workflow"]):::outdated --> x03f8f197baa464a7(["rf_cv"]):::outdated
    x1e2f629700cdf2b0(["grid_pred"]):::outdated --> x40f6344f44be00c4(["pred_map"]):::outdated
    x446632179a854016>"make_pred_map"]:::uptodate --> x40f6344f44be00c4(["pred_map"]):::outdated
    xae0bb90779bc5978(["seus"]):::uptodate --> x40f6344f44be00c4(["pred_map"]):::outdated
    xab1a71ecca0d9614(["grid_bioclim"]):::uptodate --> x80f8daf00aa10777(["newdata"]):::uptodate
    xaa3dacfc0774d27e(["data_train"]):::outdated --> x88226e7f0f4662b1(["data_folds"]):::outdated
    x5cc0a89ed2100046>"calc_bioclim"]:::uptodate --> xc26e685f03c57771(["bioclim"]):::outdated
    x001de431ee97eb4a(["daymet_monthly"]):::outdated --> xc26e685f03c57771(["bioclim"]):::outdated
    x88226e7f0f4662b1(["data_folds"]):::outdated --> x0dd52ca5681d2dec(["lm_cv"]):::outdated
    x541d164e38df8517(["lm_hyperparameters"]):::outdated --> x0dd52ca5681d2dec(["lm_cv"]):::outdated
    x7d700859457f5791(["lm_workflow"]):::outdated --> x0dd52ca5681d2dec(["lm_cv"]):::outdated
    xc26e685f03c57771(["bioclim"]):::outdated --> xa3f7d12cb273bbe2(["model_data"]):::outdated
    xb1bfd93c0984802a>"create_model_data"]:::uptodate --> xa3f7d12cb273bbe2(["model_data"]):::outdated
    x84746b2e0f9f6b50(["setaria_data"]):::outdated --> xa3f7d12cb273bbe2(["model_data"]):::outdated
    xaa3dacfc0774d27e(["data_train"]):::outdated --> x2dc7e80e5e9b239f(["rf_grid_results"]):::outdated
    xb66df7ac83f87f08(["rf_grid"]):::uptodate --> x2dc7e80e5e9b239f(["rf_grid_results"]):::outdated
    x31fafe63f123d72c(["rf_workflow"]):::outdated --> x2dc7e80e5e9b239f(["rf_grid_results"]):::outdated
    x69c7dddc4e8cfd76(["lm_grid_results"]):::outdated --> x541d164e38df8517(["lm_hyperparameters"]):::outdated
    x13288cb0758ce97d(["data_test"]):::outdated --> x82c80750d3c3aa91(["lm_pred_plot"]):::outdated
    xfe69c4366ba0129f(["lm_fit"]):::outdated --> x82c80750d3c3aa91(["lm_pred_plot"]):::outdated
    x86547e801250e368>"get_daymet_monthly"]:::uptodate --> x4f1371d8a31ead17(["grid_daymet"]):::uptodate
    x4b7f0494130845c9(["grid_data"]):::uptodate --> x4f1371d8a31ead17(["grid_daymet"]):::uptodate
    xa3f7d12cb273bbe2(["model_data"]):::outdated --> xe79aca23d28071ab(["data_split"]):::outdated
    x1e2f629700cdf2b0(["grid_pred"]):::outdated --> x221c4544dec83bd3(["pred_map_diff"]):::outdated
    x29dca615c423dffb>"make_pred_map_diff"]:::uptodate --> x221c4544dec83bd3(["pred_map_diff"]):::outdated
    xae0bb90779bc5978(["seus"]):::uptodate --> x221c4544dec83bd3(["pred_map_diff"]):::outdated
    x25a132700f092ff0(["prop_agb_plot"]):::outdated --> x562ba761c4660183(["prop_agb_plot_png"]):::outdated
    xaa3dacfc0774d27e(["data_train"]):::outdated --> x69c7dddc4e8cfd76(["lm_grid_results"]):::outdated
    x7c34938a17ec8f51(["lm_grid"]):::uptodate --> x69c7dddc4e8cfd76(["lm_grid_results"]):::outdated
    x7d700859457f5791(["lm_workflow"]):::outdated --> x69c7dddc4e8cfd76(["lm_grid_results"]):::outdated
    xaa3dacfc0774d27e(["data_train"]):::outdated --> x251ec748a49d82a0(["rf_fit"]):::outdated
    x6f6ea77a33e65215(["rf_hyperparameters"]):::outdated --> x251ec748a49d82a0(["rf_fit"]):::outdated
    x31fafe63f123d72c(["rf_workflow"]):::outdated --> x251ec748a49d82a0(["rf_fit"]):::outdated
    x86547e801250e368>"get_daymet_monthly"]:::uptodate --> x001de431ee97eb4a(["daymet_monthly"]):::outdated
    x2032b88ecc3ceb3d(["site_data"]):::outdated --> x001de431ee97eb4a(["daymet_monthly"]):::outdated
    x221c4544dec83bd3(["pred_map_diff"]):::outdated --> xd64eb7c952356186(["pred_map_diff_png"]):::outdated
    x5cc0a89ed2100046>"calc_bioclim"]:::uptodate --> xab1a71ecca0d9614(["grid_bioclim"]):::uptodate
    x4f1371d8a31ead17(["grid_daymet"]):::uptodate --> xab1a71ecca0d9614(["grid_bioclim"]):::uptodate
    xaef2406a8582bb04>"calc_prop_agb"]:::uptodate --> x1b1230a63dce64ae(["prop_quantiles"]):::outdated
    x84746b2e0f9f6b50(["setaria_data"]):::outdated --> x1b1230a63dce64ae(["prop_quantiles"]):::outdated
    x4bb16a5c13f5da41(["lm_model"]):::uptodate --> x7d700859457f5791(["lm_workflow"]):::outdated
    x2c6a769cc6041606(["rf_recipe"]):::outdated --> x7d700859457f5791(["lm_workflow"]):::outdated
    xaa3dacfc0774d27e(["data_train"]):::outdated --> x2c6a769cc6041606(["rf_recipe"]):::outdated
    xb8f889fdd5ebdfca>"define_recipe"]:::uptodate --> x2c6a769cc6041606(["rf_recipe"]):::outdated
    x13288cb0758ce97d(["data_test"]):::outdated --> x7ee10909b9e9ca92(["rf_pred_plot"]):::outdated
    x251ec748a49d82a0(["rf_fit"]):::outdated --> x7ee10909b9e9ca92(["rf_pred_plot"]):::outdated
    x6e52cb0f1668cc22(["readme"]):::outdated --> x6e52cb0f1668cc22(["readme"]):::outdated
    x81273780ea74b537>"get_data_paths"]:::uptodate --> x81273780ea74b537>"get_data_paths"]:::uptodate
    xb0435bc32be38d36>"combine_wrangle"]:::uptodate --> xb0435bc32be38d36>"combine_wrangle"]:::uptodate
  end
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 84 stroke-width:0px;
  linkStyle 85 stroke-width:0px;
  linkStyle 86 stroke-width:0px;
```
