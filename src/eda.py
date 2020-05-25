import os
import sys
#from dotenv import load_dotenv, find_dotenv
import numpy as np
import pandas as pd
#import psycopg2

## Returns overview with column, dtype, # unique values, # missing values and sample value
def get_snapshot(dataframe):
    
    """
    Takes an existing DataFrame and creates a pandas DataFrame 
    where each row displays the original DataFrame column name, 
    number of unique values, number of missing values, and a
    random sample value from that column. 
    
    Useful for exploring raw data to quickly figure out appropriate 
    data types.
    
    Example
    -------
    
    snapshot = get_snapshot(my_dataframe)
    
    """

    unique = dataframe.nunique(axis=0)
    is_null = dataframe.isnull().sum()
    data_types = dataframe.dtypes
    
    samples = pd.DataFrame()
    column_names = pd.DataFrame()
    
    for column, row in dataframe.iteritems():
        try:
            sample = dataframe[column].dropna(axis=0).sample()
            column_name = pd.Series(column)
        except:
            pass

        samples = pd.concat([samples, sample], axis=0).reset_index(drop=True)
        column_names = pd.concat([column_names, column_name], 
                                 axis=0, ).reset_index(drop=True)

        examples = pd.concat([column_names, samples], axis=1, ignore_index=True)
        examples.columns = ['COLUMN', 'SAMPLE VALUE']
    
    snapshot = pd.concat([data_types, unique, is_null], axis=1)
    snapshot.reset_index(inplace=True)
    snapshot.columns = columns=['COLUMN', 'DATA TYPE', '# UNIQUE VALUES', '# MISSING VALUES']
    snapshot = snapshot.merge(right=examples, on='COLUMN').drop_duplicates(subset=['COLUMN']).set_index('COLUMN')
    
    return snapshot

# Creates a report to show value counts for columns with less than n unique values
def explore_value_counts(dataframe, n=None, max_n=1500, columns=None, printed=True):
    
    """
    This function is helpful for quickly determining which values
    should be converted to integer or category types in a dataframe.
    
    Prints a series of custom text summaries with n value counts 
    for each column. Can work if neither n nor columns are specified.
    
    Also can return a generator yielding a text summary with n
    value counts for each column.
    
    Example:
    --------
    ## Iterates through individual tables
    gen = explore_value_counts(data, printed=False)
    print(next(gen)) 
    
    ## Prints all tables to STDOUT
    explore_value_counts(data, printed=True)
    
    Params
    --------
    dataframe : pandas DataFrame
        DataFrame with columns to be summarized.
    n : integer or string
        Max number of unique categories in column, or 'all'.
    max_n : integer
        Ceiling safeguard to avoid extremely large values of n
    columns : list 
        Columns to include in output.
    printed : bool
        If True prints to console; if False returns generator object
        which can be printed as text.
    
    Returns
    --------
    if printed=True: prints all formatted text of all tables
    
    if printed=False: generator object that outputs one table
    
    """
    
    # Parsing arguments
    if columns:
        dataframe = dataframe[columns]
    
    if n == 'all':
        n = len(dataframe) if len(dataframe) <= max_n else max_n
    elif not n:
        n = 30
    else:
        n = n if n <= max_n else max_n
        
    def make_tables():
        dataframe_n = pd.DataFrame()

        # Data selection
        for column, row in dataframe.iteritems():
            
            #n_unique = dataframe[column].nunique()
            
            # Throws error if float64 is removed
            if (dataframe[column].dtype not in ['float64', '<M8[ns]']):
                dataframe_n = pd.concat([dataframe_n, dataframe[column]], axis=1)

        summary_list = []

        # Text generation
        for column, row in dataframe_n.iteritems(): 
            series = dataframe_n[column]
            name = series.name
            
            index_slice = n if n <= len(series) else len(series)
            
            # Create dataframe of value counts
            counted = series.value_counts(sort=True)[:index_slice]
            percent = series.value_counts(sort=True, normalize=True)[:index_slice]
            summary = pd.concat([counted, percent], axis=1)
            summary.columns = ['COUNT', 'PERCENTAGE']
            summary.index = summary.index.rename('UNIQUE VALUES:')
            
            # Create a custom table with n unique, missing values to print to console as text
            summary_text = 'COLUMN:   "{}"\nDATA TYPE:  {}'.format(name, series.dtype)
            summary_text = summary_text + '\nTOTAL UNIQUE:  {}'.format(name, series.nunique())
            summary_text = summary_text + '\nTOTAL MISSING:  {}'.format(series.isnull().sum())
            summary_text = summary_text + '\n' + summary.to_string() + '\n\n'

            summary_list.append(summary_text)
        
        if not printed:
            summary_gen = iter(summary_list)
            return summary_gen
        else:
            return summary_list
        
    if printed:
        print('\n'.join(make_tables()))
    else:
        return make_tables()

