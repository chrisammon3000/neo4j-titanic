## .DEFAULT_GOAL := data

SHELL=/bin/bash
CONDAROOT = /Users/gregory/anaconda3

delete_env:
	source $(CONDAROOT)/bin/activate
	conda env remove --name neo4j-titanic

create_env: delete_env
	## Create environment
	source $(CONDAROOT)/bin/activate \
	&& conda env create -f environment.yml \
	&& conda deactivate

clean:
	@python src/preprocess.py

db: clean
	## Build and run Docker instance of Neo4j
	@docker rm -f /neo4j_db
	@docker build -t neo4j-titanic:neo4j_db ./neo4j
	@docker run --name neo4j_db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 \
	-v "$(shell pwd)/data/interim":/var/lib/neo4j/import neo4j-titanic:neo4j_db
	@echo "Neo4j is starting up..."
	@until $$(curl --output /dev/null --silent --head --fail http://localhost:7474) ; do \
		printf '.' ; \
		sleep 3 ; \
	done	

load_db: db
	## Loading ...
	@cat neo4j/create_db.cyp | docker exec --interactive neo4j_db bin/cypher-shell -u neo4j -p test
	
## Get Neo4j status code:
## "$(shell curl --silent -I http://localhost:7474 | head -n 1 | cut -d ' ' -f2)"
