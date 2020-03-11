# popcrn-gql
Graph database layer using Neo4j for the POPCRN app, accessed through a GraphQL API.

## Project Description
Describes nodes, relationships, and the properties of each. Nodes include Users, Projects, Images and Tags. The database can be run inside a Docker container and accessed via http://localhost:7474.

## Starting the database

1. Clone this repo.

2. Open terminal and navigate to the project directory, then build the image by running:
<br>```$ docker build -t popcrn-gql-db .```

1. Next start the container in the background by running:
<br>```$ docker run -it --publish=7474:7474 -v $HOME/neo4j/data:/data --publish=7687:7687 -d popcrn-gql-db```

4. Run `$ docker ps` and copy the CONTAINER ID

5. Insert the CONTAINER ID and access the running container's terminal by running:
<br>```$ docker exec -it <CONTAINER ID> bash```

6. Once you are inside the container, use cypher-shell to load data from Google Sheets:
<br>```$ cat import/create_db.cyp | bin/cypher-shell -u neo4j -p test```

1. Open the Neo4j browser at `http://localhost:7474` to view the graph. Connect clients on `bolt://localhost:7687`.

## Connecting to the database
Once the database is running and data has been imported, connections can be made on port 7687 using a client such as py2neo for Python (see examples in `notebooks/` directory). Be sure to install the appropriate drivers. More info at:
https://neo4j.com/developer/language-guides/.

## GraphQL API Setup

More queries will be added to the API as more progress is made. 

### Getting Started
To get started run:

```cd api```

```npm build && npm start```

The GraphQL server will be available at [http://localhost:4001/graphql](http://localhost:4001/graphql). Refer to the "DOCS" tab on the right side to view all possible Queries (retrieving data) and Mutations (updating data). 

### Example GraphQL Queries
A query for the name, email and handle of the User with userId: 2 can be run as follows:
```
{
  User(userId: "2"){
    userFirstName
    userLastName
    userEmail
    userHandle
  }
}
```
This returns:
```
{
  "data": {
    "User": [
      {
        "userFirstName": "ben",
        "userLastName": "phics",
        "userEmail": "ben@gmail.com",
        "userHandle": "@ben_phics"
      }
    ]
  }
}
```
Important relationships are also represented by the schema. They can be retrieved as follows:
```
{
  User(userId: "2") {
    userFollowers {
      userHandle
    }
    userIsTagged {
      imageURL
    }
  }
}

```
This returns:
```
{
  "data": {
    "User": [
      {
        "userFollowers": [
          {
            "userHandle": "@sultan_morgan"
          },
          {
            "userHandle": "@anais_morin"
          },
          ...
        ],
        "userIsTagged": [
          {
            "imageURL": "./amanda_styles/Projects/Branding - Blond/amanda_styles_010.jpg"
          },
          {
            "imageURL": "./amanda_styles/Projects/Branding - Blond/amanda_styles_009.jpg"
          },
          ...
        ]
      }
    ]
  }
}
```
### Using the `curl` with GraphQL
To query the GraphQL endpoint from the command line, use the curl utility. For example, to query the followers of a particular user, paste in the GraphQL URI and run:

<br>```curl -X POST -H "Content-Type: application/json" --data \```<br>
```'{ "query": "{ User (userId: 1) { userFollowers { userHandle } } }" }' <URI>```
<br><br>Result:

```{"data":{"User":[{"userFollowers":[{"userHandle":"@ben_phics"},{"userHandle":"@tyreece_santiago"},{"userHandle":"@ephraim_rivas"}]}]}}```
<br>

To understand more about GraphQL refer to [Introduction to GraphQL](https://graphql.org/learn/).