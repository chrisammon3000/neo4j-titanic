# neo4j-titanic
Simple data pipeline for the *RMS Titanic* dataset using Python and Pandas library for preprocessing. The data is loaded into a Neo4j graph database for exploration and analysis.

## Project Description
The project loads the *RMS Titanic* dataset into Neo4j where relationships between passengers and other entities such as other passengers, lifeboats, and destination countries can be visualized, analyzed and explored.

## Run Pipeline
Ensure that the Pandas library and Docker are installed. To run the pipeline:
```
make data
```
This will fetch the data, process it and save it to the /data folder, pull a Neo4j Docker image, start the container and load the processed data using the create_db.cyp file.

## Sources
A complete *Titanic* dataset is available from [https://data.world/nrippner/titanic-disaster-dataset](https://data.world/nrippner/titanic-disaster-dataset). 