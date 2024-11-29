#### Preamble ####
# Purpose: Tests for analysis dataset
# Author: Ziqi Zhu
# Date: 29 November 2024
# Contact: ziqi.zhu@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `testthat` package must be installed and loaded


#### Workspace setup ####
library(tidyverse)
library(testthat)


#### Test data ####
analysis_data <- read_csv("data/02-analysis_data/analysis_data.csv")

# Test if the data was successfully loaded
if (exists("analysis_data")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}

#### Test data ####

# Create a test suite for the analysis dataset
test_that("Dataset Validation Tests", {
  
  # 1. Check if there are any missing values in the dataset
  expect_true(all(!is.na(analysis_data)), label = "The dataset should not contain missing values")
  
  # 2. Check if there are no empty strings in 'genre' column
  expect_true(all(analysis_data$genre != ""), label = "The 'genre' column should not contain empty strings")
  
  # 3. Check that all release dates fall between 2014 and 2024
  expect_true(
    all(analysis_data$release_date >= as.Date("2014-01-01") &
          analysis_data$release_date <= as.Date("2024-12-11")),
    label = "All release dates should be between 2014 and 2024"
  )
  
  # 4. Ensure scores fall within their expected ranges
  expect_true(
    all(analysis_data$score >= 0 & analysis_data$score <= 100) &&
      all(analysis_data$user_score >= 0 & analysis_data$user_score <= 10),
    label = "Scores should fall within their valid ranges"
  )
  
  # 5. Ensure positive rate fall within their expected ranges
  expect_true(
    all(analysis_data$critic_positivity >= 0 & analysis_data$critic_positivity <= 100) &&
      all(analysis_data$user_positivity >= 0 & analysis_data$user_positivity <= 100),
    label = "Positive rate of reviews should fall within their valid ranges"
  )
  
  # 6. Verify the proportion of GOTY winners is consistent (10 winners)
  expect_equal(sum(analysis_data$goty_status == 1), 10, 
               label = "There should be exactly 10 GOTY winners")
  
  # 7. Verify the game name is unique
  expect_equal(n_distinct(analysis_data$name), nrow(analysis_data), 
               label = "The dataset should have unique game names")
})