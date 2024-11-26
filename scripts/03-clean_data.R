#### Preamble ####
# Purpose: Cleans the raw data
# Author: Ziqi Zhu
# Date: 25 November 2024
# Contact: ziqi.zhu@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse`, `dplyr`, `lubridate` packages must be installed

#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(lubridate)

#### Clean data ####
raw_data <- read_csv(here::here("data/01-raw_data/raw_data.csv"))

cleaned_data <-
  raw_data |>
  janitor::clean_names() %>% 
  mutate(release_date = mdy(release_date)) %>%
  select(-publisher, -developer) %>%
  tidyr::drop_na()|>
  mutate(genre = ifelse(genre %in% names(which(table(genre) < 5)), "Other", genre)) |> # Convert genre to Other if samples too less
  filter(users >= quantile(users, probs = 0.25))  # Filter out games with fewer user ratings than the 25th percentile

# Create a new column to mark for nominees and winner of GOTY
# GOTY Winners
goty_winners <- c(
  "Dragon Age: Inquisition",       # 2014
  "The Witcher 3: Wild Hunt",      # 2015
  "Overwatch",                     # 2016
  "The Legend of Zelda: Breath of the Wild",  # 2017
  "God of War",                    # 2018
  "Sekiro: Shadows Die Twice",     # 2019
  "The Last of Us Part II",        # 2020
  "It Takes Two",                  # 2021
  "Elden Ring",                    # 2022
  "Baldur's Gate 3"                # 2023
)

# GOTY Nominees
goty_nominees <- c(
  "Bayonetta 2",                   # 2014
  "Dark Souls II",
  "Dragon Age: Inquisition",
  "Hearthstone: Heroes of Warcraft",
  "Middle-earth: Shadow of Mordor",
  "Bloodborne",                    # 2015
  "Fallout 4",
  "Metal Gear Solid V: The Phantom Pain",
  "Super Mario Maker",
  "The Witcher 3: Wild Hunt",
  "DOOM",                          # 2016
  "Inside",
  "Overwatch",
  "Titanfall 2",
  "Uncharted 4: A Thief's End",
  "Horizon Zero Dawn",             # 2017
  "Persona 5",
  "PlayerUnknown's Battlegrounds",
  "Super Mario Odyssey",
  "The Legend of Zelda: Breath of the Wild",
  "Assassin's Creed Odyssey",      # 2018
  "Celeste",
  "God of War",
  "Marvel's Spider-Man",
  "Monster Hunter: World",
  "Red Dead Redemption 2",
  "Control",                       # 2019
  "Death Stranding",
  "Resident Evil 2",
  "Sekiro: Shadows Die Twice",
  "Super Smash Bros. Ultimate",
  "The Outer Worlds",
  "Animal Crossing: New Horizons", # 2020
  "Doom Eternal",
  "Final Fantasy VII Remake",
  "Ghost of Tsushima",
  "Hades",
  "The Last of Us Part II",
  "Deathloop",                     # 2021
  "It Takes Two",
  "Metroid Dread",
  "Psychonauts 2",
  "Ratchet & Clank: Rift Apart",
  "Resident Evil Village",
  "A Plague Tale: Requiem",        # 2022
  "Elden Ring",
  "God of War: Ragnarok",
  "Horizon Forbidden West",
  "Stray",
  "Xenoblade Chronicles 3",
  "Alan Wake II",                  # 2023
  "Baldur's Gate 3",
  "Marvel's Spider-Man 2",
  "Resident Evil 4",
  "Super Mario Bros. Wonder",
  "The Legend of Zelda: Tears of the Kingdom"
)

# Add goty_status column set winners from past years to 1
cleaned_data_win <- cleaned_data %>%
  mutate(goty_status = case_when(
    tolower(name) %in% tolower(goty_winners) ~ 1,     # Assign Winner as 1 
    TRUE ~ 0                                          # Others as 0
  ))


#### Save data ####
write_csv(cleaned_data_win, here::here("data/02-analysis_data/analysis_data.csv"))
