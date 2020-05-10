"""
RMS Titanic dataset to Neo4j pipeline module

This module takes the RMS Titanic dataset as .csv and prepares it
for import into the Neo4j property graph database. See the accompanying 
notebooks for more information.

Example
-------

    $ python src/pipeline.py titanic.csv

"""

import os
import sys
import pandas as pd

# Download dataset url
url = 'https://query.data.world/s/xjk6hp7t7w3553bfpkfshr2bjd67a4'

def clean_data(data):
    """
    Takes a Pandas Dataframe and cleans and updates string values to 
    prepare for import into Neo4j. Also generates some new features.

    Parameters
    ----------
    data : Pandas Dataframe
        Dataframe of Titanic dataset loaded from .csv

    Columns Fixed
    -------------
        - embarked
        - home.dest
    
    Columns Created
    ---------------
        - family.size
        - surname
        - deck

    Returns
    -------
    Pandas Dataframe
        Dataframe ready for import into property graph database

    """
    # Calculate total size of family (same surname) including passenger
    data['family.size'] = data['sibsp'] + data['parch'] + 1

    # Add surname column to easily identify relatives. Neo4j can 
    # build relationships based on matching surname and family size.
    data['surname'] = data['name'].str.split(',', expand=True)[0]

    # Extract deck from cabin number
    data['deck'] = data['cabin'].str[:1]
    
    # Fill incorrect NaN values of embarked with correct values for passengers
    data.loc[data['ticket'] == '113572', 'embarked'] = 'S'
    
    # Replace embarked with location name
    embarked = {"S": "Southampton", "C": "Cherbourg", "Q": "Queenstown"}
    data['embarked'] = data['embarked'].map(embarked)
    
    # Replace NaN values with Unknown in destination column
    data['home.dest'].fillna("Unspecified Destination", inplace=True)
    
    return data

# Create dictionary of Country:[strings]
# If row.`home.dest` is in map assign Country value
abbrev_map = {
    'Alabama': 'AL',
    'Alaska': 'AK',
    'American Samoa': 'AS',
    'Arizona': 'AZ',
    'Arkansas': 'AR',
    'California': 'CA',
    'Colorado': 'CO',
    'Connecticut': 'CT',
    'Delaware': 'DE',
    'District of Columbia': 'DC',
    'Florida': 'FL',
    'Georgia': 'GA',
    'Guam': 'GU',
    'Hawaii': 'HI',
    'Idaho': 'ID',
    'Illinois': 'IL',
    'Indiana': 'IN',
    'Iowa': 'IA',
    'Kansas': 'KS',
    'Kentucky': 'KY',
    'Louisiana': 'LA',
    'Maine': 'ME',
    'Maryland': 'MD',
    'Massachusetts': 'MA',
    'Michigan': 'MI',
    'Minnesota': 'MN',
    'Mississippi': 'MS',
    'Missouri': 'MO',
    'Montana': 'MT',
    'Nebraska': 'NE',
    'Nevada': 'NV',
    'New Hampshire': 'NH',
    'New Jersey': 'NJ',
    'New Mexico': 'NM',
    'New York': 'NY',
    'North Carolina': 'NC',
    'North Dakota': 'ND',
    'Northern Mariana Islands':'MP',
    'Ohio': 'OH',
    'Oklahoma': 'OK',
    'Oregon': 'OR',
    'Pennsylvania': 'PA',
    'Puerto Rico': 'PR',
    'Rhode Island': 'RI',
    'South Carolina': 'SC',
    'South Dakota': 'SD',
    'Tennessee': 'TN',
    'Texas': 'TX',
    'Utah': 'UT',
    'Vermont': 'VT',
    'Virgin Islands': 'VI',
    'Virginia': 'VA',
    'Washington': 'WA',
    'West Virginia': 'WV',
    'Wisconsin': 'WI',
    'Wyoming': 'WY',
    "Alberta": "AB",
    "British Columbia": "BC",
    "Manitoba": "MB",
    "New Brunswick": "NB",
    "Newfoundland": "NL",
    "Northwest Territories": "NT",
    "Nova Scotia": "NS",
    "Nunavut": "NU",
    "Ontario": "ON",
    "Prince Edward Island": "PE",
    "Quebec": "PQ",
    "Saskatchewan": "SK",
    "Yukon": "YT",
    "Northern Ireland": "NI"}

# Invert mappings
abbrev_map = {v: k for k, v in abbrev_map.items()}

# Applies mappings to replace state abbreviations
def remap_abbrev(series):
    remapper = lambda row: ' '.join([abbrev_map.get(word, word) for word in row])
    series = series.str.split().apply(remapper)
    return series

def main():
 # body

if __name__=='__main__':
   # run