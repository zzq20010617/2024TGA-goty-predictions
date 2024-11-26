#### Preamble ####
# Purpose: Scrape data of games released from 2014 to 2024 from Metacritic
# Author: Ziqi Zhu
# Date: 24 November 2024
# Contact: ziqi.zhu@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
  # - `pandas` must be installed (pip install pandas)
  # - `requests` must be installed (pip install requests)
  # - `beautifulsoup4` must be installed (pip install beautifulsoup4)
# Other info: The original `scraper.ipynb` script was obtained from 
  #[https://github.com/BrunoBVR/projectGames/blob/main/scraper.ipynb]. The 
  # repository's last update was four years ago. I modified the script to scrape 
  # data from the latest version of the Metacritic website, adapting the game
  # details to match the specific information needed for this study. The use of 
  # the script has been explicitly permitted by the original author.
  
import requests
from bs4 import BeautifulSoup
import re

import pandas as pd

"""
We will use [Metacritic](https://www.metacritic.com/browse/game/?releaseYearMin=2014&releaseYearMax=2024&page=1) data to create a dataframe with data on games across all platforms from 2014-2024.

We want to get a dataframe with all games with columns:
* name: The name of the game
* released_date: date it was released
* score: average score given by critics (metascore)
* publisher: game publisher
* genre: genre of the game (only one)
* user_score: average score given by users in the website
* user_positivity: ratio of positive reviews from users
* critic_positivity: ratio of positive reviews from critics
* developer: game developer
* critics: number of critics reviewing the game
* users: Number of metacritic users that reviewed the game

All data was collected on November 24th, 2024.

Steps used in scraper:

* Create a dictionary `pages` that will contain the DataFrame objects from all pages. Each entry is a pandas DataFrame with data from the games in each site page. There are, currently, 249 pages of rated games.
* For each page, create a dictionary `data_page` of empty lists to be filled with the data from each game. As each page displays 24 games, each of this lists should contain 24 elements (except for the last page).
* Use `requests` to get into the url of each page and `BEautifulSoup` to parse the html file.
* Loop through all games in each page and scrap the relevant data. Note that 'developer', 'genre', 'players', 'critics' and 'users' are found on different URLs, so we need to fetch these for each game. This URL for each game is inside a `a` tag with a `title` class. 
* There are a couple of if's in the scraper to ensure None objects get dealt with (some games don't have a number of players information, for example; some games have no user reviews, given it is not yet released, and a few others).
* After all data is collected (around 1.5 hour for all entries in raw_data), all dataframes in the `pages` dictionary are concatenated to create a single one with all game data.
* The dataframe is export to a csv file.
"""
pages = {}

