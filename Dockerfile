# Built referencing Combat-TB-NeoDB
# Build Neo4j image
# Run script that pipes in command to create a create_db.cyp file in ./neo4j:/var/lib/neo4j/import
# Run cypher-shell script that loads the data

# To run:
# docker run -it --publish=7474:7474 --publish=7687:7687 -d --env NEO4J_AUTH=neo4j/test <image tag>

FROM neo4j:3.5.14
#LABEL Maintainer="gclindsey@gmail.com"

ENV NEO4J_AUTH="neo4j/test"
# ENV NEO4J_SECRETS_PASSWORD = "test"

RUN apt-get update \
    && apt-get install -y \ 
    wget \ 
    apt-utils

# APOC, Algorithms and Guide settings 
# RUN echo 'dbms.security.procedures.whitelist=apoc.*, algo.*' >> conf/neo4j.conf \
#     && echo 'dbms.security.procedures.unrestricted=apoc.*, algo.*' >> conf/neo4j.conf \
#     && echo 'dbms.unmanaged_extension_classes=extension.web=/guides' >> conf/neo4j.conf \
#     ## The extension assumes that you added a 'guides' directory in the "data".
#     && echo 'org.neo4j.server.guide.directory=data/guides' >> conf/neo4j.conf \ 
#     && echo 'browser.remote_content_hostname_whitelist=*' >> conf/neo4j.conf \
RUN echo 'apoc.import.file.enabled=true' >> conf/neo4j.conf \
    && echo 'dbms.logs.query.enabled=true' >> conf/neo4j.conf

COPY ./neo4j/create_db.cyp /var/lib/neo4j/import/
COPY ./docker-neo4j-entrypoint.sh /var/lib/neo4j

RUN ["chmod", "+x", "/var/lib/neo4j/docker-neo4j-entrypoint.sh"]

# VOLUME /data

# # Download Google Sheets data as .csv
# RUN cd import \ 
#     && wget -O profile.csv https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=1801331028 \
#     && echo "Downloading from Google Sheets: profile.csv ..." \
#     && wget -O project.csv https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=276470380 \
#     && echo "Downloading from Google Sheets: project.csv ..." \
#     && wget -O media.csv https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=0 \
#     && echo "Downloading from Google Sheets: media.csv ..."

# VOLUME /import

RUN echo "Neo4j is ready."

ENTRYPOINT ["./docker-neo4j-entrypoint.sh"]
CMD ["neo4j"]

#  && cat import/create_db.cyp | bin/cypher-shell -u neo4j -p test

# Run cypher-shell to execute query from file 