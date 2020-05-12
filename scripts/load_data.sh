#!/bin/bash

docker build -t neo4j-titanic:neo4j_db ./neo4j \
&& docker run --name neo4j_db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 \
-v $PWD/data/interim:/var/lib/neo4j/import neo4j-titanic:neo4j_db

cat neo4j/create_db.cyp | docker exec --interactive neo4j_db bin/cypher-shell -u neo4j -p test