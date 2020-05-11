# neo4j-titanic
Straightforward data pipeline for the *RMS Titanic* dataset using Python and Pandas library for preprocessing, as well as NLTK, spaCy and Mordecai for NLP and geoparsing. The data is loaded into a Neo4j graph database for analysis.

## Project Description
The project loads the *RMS Titanic* dataset into Neo4j where relationships between passengers and other entities such as other passengers, lifeboats, and destination countries can be visualized, analyzed and explored.

The pipeline contains two steps 1) preprocessing and 2) geoparsing. The purpose of geoparsing is to extract the destination country of each passenger from the unstructured text in the `home.dest` column. The geoparsing step is optional and requires a running Elasticsearch container, NLTK libraries, spaCy and a gazeteer downloaded and installed. 

If only the preprocessing step is run, the graph will not contain nodes for destination country.

## Getting up and running

### Environment Variables
Determine whether to run the pipeline with or without geoparsing. Running with geoparsing will take additional resources. Update the `.env` file to reflect:
```
GEOPARSE=True  # include geoparsing step
GEOPARSE=False  # skip geoparsing step
```

### Create Environment
Either Anaconda or Virtualenv can be used. Conda is recommended.
```
make create_environment
```

### Start Containers
Neo4j can be run inside a Docker container. To do so run from the root directory:
```
make docker
```
#### Neo4j
Running `make docker` will automate this step but it is possible to build and run the image from scratch:
```
cd neo4j-titanic \
&& docker build -t neo4j-titanic:neo4j_db ./neo4j \
&& docker run --name neo4j_db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 \
-v $PWD/data/interim:/var/lib/neo4j/import neo4j-titanic:neo4j_db
```
#### Elasticsearch (geoparsing only)
Automated if `GEOPARSE=True`. This will run the Elasticsearch container from scratch:
```
docker run -d -p 127.0.0.1:9200:9200 -v $PWD/geoparse/es/geonames_index/:/usr/share/elasticsearch/data elasticsearch:5.5.2
```
### Run Pipeline
To run the pipeline:
```
make data
```

## Sources
A complete *Titanic* dataset is available from [https://data.world/nrippner/titanic-disaster-dataset](https://data.world/nrippner/titanic-disaster-dataset). 