for page in range(1, 249):
    
    data_page = {
        'name':[],
        'release_date':[],
        'score':[],
        'publisher':[],
        'genre':[],
        'user_score':[],
        'user_positivity':[],
        'critic_positivity':[],
        'developer':[],
        'critics':[],
        'users':[]
    }    
    
    # Site inside metacritic listing "Best Games" filtered from 2014-2024
    url = 'https://www.metacritic.com/browse/game/?releaseYearMin=2014&releaseYearMax=2024&page='+str(page)
    user_agent = {'User-agent': 'Mozilla/5.0'}
    response = requests.get(url, headers = user_agent)
    soup = BeautifulSoup(response.text, 'html.parser')

    
    # Printing out current page
    print(f"In page:{page}")
    
    # Loop through all games in current page
    for game in soup.find_all('div', class_ = 'c-finderProductCard c-finderProductCard-game'):

        user_flag = True

        # Extract game name
        name = game.find('div', class_='c-finderProductCard_title').get('data-title', '').strip()
        if name:
            data_page['name'].append(name)

        # Extract release date
        release_date_tag = game.find('span', class_='u-text-uppercase')
        release_date = release_date_tag.text.strip() if release_date_tag else None
        data_page['release_date'].append(release_date)

        # Extract Metascore
        metascore_tag = game.find('div', class_='c-finderProductCard_metascoreValue')
        metascore = metascore_tag.text.strip() if metascore_tag else None
        data_page['score'].append(metascore)
        
        # Into the game page
        # Getting the url of the reviews page:
        url_info = game.find('a', class_='c-finderProductCard_container')['href']

        url_info = 'https://www.metacritic.com'+url_info

        # Getting into the game page:
        response_info = requests.get(url_info, headers = user_agent)

        soup_info = BeautifulSoup(response_info.text, 'html.parser')

        # Get developer info
        developer = soup_info.find('div', class_='c-gameDetails_Developer')
        if developer is not None:
            developer = developer.find('li',class_='c-gameDetails_listItem').text

            developer = developer.replace('\n','')
            developer = developer.replace(' ','')  

            data_page['developer'].append(developer)
        else:
            data_page['developer'].append('No info')
        
        # Get user score
        user_score = soup_info.find('div', {'data-testid': 'user-score-info'})
        
        if user_score is not None:
            user_score = user_score.find('div', class_='c-siteReviewScore')
            user_score = user_score.find('span')
            if user_score:
                user_score = user_score.text.strip()
                if user_score.lower() == 'tbd':
                    user_flag = False
                    data_page['user_score'].append(None)
                else:
                    user_score = float(user_score)
                    data_page['user_score'].append(user_score)
            else:
                data_page['user_score'].append(None)
        else:
            data_page['user_score'].append(None)

        # Get positivity of user
        user_positive = soup_info.find('div', class_='c-reviewsSection_userReviews')
        if user_positive is not None and user_flag:
            user_positive = user_positive.find('div', class_='c-reviewsOverview_scoreCardGraph')
            user_positive = user_positive.find('span', class_='g-text-bold')
            if user_positive:
                positivity_text = user_positive.text.strip()
                positivity_percentage = int(re.search(r'\d+', positivity_text).group())
                data_page['user_positivity'].append(positivity_percentage)
            else:
                data_page['user_positivity'].append(None)
        else:
            data_page['user_positivity'].append(None)

        # Get positivity of critics
        critics_positive = soup_info.find('div', class_='c-reviewsSection_criticReviews')
        if critics_positive is not None:
            critics_positive = critics_positive.find('div', class_='c-reviewsOverview_scoreCardGraph')
            critics_positive = critics_positive.find('span', class_='g-text-bold')
            if critics_positive:
                positivity_text = critics_positive.text.strip()
                positivity_percentage = int(re.search(r'\d+', positivity_text).group())
                data_page['critic_positivity'].append(positivity_percentage)
            else:
                data_page['critic_positivity'].append(None)
        else:
            data_page['critic_positivity'].append(None)

        # Get publisher info
        publisher = soup_info.find('div', class_ = 'c-gameDetails_Distributor')
        
        if publisher is not None:
            publisher = publisher.find('span',class_='g-outer-spacing-left-medium-fluid').text

            publisher = publisher.replace('\n','')
            publisher = publisher.replace(' ','')  

            data_page['publisher'].append(publisher)
        else:
            data_page['publisher'].append('No info')

        # Get genre info (multiple genres are separated by commas in our entry)

        genres = soup_info.find('li', class_ = 'c-genreList_item')
        
        if genres is not None:
            genre = genres.find('span', class_='c-globalButton_label').text
            genre = genre.replace('\n','')
            genre = genre.replace(' ','')  

            data_page['genre'].append(genre)
        else:
            data_page['genre'].append('No info')

        # Get number of critics
        critics_tag = soup_info.find('div', {'data-testid': 'critic-score-info'})
        if critics_tag:
            critics_reviews_tag = critics_tag.find('span', class_='c-productScoreInfo_reviewsTotal')
            if critics_reviews_tag:
                # Extract the text and parse the number of reviews
                critics_text = critics_reviews_tag.text.strip()  # Extract text
                critics_number = int(re.search(r'\d+', critics_text).group())  # Extract numeric value, remove commas
                data_page['critics'].append(critics_number)
            else:
                data_page['critics'].append(0)
        else:
            data_page['critics'].append(0)

        # Get number of users
        users_tag = soup_info.find('div', {'data-testid': 'user-score-info'})
        if users_tag and user_flag:
            users_reviews_tag = users_tag.find('span', class_='c-productScoreInfo_reviewsTotal')
            if users_reviews_tag:
                # Extract the text and parse the number of reviews
                users_text = users_reviews_tag.text.strip()  # Extract text
                users_number = int(re.search(r'\d+(,\d+)*', users_text).group().replace(',', ''))  # Extract numeric value
                data_page['users'].append(users_number)
            else:
                data_page['users'].append(0)
        else:
            data_page['users'].append(0)
    # create a dict entry to store the dataframe for each page
    pages[str(page)] = pd.DataFrame(data_page)
    
    # export page data as csv
    pages[str(page)].to_csv('games_data-page'+str(page)+'.csv',index=False)


# Concatenating all dataframes inside 'pages' dictionary
# Create a list of all dataframes to concatenate
frames = []

for k,v in pages.items():
    frames.append(v)
    
df_ultimate = pd.concat(frames)
df_ultimate.index = range(len(df_ultimate))

# Export to csv file
df_ultimate.to_csv('games-data.csv',index=False)
