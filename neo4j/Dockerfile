# docker build -t neo4j-titanic:neo4j_db ./neo4j \
# && docker run --name neo4j_db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 \
# -v $PWD/data/interim:/var/lib/neo4j/import neo4j-titanic:neo4j_db

FROM neo4j:3.5.12

# RUN apt-get update \
#     && apt-get install -y wget openssl apt-utils zip unzip

ENV NEO4J_AUTH=neo4j/test \
    APOC_VERSION=3.5.0.5

ENV APOC_URI https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/${APOC_VERSION}/apoc-${APOC_VERSION}-all.jar
RUN sh -c 'cd /var/lib/neo4j/plugins && curl -L -O "${APOC_URI}"'

EXPOSE 7474 7473 7687

CMD ["neo4j"]
