"""
RMS Titanic dataset to Neo4j pipeline module

This module takes the RMS Titanic dataset as .csv and geoparses the 
`home.dest` column to extract `home.country` as the name of the
destination country. For more info please see the accompanying 
notebooks.

Example
-------

    '>>> example'

"""

import os
import sys
import pandas as pd
import nltk
from mordecai import Geoparser
import pycountry

# Check that Elasticsearch is running


# Download NLP data for country extraction // make this modular by setting nltk data path
nltk.download('treebank')
nltk.download('maxent_treebank_pos_tagger')
nltk.download('punkt') # Download corpora for GPE extraction
nltk.download('averaged_perceptron_tagger')
nltk.download('maxent_ne_chunker')
nltk.download('words')

# Can be used with Pandas apply method. Use batch version for better speed.
def extract_country(row):
    geo = Geoparser()
    inferred = geo.geoparse(row)
    country_range = range(len(inferred))
    home_countries = set([inferred[i]['country_predicted'] for i in country_range])
    home_countries = ", ".join(home_countries)
    
    return home_countries

# Finished
def batch_extract_country(series):
    countries = []
    geo = Geoparser(es_hosts=['localhost'], es_port=9200)
    batch = geo.batch_geoparse(series)
    for doc_list in batch:
        row = ", ".join(set([entry['country_predicted'] for entry in doc_list]))
        countries.append(row)
    
    return pd.Series(countries)

# Finished
def lookup_country_name(row):
    if row == "":
        return ""
    else:
        words = row.split(', ')
        lookup = lambda country: pycountry.countries.lookup(country).name
        names = list(map(lookup, words))
        names = ", ".join(names)
        return names

# def geoparse_data(data):
    
#     # Apply mappings to replace state abbreviations
#     data['home.dest'] = remap_abbrev(data['home.dest'])

#     # Parses home.dest to infer destination countries for each passenger. \\
#     # This step takes a while depending on the machine.
#     data['home.country'] = batch_extract_country(data['home.dest'])
    
#     # Converts ISO country code to country name
#     data['home.country'] = data['home.country'].apply(lookup_country_name)

#     return data

# def main(data):
#     # body

# # if __name__=='__main__':
# #     # run