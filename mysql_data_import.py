# Connect and import multiple csv files into MySQL Database 

import pandas as pd 
from sqlalchemy import create_engine
import os
    
# Set up engine ('mysql+mysqlconnector://user:password@hostname/dbname)
engine = create_engine('mysql+mysqlconnector://root:***********@localhost/adventureworks2022')

# Path to directory containing csv files
csv_dir = '/Users/jaypaints/Downloads/AdventureWorks2022'

# Exract csv files in the directory into a list
csv_files = [file for file in os.listdir(csv_dir) if file.lower().endswith('.csv')]

# Loop over the csv files, extract file names and use as database table names 
for file in csv_files:
    table_name = os.path.splitext(file)[0].lower()
    csv_path = os.path.join(csv_dir, file)
    # Read csv files into pandas DataFrames
    df = pd.read_csv(csv_path, encoding = 'latin1')
    print(f"--- Data read from csv file into DataFrame {table_name}. ---")
    print(df.head())
    # Create and query the tables in the database
    df.to_sql(name = table_name, con = engine, if_exists = 'replace', index = False)
    sql = 'SELECT * FROM ' + table_name
    data_db = pd.read_sql_query(sql, engine)
    print(f"--- DB table {table_name} created successfully! ---")
    print(data_db.head())

print("All csv files imported into separate tables in the adventureworks2022 database.")

