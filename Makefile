.PHONY: clean data

SHELL=/bin/bash
CONDAROOT=/Users/gregory/anaconda3
CONTAINER=neo4j_db

## Delete Conda environment
delete_env:
	@source $(CONDAROOT)/bin/activate
	@conda env remove --name neo4j-titanic-env

## Create Conda environment
create_env: delete_env
	@echo "###Create environment###"
	@source $(CONDAROOT)/bin/activate \
	&& conda env create -f environment.yml \
	&& conda deactivate

## Create data directory if not present
check_directory: 
	@if [ ! -d "./data" ]; then mkdir -p data/{interim,processed,raw}; fi

## Fetch, process and save data
process_data: check_directory
	@echo "### Begin Pipeline ###"
	@python src/preprocess.py

## Start Docker Neo4j Instance
db: process_data
	@echo "### Building Neo4j Docker instance... ###"
	@[[ $$(docker ps -f "name=neo4j_db" --format '{{.Names}}') != "neo4j_db" ]] || docker rm -f neo4j_db
	@docker build -t neo4j-titanic:neo4j_db ./neo4j && \
	docker run --rm --name neo4j_db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 \
	-v "$(shell pwd)/data/processed":/var/lib/neo4j/import neo4j-titanic:neo4j_db
	@echo "### Starting Neo4j... ###"
	@until $$(curl --output /dev/null --silent --head --fail http://localhost:7474) ; do \
		printf '.' ; \
		sleep 1 ; \
	done
	@printf "%s\n" " "

## Run pipeline
data: db
	@echo "### Importing data... ###"
	@cat neo4j/create_db.cyp | docker exec --interactive neo4j_db bin/cypher-shell -u neo4j -p test
	@printf "Finished!"
	@printf "\n%s\n" 'Neo4j is available at http://localhost:7474.'

## Stop Neo4j
stop_db:
	@echo "### Stopping Neo4j... ###"
	@docker exec --interactive neo4j_db bin/neo4j stop


## Delete all compiled Python files
clean_up: stop_db
	@echo "### Removing container... ###"
	@docker rm -f neo4j_db
	@echo "### Cleaning up cache... ###"
	@find . -type f -name "*.py[co]" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "Done."

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>

.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')