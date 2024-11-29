#### Preamble ####
# Purpose: Models... [...UPDATE THIS...]
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 11 February 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: [...UPDATE THIS...]
# Any other information needed? [...UPDATE THIS...]


#### Workspace setup ####
library(tidyverse)
library(ggplot2)
library(rstanarm)
library(broom.mixed)  # For extracting posterior summaries

#### Read data ####
bayesian_model <-
  readRDS(file = here::here("models/bayesian_model.rds"))

# Calculate class proportions
class_weights <- data_past_years %>%
  group_by(goty_status) %>%
  summarise(weight = n()) %>%
  mutate(weight = max(weight) / weight)  # Higher weight for minority class

# Add weights to the dataset
data_past_years <- data_past_years %>%
  left_join(class_weights, by = "goty_status")


# Select the top 10 genres by count
top_genres <- winner_2024 %>%
  count(genre, sort = TRUE) %>%  # Count entries per genre and sort in descending order
  top_n(10, n)                   # Select the top 10 genres by count

# Plot the top 10 genres
ggplot(top_genres, aes(x = reorder(genre, n), y = n)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black") +
  coord_flip() +  # Flip coordinates for better readability
  labs(
    title = "Top 10 Genres by Number of Nominated Games",
    x = "Genre",
    y = "Count"
  ) +
  theme_minimal()

# Load analysis data
raw_data <- read_csv(here::here("data/01-raw_data/raw_data.csv"))

# Extract posterior summaries
posterior_summary <- tidy(bayesian_model, effects = "fixed", conf.int = TRUE)

# View the posterior summaries
print(posterior_summary)

# Plot posterior distributions
library(bayesplot)
mcmc_areas(as.matrix(bayesian_model), 
           pars = c("score", "user_score", "critic_positivity", "critics", "user_positivity", "log(users)"),
           prob = 0.95) + 
  labs(title = "Posterior Distributions of Predictors")

pp_check(bayesian_model)

gotywin_genre_count <- analysis_data %>%
  filter(name %in% goty_winners) %>%
  count(genre, sort = TRUE)