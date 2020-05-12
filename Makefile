install:
	conda create --name neo4j-titanic --file environment.yml

db:
	docker build -t neo4j-titanic:neo4j_db ./neo4j
	docker run --name neo4j_db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 \
	-v "$(shell pwd)/data/interim":/var/lib/neo4j/import neo4j-titanic:neo4j_db

