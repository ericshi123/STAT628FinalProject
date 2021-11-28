import os
import json
import sys
import pandas as pd
import matplotlib.pyplot as plt
import re

#covid = [json.loads(line) for line in open('/Users/lukevandy/Documents/python-workspace/Stat628_Module3/yelp_dataset/covid.json', 'r')]
business = [json.loads(line) for line in open('/Users/lukevandy/Documents/python-workspace/Stat628_Module3/yelp_dataset/business.json', 'r')]
review = [json.loads(line) for line in open('/Users/lukevandy/Documents/python-workspace/Stat628_Module3/yelp_dataset/review.json', 'r')]
#tip = [json.loads(line) for line in open('/Users/lukevandy/Documents/python-workspace/Stat628_Module3/yelp_dataset/tip.json', 'r')]
#user = [json.loads(line) for line in open('/Users/lukevandy/Documents/python-workspace/Stat628_Module3/yelp_dataset/user.json', 'r')]

#covid_df = pd.DataFrame(covid)
business_df = pd.DataFrame(business)
review_df = pd.DataFrame(review)
#tip_df = pd.DataFrame(tip)
#user_df = pd.DataFrame(user)

business_df.drop(['address', 'city', 'state', 'postal_code', 'latitude', 'longitude', 'stars', 'review_count', 'is_open', 'attributes'], axis=1)
review_df.drop(['useful', 'funny', 'cool', 'date'], axis=1)

popeyes = business_df[business_df['name'] == ('Popeyes')]
popeyes = popeyes.append(business_df[business_df['name'] == ('Popeyes Louisiana Kitchen')])
kfc = business_df[business_df['name'] == ('Kentucky Fried Chicken')]
kfc = kfc.append(business_df[business_df['name'] == ('KFC')])
wendys = business_df[business_df['name'] == ('Wendy\'s')]
wendys = wendys.append(business_df[business_df['name'] == ('Wendys')])
chick_fil_a = business_df[business_df['name'] == ('Chick-fil-A')]
chick_fil_a = chick_fil_a.append(business_df[business_df['name'] == ('Chick-Fil-A')])
carls_jr = business_df[business_df['name'] == ('Carl\'s Jr.')]
carls_jr = carls_jr.append(business_df[business_df['name'] == ('Carl\'s Jr')])
carls_jr = carls_jr.append(business_df[business_df['name'] == ('Carls Jr')])
mcdonalds = business_df[business_df['name'] == ('McDonald\'s')]
burger_king = business_df[business_df['name'] == ('Burger King')]

popeyes['name'] = 'Popeyes'
kfc['name'] = 'KFC'
wendys['name'] = 'Wendy\'s'
chick_fil_a['name'] = 'Chick-fil-A'
carls_jr['name'] = 'Carl\'s Jr.'

all_restaurants = popeyes.append([kfc, wendys, chick_fil_a, carls_jr, mcdonalds, burger_king])

all_our_reviews = pd.merge(left=all_restaurants, right=review_df, left_on='business_id', right_on='business_id')

all_our_reviews.to_csv('/Users/lukevandy/Documents/python-workspace/Stat628_Module3/all_chains_reviews.csv')

all_our_cs_reviews = all_our_reviews[all_our_reviews['text'].str.contains('chicken sandwich', flags=re.IGNORECASE, regex=True)]

all_our_cs_reviews.to_csv('/Users/lukevandy/Documents/python-workspace/Stat628_Module3/all_chains_cs_reviews.csv')
