import requests
from bs4 import BeautifulSoup
import tweepy
import random

# Twitter API credentials
consumer_key = 'your_consumer_key'
consumer_secret = 'your_consumer_secret'
access_token = 'your_access_token'
access_secret = 'your_access_secret'

# Set up Tweepy API client
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)

# Define list of topics to generate questions for
topics = ['politics', 'gaming', 'crypto', 'tokens', 'web3']

for topic in topics:
    # Define URLs for news articles
    if topic == 'politics':
        urls = ['https://www.reuters.com/news/politics', 'https://www.bbc.com/news/politics']
    elif topic == 'gaming':
        urls = ['https://www.polygon.com/gaming', 'https://www.gamesradar.com/news/']
    elif topic == 'crypto':
        urls = ['https://www.coindesk.com/', 'https://cointelegraph.com/']
    elif topic == 'tokens':
        urls = ['https://www.coindesk.com/', 'https://www.publish0x.com/']
    elif topic == 'web3':
        urls = ['https://www.coindesk.com/', 'https://ethereum.org/en/']

    # Get HTML content from URLs
    headlines = []
    for url in urls:
        response = requests.get(url)
        soup = BeautifulSoup(response.content, 'html.parser')
        headlines += [headline.get_text().strip() for headline in soup.find_all('h2')]

    # Get top 10 trends for topic on Twitter
    trends = api.trends_place(1)
    trends = [trend['name'] for trend in trends[0]['trends'] if trend['name'].startswith('#')][:10]

    # Choose a random headline and trend and generate a question
    headline = random.choice(headlines)
    trend = random.choice(trends)
    question = f"What do you think will happen with {headline} and {trend} industry ?"

    print(question)










