library(rstan)
library(shinystan)
library(tidyverse)

library(readr)

library(readr)

directory = '/home/ubuntu/efs/stan/'

PRSA_data_2010_1_1_2014_12_31 <- read_csv(paste0(directory,"PRSA_data_2010.1.1-2014.12.31.csv"))

pollution <- PRSA_data_2010_1_1_2014_12_31 %>% select(year,pm25=pm2.5,DEWP,TEMP,PRES) %>%
  filter(complete.cases(.)) 

data_list <- list(N = nrow(pollution), 
                    pm25 = pollution$pm25,
                  dewpoint=pollution$DEWP,
                  temp=pollution$TEMP,
                  pressure=pollution$PRES)

model <- 'data {
  int<lower=0> N;
  vector[N] pm25;
  vector[N] dewpoint;
  vector[N] temp;
  vector[N] pressure;
}
parameters {
  real b_dewpoint;
  real b_temp;
  real b_pressure;
  real alpha;
  real<lower=0> sigma_dewpoint;
  real<lower=0> sigma_temp;
  real<lower=0> sigma_pressure;
  real<lower=0> sigma_intercept;
  real<lower=0> sigma;


}
model {

  b_dewpoint ~ normal(0,sigma_dewpoint);    
  b_dewpoint ~ normal(0,sigma_dewpoint);    
  b_dewpoint ~ normal(0,sigma_dewpoint);    
  alpha ~ normal(0., sigma_intercept);

  for (n in 1:N)
    pm25[n] ~ normal(alpha + b_dewpoint * dewpoint[n] + b_temp * temp[n] + b_pressure * pressure[n] , sigma);
}
'

fit <- stan(model_code = model, data = data_list, 
            iter = 10000, chains = 2)



print(fit)

launch_shinystan(fit)

