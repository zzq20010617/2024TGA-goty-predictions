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

# Load analyse data
analysis_data <- read_csv(here::here("data/02-analysis_data/analysis_data.csv"))

# Load model
bayesian_model <-
  readRDS(file = here::here("models/bayesian_model.rds"))

# Filter for entries in 2024
data_2024 <- analysis_data %>%
  filter(year(release_date) == 2024)

set.seed(617)
predicted_probs <- posterior_predict(bayesian_model, newdata = data_2024, type = "response")

data_2024$mean_prob <- apply(predicted_probs, 2, mean)

top_10_percent_threshold <- quantile(data_2024$mean_prob, 0.9)

data_2024 <- data_2024 %>%
  mutate(goty_status = ifelse(mean_prob >= top_10_percent_threshold, 1, 0))

# Save prediction as csv 
write_csv(data_2024, here::here("data/03-prediction/prediction.csv"))