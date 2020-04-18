FROM neo4j:3.5.12

# RUN apt-get update \
#     && apt-get install -y wget openssl apt-utils zip unzip

ENV NEO4J_AUTH=neo4j/test \
    APOC_VERSION=3.5.0.5 \  
    GRAPHQL_VERSION=3.5.0.4

ENV APOC_URI https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/${APOC_VERSION}/apoc-${APOC_VERSION}-all.jar
RUN sh -c 'cd /var/lib/neo4j/plugins && curl -L -O "${APOC_URI}"'

ENV GRAPHQL_URI https://github.com/neo4j-graphql/neo4j-graphql/releases/download/${GRAPHQL_VERSION}/neo4j-graphql-${GRAPHQL_VERSION}.jar
RUN sh -c 'cd /var/lib/neo4j/plugins && curl -L -O "${GRAPHQL_URI}"'

# ENV DB_VERSION="3274226"
# RUN wget "https://zenodo.org/record/${DB_VERSION}/files/neodb-db-data.tar.bz2" \
#     -O neodb_db_data.tar.bz2 \
#     && tar xvfj neodb_db_data.tar.bz2 \
#     && rm -rf neodb_db_data.tar.bz2 \
#     && cp -r databases /data/

COPY ./create_db.cyp /var/lib/neo4j/import

EXPOSE 7474 7473 7687

CMD ["neo4j"]
