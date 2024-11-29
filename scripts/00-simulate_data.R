#### Preamble ####
# Purpose: Simulates a dataset of video games include critic score, user score,
# and number of reviews from users and critics,positive rate, genre and a column 
# indicate if game had won GOTY
# Author: Ziqi Zhu
# Date: 29 November 2024
# Contact: ziqi.zhu@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse`, `dplyr` package must be installed

#### Workspace setup ####
library(tidyverse)
library(dplyr)
        
set.seed(617)

#### Simulate data ####

# Define the number of games in the dataset
n <- 100

# Generate release dates between 2014 and 2023
release_dates <- seq.Date(from = as.Date("2014-01-01"), to = as.Date("2023-12-31"), by = "day")

# Simulate data
simulated_data <- data.frame(
  game_id = 1:n,
  critic_score = round(rnorm(n, mean = 75, sd = 10)) %>%
    pmax(0) %>%
    pmin(100),
  user_score = round(runif(n, min = 5, max = 9), 1),
  user_reviews = sample(50:5000, n, replace = TRUE),
  critic_reviews = sample(5:100, n, replace = TRUE),
  positive_rate = round(runif(n, min = 50, max = 95), 1),
  release_date = sample(release_dates, n, replace = TRUE),
  genre = sample(x = c("RPG", "Action", "FPS", "Survival", "Adventure", "Other"), n, replace = TRUE)
  )

# Ensure 1 GOTY winner per year
goty_winners <- simulated_data %>%
  group_by(year = year(release_date)) %>%
  slice_sample(n = 1) %>%
  mutate(goty_status = 1)

# Mark remaining games as non-winners
non_winners <- anti_join(simulated_data, goty_winners, by = "game_id") %>%
  mutate(goty_status = 0)

# Combine winners and non-winners
simulate_data <- bind_rows(goty_winners, non_winners) %>%
  arrange(release_date)

simulate_data <- simulate_data %>%
  ungroup() %>% 
  select(-year)
#### Save data ####
write_csv(simulate_data, "data/00-simulated_data/simulated_data.csv")
