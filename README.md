
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
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
  end
  subgraph Graph
    direction LR
    x4b7f0494130845c9(["grid_data"]):::uptodate --> x1e2f629700cdf2b0(["grid_pred"]):::uptodate
    x80f8daf00aa10777(["newdata"]):::uptodate --> x1e2f629700cdf2b0(["grid_pred"]):::uptodate
    x251ec748a49d82a0(["rf_fit"]):::uptodate --> x1e2f629700cdf2b0(["grid_pred"]):::uptodate
    x691fe2667432a68c>"make_phenotype_data"]:::uptodate --> x84746b2e0f9f6b50(["setaria_data"]):::uptodate
    xba8bb58288d54f0e(["setaria_raw"]):::uptodate --> x84746b2e0f9f6b50(["setaria_data"]):::uptodate
    x9d9a71525b73affe>"make_grid_data"]:::uptodate --> x4b7f0494130845c9(["grid_data"]):::uptodate
    xae0bb90779bc5978(["seus"]):::uptodate --> x4b7f0494130845c9(["grid_data"]):::uptodate
    x5cc0a89ed2100046>"calc_bioclim"]:::uptodate --> xc26e685f03c57771(["bioclim"]):::uptodate
    x001de431ee97eb4a(["daymet_monthly"]):::uptodate --> xc26e685f03c57771(["bioclim"]):::uptodate
    xaa3dacfc0774d27e(["data_train"]):::uptodate --> x2c6a769cc6041606(["rf_recipe"]):::uptodate
    xb8f889fdd5ebdfca>"define_recipe"]:::uptodate --> x2c6a769cc6041606(["rf_recipe"]):::uptodate
    xaa3dacfc0774d27e(["data_train"]):::uptodate --> x88226e7f0f4662b1(["data_folds"]):::uptodate
    xe79aca23d28071ab(["data_split"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x4b7f0494130845c9(["grid_data"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x0dd52ca5681d2dec(["lm_cv"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x82c80750d3c3aa91(["lm_pred_plot"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x40f6344f44be00c4(["pred_map"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x221c4544dec83bd3(["pred_map_diff"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x03f8f197baa464a7(["rf_cv"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x7ee10909b9e9ca92(["rf_pred_plot"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    x2c6a769cc6041606(["rf_recipe"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    xae0bb90779bc5978(["seus"]):::uptodate --> xe0fba61fbc506510(["report"]):::uptodate
    xaa3dacfc0774d27e(["data_train"]):::uptodate --> xfe69c4366ba0129f(["lm_fit"]):::uptodate
    x541d164e38df8517(["lm_hyperparameters"]):::uptodate --> xfe69c4366ba0129f(["lm_fit"]):::uptodate
    x7d700859457f5791(["lm_workflow"]):::uptodate --> xfe69c4366ba0129f(["lm_fit"]):::uptodate
    xab1a71ecca0d9614(["grid_bioclim"]):::uptodate --> x80f8daf00aa10777(["newdata"]):::uptodate
    xe79aca23d28071ab(["data_split"]):::uptodate --> xaa3dacfc0774d27e(["data_train"]):::uptodate
    xaa3dacfc0774d27e(["data_train"]):::uptodate --> x251ec748a49d82a0(["rf_fit"]):::uptodate
    x6f6ea77a33e65215(["rf_hyperparameters"]):::uptodate --> x251ec748a49d82a0(["rf_fit"]):::uptodate
    x31fafe63f123d72c(["rf_workflow"]):::uptodate --> x251ec748a49d82a0(["rf_fit"]):::uptodate
    x13288cb0758ce97d(["data_test"]):::uptodate --> x7ee10909b9e9ca92(["rf_pred_plot"]):::uptodate
    x251ec748a49d82a0(["rf_fit"]):::uptodate --> x7ee10909b9e9ca92(["rf_pred_plot"]):::uptodate
    x1e2f629700cdf2b0(["grid_pred"]):::uptodate --> x40f6344f44be00c4(["pred_map"]):::uptodate
    x446632179a854016>"make_pred_map"]:::uptodate --> x40f6344f44be00c4(["pred_map"]):::uptodate
    xae0bb90779bc5978(["seus"]):::uptodate --> x40f6344f44be00c4(["pred_map"]):::uptodate
    x13288cb0758ce97d(["data_test"]):::uptodate --> x82c80750d3c3aa91(["lm_pred_plot"]):::uptodate
    xfe69c4366ba0129f(["lm_fit"]):::uptodate --> x82c80750d3c3aa91(["lm_pred_plot"]):::uptodate
    x88226e7f0f4662b1(["data_folds"]):::uptodate --> x03f8f197baa464a7(["rf_cv"]):::uptodate
    x6f6ea77a33e65215(["rf_hyperparameters"]):::uptodate --> x03f8f197baa464a7(["rf_cv"]):::uptodate
    x31fafe63f123d72c(["rf_workflow"]):::uptodate --> x03f8f197baa464a7(["rf_cv"]):::uptodate
    x25a132700f092ff0(["prop_agb_plot"]):::uptodate --> x562ba761c4660183(["prop_agb_plot_png"]):::uptodate
    x2dc7e80e5e9b239f(["rf_grid_results"]):::uptodate --> x6f6ea77a33e65215(["rf_hyperparameters"]):::uptodate
    x40f6344f44be00c4(["pred_map"]):::uptodate --> xd1d5de95fb768940(["pred_map_png"]):::uptodate
    x86547e801250e368>"get_daymet_monthly"]:::uptodate --> x001de431ee97eb4a(["daymet_monthly"]):::uptodate
    x2032b88ecc3ceb3d(["site_data"]):::uptodate --> x001de431ee97eb4a(["daymet_monthly"]):::uptodate
    x88226e7f0f4662b1(["data_folds"]):::uptodate --> x0dd52ca5681d2dec(["lm_cv"]):::uptodate
    x541d164e38df8517(["lm_hyperparameters"]):::uptodate --> x0dd52ca5681d2dec(["lm_cv"]):::uptodate
    x7d700859457f5791(["lm_workflow"]):::uptodate --> x0dd52ca5681d2dec(["lm_cv"]):::uptodate
    x221c4544dec83bd3(["pred_map_diff"]):::uptodate --> xd64eb7c952356186(["pred_map_diff_png"]):::uptodate
    xa3f7d12cb273bbe2(["model_data"]):::uptodate --> xe79aca23d28071ab(["data_split"]):::uptodate
    xe79aca23d28071ab(["data_split"]):::uptodate --> x13288cb0758ce97d(["data_test"]):::uptodate
    xbea1d239f1152dfe>"get_seus_shape"]:::uptodate --> xae0bb90779bc5978(["seus"]):::uptodate
    x4bb16a5c13f5da41(["lm_model"]):::uptodate --> x7d700859457f5791(["lm_workflow"]):::uptodate
    x2c6a769cc6041606(["rf_recipe"]):::uptodate --> x7d700859457f5791(["lm_workflow"]):::uptodate
    x5cc0a89ed2100046>"calc_bioclim"]:::uptodate --> xab1a71ecca0d9614(["grid_bioclim"]):::uptodate
    x4f1371d8a31ead17(["grid_daymet"]):::uptodate --> xab1a71ecca0d9614(["grid_bioclim"]):::uptodate
    xc26e685f03c57771(["bioclim"]):::uptodate --> xa3f7d12cb273bbe2(["model_data"]):::uptodate
    xb1bfd93c0984802a>"create_model_data"]:::uptodate --> xa3f7d12cb273bbe2(["model_data"]):::uptodate
    x84746b2e0f9f6b50(["setaria_data"]):::uptodate --> xa3f7d12cb273bbe2(["model_data"]):::uptodate
    xaef2406a8582bb04>"calc_prop_agb"]:::uptodate --> x1b1230a63dce64ae(["prop_quantiles"]):::uptodate
    x84746b2e0f9f6b50(["setaria_data"]):::uptodate --> x1b1230a63dce64ae(["prop_quantiles"]):::uptodate
    x2869030bf0e5bc40(["setaria_file"]):::uptodate --> xba8bb58288d54f0e(["setaria_raw"]):::uptodate
    xaa3dacfc0774d27e(["data_train"]):::uptodate --> x2dc7e80e5e9b239f(["rf_grid_results"]):::uptodate
    xb66df7ac83f87f08(["rf_grid"]):::uptodate --> x2dc7e80e5e9b239f(["rf_grid_results"]):::uptodate
    x31fafe63f123d72c(["rf_workflow"]):::uptodate --> x2dc7e80e5e9b239f(["rf_grid_results"]):::uptodate
    xaa3dacfc0774d27e(["data_train"]):::uptodate --> x69c7dddc4e8cfd76(["lm_grid_results"]):::uptodate
    x7c34938a17ec8f51(["lm_grid"]):::uptodate --> x69c7dddc4e8cfd76(["lm_grid_results"]):::uptodate
    x7d700859457f5791(["lm_workflow"]):::uptodate --> x69c7dddc4e8cfd76(["lm_grid_results"]):::uptodate
    x69c7dddc4e8cfd76(["lm_grid_results"]):::uptodate --> x541d164e38df8517(["lm_hyperparameters"]):::uptodate
    xc226421a0b14850a>"plot_prop_agb"]:::uptodate --> x25a132700f092ff0(["prop_agb_plot"]):::uptodate
    x1b1230a63dce64ae(["prop_quantiles"]):::uptodate --> x25a132700f092ff0(["prop_agb_plot"]):::uptodate
    x1e2f629700cdf2b0(["grid_pred"]):::uptodate --> x221c4544dec83bd3(["pred_map_diff"]):::uptodate
    x29dca615c423dffb>"make_pred_map_diff"]:::uptodate --> x221c4544dec83bd3(["pred_map_diff"]):::uptodate
    xae0bb90779bc5978(["seus"]):::uptodate --> x221c4544dec83bd3(["pred_map_diff"]):::uptodate
    x8165fe9985c10a4a(["rf_model"]):::uptodate --> x31fafe63f123d72c(["rf_workflow"]):::uptodate
    x2c6a769cc6041606(["rf_recipe"]):::uptodate --> x31fafe63f123d72c(["rf_workflow"]):::uptodate
    x27f4571812c133e6>"make_site_data"]:::uptodate --> x2032b88ecc3ceb3d(["site_data"]):::uptodate
    x84746b2e0f9f6b50(["setaria_data"]):::uptodate --> x2032b88ecc3ceb3d(["site_data"]):::uptodate
    x86547e801250e368>"get_daymet_monthly"]:::uptodate --> x4f1371d8a31ead17(["grid_daymet"]):::uptodate
    x4b7f0494130845c9(["grid_data"]):::uptodate --> x4f1371d8a31ead17(["grid_daymet"]):::uptodate
    x81273780ea74b537>"get_data_paths"]:::uptodate --> x81273780ea74b537>"get_data_paths"]:::uptodate
    xb0435bc32be38d36>"combine_wrangle"]:::uptodate --> xb0435bc32be38d36>"combine_wrangle"]:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 82 stroke-width:0px;
  linkStyle 83 stroke-width:0px;
```
