# titanic-neo4j
Graph analysis of Titanic dataset using Python for data pre-proceesing and Neo4j for graph analysis. 

## Project Description
The project aims to use graph analysis to investigate interesting questions such as:

1) **What was the plight of families during the rescue?**

## Sources
A complete *Titanic* dataset is available from [https://data.world/nrippner/titanic-disaster-dataset](https://data.world/nrippner/titanic-disaster-dataset). 

## Getting up and running
To run the preprocssing steps an ElasicSearch container must be running and accessible on port 9200:
```
docker pull elasticsearch:5.5.2 \
&& wget https://s3.amazonaws.com/ahalterman-geo/geonames_index.tar.gz --output-file=wget_log.txt \
&& tar -xzf geonames_index.tar.gz \
&& docker run -d -p 127.0.0.1:9200:9200 -v "$(pwd)/es/geonames_index/:/usr/share/elasticsearch/data" elasticsearch:5.5.2
```