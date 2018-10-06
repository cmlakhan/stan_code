library(rstan)
library(shinystan)
library(tidyverse)

library(readr)
wdbc <- read_csv("Documents/stan_code/wdbc.data", 
                 col_names = FALSE)
View(wdbc)

names(wdbc) <- c('ID','diagnosis',
                 'radius_1','texture_1','perimeter_1','area_1','smoothness_1','compactness_1','concavity_1','')