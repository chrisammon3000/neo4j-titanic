# neo4j-titanic
Data pipeline for the *RMS Titanic* dataset using Python for preprocessing, NLP, and geoparsing and Neo4j for graph analysis. 

## Project Description
The project loads the *RMS Titanic* dataset into Neo4j where relationships between passengers and other entities such as other passengers, lifeboats, and destination countries can be visualized, analyzed and explored.

The pipeline contains two steps 1) preprocessing and 2) geoparsing. The geoparsing step is optional and requires a running Elasticsearch container, NLTK libraries, spaCy and a gazeteer downloaded and installed. The purpose of geoparsing is to extract the destination country of each passenger from the unstructured text in the `home.dest` column.

## Getting up and running

### Neo4j Docker
Neo4j can be run inside a Docker container. To do so run from the root directory:
```
cd neo4j-titanic \
&& docker build -t neo4j-titanic:neo4j_db ./neo4j \
&& docker run --name neo4j_db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 \
-v $PWD/data/interim:/var/lib/neo4j/import neo4j-titanic:neo4j_db
```
### Elasticsearch Docker (optional)
1) Update the environment by installing the dependencies in the `geoparse` directory. 
`bash ./geoparse/scripts/geoparse_env.sh`
2)  
To run the geoparsing steps an Elasicsearch container must be running and accessible on port 9200:
```
docker run -d -p 127.0.0.1:9200:9200 -v $PWD/geoparse/es/geonames_index/:/usr/share/elasticsearch/data elasticsearch:5.5.2
```

## Sources
A complete *Titanic* dataset is available from [https://data.world/nrippner/titanic-disaster-dataset](https://data.world/nrippner/titanic-disaster-dataset). 