# neo4j-titanic
Simple data pipeline for the *RMS Titanic* dataset using Python and Pandas library for preprocessing. The data is loaded into a Neo4j graph database for exploration and analysis.

#### -- Project Status: [Active]

## Project Description
The pipeline fetches the *RMS Titanic* dataset, cleans, preprocesses it then loads it into a Docker Neo4j instance where relationships between passengers and other entities such as other passengers, lifeboats, cabins, and other data can be visualized, analyzed and explored.

![Neo4j Browser](/img/neo4jbrowser.png)

## Run Pipeline
Ensure that the Pandas library and Docker are installed. To run the pipeline, clone the repo and run:
```
make data
```
This will fetch the data, process it and save it to the /data folder, pull a Neo4j Docker image, start the container and load the processed data using the create_db.cyp file.

To explore the database, navigate to the [Neo4j Browser](http://localhost:7474/browser/) and run any Cypher query. 

When finished, ```make clean_up``` will stop Neo4j, remove the container and clean up cache files.

## Sources
A complete *Titanic* dataset is available from [https://data.world/nrippner/titanic-disaster-dataset](https://data.world/nrippner/titanic-disaster-dataset). 

## Authors
[Gregory Lindsey](https://github.com/gclindsey) 

## License
This project is licensed under the MIT License - see the LICENSE file for details