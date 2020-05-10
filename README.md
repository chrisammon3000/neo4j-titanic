# titanic-neo4j
Data pipeline for the *RMS Titanic* dataset using Python for preprocessing, NLP, and geoparsing and Neo4j for graph analysis. 

## Project Description
The project loads the *RMS Titanic* dataset into Neo4j where family relationships between passengers as well as context including other entities such as lifeboats, destination countries can be visualized, analyzed and explored.

## Getting up and running
To run the preprocssing steps an ElasicSearch container must be running and accessible on port 9200:
```
cd es/ \
docker pull elasticsearch:5.5.2 \
&& wget https://s3.amazonaws.com/ahalterman-geo/geonames_index.tar.gz --output-file=wget_log.txt \
&& tar -xzf geonames_index.tar.gz \
&& docker run -d -p 127.0.0.1:9200:9200 -v "$(pwd)/geonames_index/:/usr/share/elasticsearch/data" elasticsearch:5.5.2
```

## Sources
A complete *Titanic* dataset is available from [https://data.world/nrippner/titanic-disaster-dataset](https://data.world/nrippner/titanic-disaster-dataset). 