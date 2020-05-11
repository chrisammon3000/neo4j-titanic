#!/bin/bash

cat neo4j/create_db.cyp | docker exec --interactive neo4j_db bin/cypher-shell -u neo4j -p test