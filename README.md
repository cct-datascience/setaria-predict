
# setaria-predict

<!-- badges: start -->
<!-- badges: end -->

The goal of setaria-predict is to train a model using simulation output from ED2 to create an ED2 "emulator" of sorts.  Then, we can use this model to predict the growth of *Setaria* at new locations.

We will use runs from the sensitivity analysis as stand-ins for different *Setaria* genotypes and train models using site location and/or weather data as predictors, then predict aboveground biomass or NPP of *Setaria* at new sites.