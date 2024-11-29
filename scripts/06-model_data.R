#### Preamble ####
# Purpose: Fit bayesian logistic regression model with past years data
# Author: Ziqi Zhu
# Date: 26 November 2024
# Contact: ziqi.zhu@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse`, `dplyr`, `rstanarm` packages must be installed


#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(rstanarm)

#### Read data ####
analysis_data <- read_csv(here::here("data/02-analysis_data/analysis_data.csv"))

analysis_data <- analysis_data %>%
  mutate(
    genre = factor(genre),
  )

# Filter for entries in 2024
data_2024 <- analysis_data %>%
  filter(year(release_date) == 2024)

# Filter for non-2024 entries
data_past_years <- analysis_data %>%
  filter(year(release_date) != 2024)

# table(data_past_years$genre)


### Model data ####

# Set prior to defaul
priors = normal(0, 2.5, autoscale = TRUE)

bayesian_model <- stan_glmer(
  goty_status ~ score + user_score + critic_positivity + critics + user_positivity + log(users) + (1 | genre),
  data = data_past_years,
  family = binomial(link = "logit"),
  prior = priors,
  prior_intercept = priors,
  cores = 6,
  control = list(adapt_delta = 0.99),
  seed = 617
)


bayesian_model_interact <- stan_glmer(
  goty_status ~ score + user_score + critic_positivity * critics + user_positivity * log(users) + (1 | genre),
  data = data_past_years,
  family = binomial(link = "logit"),
  prior = priors,
  prior_intercept = priors,
  cores = 6,
  control = list(adapt_delta = 0.99),
  seed = 617
)

bayesian_model_weighted <- stan_glmer(
  goty_status ~ score + user_score + critic_positivity + critics + user_positivity + log(users) + (1 | genre),
  data = data_past_years,
  family = binomial(link = "logit"),
  prior = priors,
  prior_intercept = priors,
  weights = weight,
  cores = 6,
  control = list(adapt_delta = 0.99),
  seed = 617
)

#### Save model ####
saveRDS(
  bayesian_model,
  file = "models/bayesian_model.rds"
)

