#### Preamble ####
# Purpose: Tests the structure and validity of the simulated video game dataset.
# Author: Ziqi Zhu
# Date: 29 November 2024
# Contact: ziqi.zhu@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
  # - The `tidyverse` package must be installed and loaded
  # - 00-simulate_data.R must have been run


#### Workspace setup ####
library(tidyverse)

analysis_data <- read_csv("data/00-simulated_data/simulated_data.csv")

# Test if the data was successfully loaded
if (exists("analysis_data")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}


#### Test data ####

# Check if the dataset has 100 rows
if (nrow(analysis_data) == 100) {
  message("Test Passed: The dataset has 100 rows.")
} else {
  stop("Test Failed: The dataset does not have 100 rows.")
}

# Check if the dataset has 9 columns
if (ncol(analysis_data) == 9) {
  message("Test Passed: The dataset has 9 columns.")
} else {
  stop("Test Failed: The dataset does not have 9 columns.")
}

# Check if all values in the 'game_id' column are unique
if (n_distinct(analysis_data$game_id) == nrow(analysis_data)) {
  message("Test Passed: All values in 'game_id' are unique.")
} else {
  stop("Test Failed: The 'game_id' column contains duplicate values.")
}

# Check if there are any missing values in the dataset
if (all(!is.na(analysis_data))) {
  message("Test Passed: The dataset contains no missing values.")
} else {
  stop("Test Failed: The dataset contains missing values.")
}

# Check if there are no empty strings in 'genre' columns
if (all(analysis_data$genre != "")) {
  message("Test Passed: There are no empty strings in 'genre'.")
} else {
  stop("Test Failed: There are empty strings in genre columns.")
}

# Check that all release dates fall between 2014 and 2023:
if (all(analysis_data$release_date >= as.Date("2014-01-01") &
        analysis_data$release_date <= as.Date("2023-12-31"))) {
  message("Test Passed: All release dates are within the valid range.")
} else {
  stop("Test Failed: Release dates are out of bounds.")
}

# Ensure scores fall within their expected ranges
if (all(analysis_data$critic_score >= 0 & analysis_data$critic_score <= 100) &&
    all(analysis_data$user_score >= 0 & analysis_data$user_score <= 10)) {
  message("Test Passed: Scores fall within valid ranges.")
} else {
  stop("Test Failed: Scores are out of bounds.")
}

# Verify the proportion of GOTY winners is consistent with your expectations (e.g., 10 winners for 10 years):
if (sum(analysis_data$goty_status == 1) == 10) {
  message("Test Passed: Correct number of GOTY winners.")
} else {
  stop("Test Failed: Incorrect number of GOTY winners.")
}