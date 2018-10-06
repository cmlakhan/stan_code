library(rstan)
library(shinystan)
library(tidyverse)

library(readr)

library(readr)

#directory = '/home/ubuntu/efs/stan_code/'

directory = '/Users/chirag/Documents/stan_code/'

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


PRSA_data_2010_1_1_2014_12_31 <- read_csv(paste0(directory,"PRSA_data_2010.1.1-2014.12.31.csv"))

pollution <- PRSA_data_2010_1_1_2014_12_31 %>% select(year,month,hour,pm25=pm2.5,DEWP,TEMP,PRES,Iws,Ir,Is) %>%
  filter(complete.cases(.)) %>% mutate(year=year-2009) %>%
  mutate(hour=hour+1)

data_list <- list(N = nrow(pollution), 
                  N_year = nrow(pollution %>% select(year) %>% unique()),
                  N_month = nrow(pollution %>% select(month) %>% unique()),
                  N_hour = nrow(pollution %>% select(hour) %>% unique()),
                  pm25 = pollution$pm25,
                  dewpoint=pollution$DEWP,
                  temp=pollution$TEMP,
                  pressure=pollution$PRES,
                  Iws=pollution$Iws,
                  Ir=pollution$Ir,
                  Is=pollution$Is,
                  hour=pollution$hour,
                  year=pollution$year,
                  month=pollution$month
                  )

model <- 'data {
  int<lower=0> N;
  int<lower=0> N_year;
  int<lower=0> N_month;
  int<lower=0> N_hour;
  vector[N] pm25;
  vector[N] dewpoint;
  vector[N] temp;
  vector[N] pressure;
  vector[N] Iws;
  vector[N] Ir;
  vector[N] Is;
  int<lower=1,upper=24> hour[N];
  int<lower=1,upper=5> year[N];
  int<lower=1,upper=12> month[N];
}
parameters {
  real b_dewpoint;
  real b_temp;
  real b_pressure;
  real b_Iws;
  real b_Ir;
  real b_Is;
  real alpha;
  vector[N_month] alpha_month;
  vector[N_hour] alpha_hour;
  vector[N_year] alpha_year;
real<lower=0> sigma_dewpoint;
  real<lower=0> sigma_temp;
  real<lower=0> sigma_pressure;
  real<lower=0> sigma_Iws;
  real<lower=0> sigma_Ir;
  real<lower=0> sigma_Is;
  real<lower=0> sigma_intercept;
  real<lower=0> sigma;


}
model {

  b_dewpoint ~ normal(0,sigma_dewpoint);    
  b_dewpoint ~ normal(0,sigma_dewpoint);    
  b_dewpoint ~ normal(0,sigma_dewpoint);    
  b_Iws ~ normal(0,sigma_Iws);    
  b_Ir ~ normal(0,sigma_Ir);    
  b_Is ~ normal(0,sigma_Is);    
  alpha ~ normal(0, sigma_intercept);

  for (i in 1:N)
  pm25[i] ~ normal(alpha + alpha_month[month[i]] +alpha_year[year[i]] + alpha_hour[hour[i]] + b_dewpoint * dewpoint[i] + b_temp * temp[i] + b_pressure * pressure[i] + b_Iws * Iws[i] + b_Ir * Ir[i] + b_Is * Is[i] , sigma);
}
'

#fit <- stan(model_code = model, data = data_list, 
#            iter = 10000, chains = 2)

stan_model_file <- stan_model(model_code = model)


fit_vb <- vb(stan_model_file, data = data_list,algorithm='fullrank',elbo_samples=600, output_samples=5000)


print(fit_vb)

launch_shinystan(fit_vb)

