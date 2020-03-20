# popcrn-gql
Graph database layer using Neo4j for the POPCRN app, accessed through a GraphQL API.

## Project Description
Describes nodes, relationships, and the properties of each. Nodes include Users, Projects, Images and Tags. The database can be run inside a Docker container and accessed via http://<HOST_PUBLIC_IP>:7474.

## Starting the database container

You will need:
* An EC2 Instance (t2.micro) running the standard Amazon Linux AMI
* An EC2 Key Pair
* The Public DNS of the EC2 instance. For example: ```ec2-55-225-196-177.compute-1.amazonaws.com```

1. Launch the EC2 with a security group to allow inbound access on ports 22 (SSH), 7474 and 7687 (neo4j), and 4001 (GraphQL)

2. SSH into the instance and run:<br>
   ```sudo yum update -y```<br>
   ```sudo yum install -y docker```<br>
   ```sudo service docker start```<br>
   ```sudo usermod -a -G docker ec2-user```<br>
   ```exit```

3. SSH back into the instance. To confirm docker is working run ```docker info```

4. Create a network:<br> ```docker network create -d bridge popcrn-net```
   
5. Start the database container by running:<br>
   ```docker run --name db -d -p 7474:7474 -p 7473:7473 -p 7687:7687 --network popcrn-net gclindsey/popcrn-api:db```

6. Open Neo4j in the browser at (`http://<EC2_PUBLIC_IP>:7474`) to interact with Neo4j.

7. Access the Browser Settings (gear icon) and check "Enable multi statement query editor"

8. Paste the query from the file neo4j/create_db.cyp and run it. This will populate the database.


## Starting the GraphQL server
   
1. Run the command:
   ```docker run --name api_v1_1 -d -p 4001:4001 --network popcrn-net gclindsey/popcrn-api:api_v1_1```

2. Access the GraphQL server in a browser:<br>
   `http://<EC2_PUBLIC_IP>:4001/graphql`

3. Refer to the "DOCS" tab on the right side to view all possible Queries (retrieving data) and Mutations (updating data). 

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