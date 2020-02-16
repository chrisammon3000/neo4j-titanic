# popcrn-gql
Graph database layer using Neo4j for the POPCRN app, accessed through a GraphQL API.

## Project Description
Describes nodes, relationships, and the properties of each. Nodes include Users, Projects, Images and Tags. The database can be run inside a Docker container and accessed via http://localhost:7474.

## Starting the database

1. Clone this repo.

2. Open terminal and navigate to the project directory, then build the image by running:
<br>```$ docker build -t popcrn-gql .```

1. Next start the container in the background by running:
<br>```$ docker run -it --publish=7474:7474 --publish=7687:7687 -d popcrn-gql```

4. Run `$ docker ps` and copy the CONTAINER ID

5. Insert the CONTAINER ID and access the running container's terminal by running:
<br>```$ docker exec -it <CONTAINER ID> bash```

6. Once you are inside the container, use cypher-shell to load data from Google Sheets:
<br>```$ cat import/create_db.cyp | bin/cypher-shell -u neo4j -p test```

1. Open the Neo4j browser at `http://localhost:7474` to view the graph.


