// Full Query

// User
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=1801331028' AS profile_line
CREATE (user:User { 
    userId: profile_line.userId,
    userHandle: profile_line.userHandle,
	userSiteName:profile_line.userSiteName,
    userFirstName: profile_line.userFirstName,
    userLastName: profile_line.userLastName,
    userFullName: profile_line.userFirstName + " " + profile_line.userLastName,
    userEmail: profile_line.userEmail,
    userPassword: profile_line.userPassword,
    userGender: profile_line.userGender,
    userRating: profile_line.userRating,
    userRoles: split(profile_line.userRoles, ','),
    userBio: profile_line.userBio,
    userSkills: split(profile_line.userSkills, ','),
    userClients: split(profile_line.userClients, ','),
    userLocation: profile_line.userLocation,
    userWebsite: profile_line.userWebsite,
    userProfile_FG: profile_line.userProfile_FG,
    userProfile_BG: profile_line.userProfile_BG 
    } )

// (User)-[:FOLLOWS]->(User)
WITH profile_line, split(profile_line.userFollowers, ',') AS followers
UNWIND followers AS follower
MERGE (user:User { userHandle: profile_line.userHandle })
WITH user, follower
MATCH (f:User { userHandle: follower })
CREATE (f)-[r:FOLLOWS]->(user)
SET r.followedDate = date(), r.followedType = 'USER'

// PICKUP HERE
// Create Project nodes
WITH max(1) AS dummy
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=276470380' AS project_line
CREATE (project:Project { 
    projectId: project_line.projectid,
    projectName: project_line.name,
	projectCreatedBy: '(userHandle)',
    projectDescription: project_line.description,
    projectCreatedDate: date()
    } )

// (User)-[:WORKED_ON]->(Project)
WITH project_line, 
	split(trim(project_line.users), ',') AS collaborators, 
    project_line.projectid AS project_Id
UNWIND collaborators AS collaborator
MATCH (user:User { userHandle: collaborator} )
WITH user, project_Id
MATCH (project:Project { projectId: project_Id })
CREATE (user)-[rel:WORKED_ON]->(project)
SET rel.workedOnDate = date(), 
	rel.userRoles = ['role 1', 'role 2'];

// Create Image & Tag nodes
WITH max(1) AS dummy
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=0' AS image_line

// Image nodes
CREATE (image:Image { 
    imageId: '(imageId)',
    imageOwner: '@'+image_line.owner,
	imageCreatedDate: date(),
    imageCaption: '(caption)',
    imageDescription: '(description)',
    imageURL: image_line.url
    } )

// Tag nodes
WITH image_line, split(image_line.tags, ',') AS tagnames
UNWIND tagnames AS tagname
WITH DISTINCT tagname AS tag_node
CREATE (tag:Tag { 
    tagId: '(tagId)',
    tagName: tag_node,
	tagCreatedDate: date(),
    tagCreatedBy: '(userHandle)'
    } )

// (Image)-[:FROM]->(Project) - there is no project for the value 'Display' in media.csv
WITH max(1) AS dummy
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=0' AS image_line
WITH image_line, image_line.projectid AS project_Id, image_line.url AS image_URL
MATCH (image:Image { imageURL: image_URL })
WITH image, project_Id
MATCH (project:Project { projectId: project_Id })
CREATE (image)-[rel:FROM]->(project)
SET rel.imageTaggedDate = date(), rel.taggedByUser = '(userHandle)'

// (User)-[:CREATED]->(Image)
WITH max(1) AS dummy
MATCH (user:User) 
WITH user
MATCH (image:Image)
WHERE user.userHandle = image.imageOwner
CREATE (user)-[r:CREATED]->(image) SET r.createdDate = date(), r.createdType = 'IMAGE';

// (User)-[:FOLLOWS]->(Tag)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=1801331028' AS profile_line
WITH '@'+profile_line.handle AS user_handle, 
    split(profile_line.interests_tags, ',') AS interests
UNWIND interests AS interest
MATCH (user:User { userHandle: user_handle })
WITH user, interest
MATCH (tag:Tag { tagName: interest})
CREATE (user)-[r:FOLLOWS]->(tag)
SET r.followedDate = date(), r.followedType = 'TAG';

// (Project)-[:IS_TAGGED]->(Tag)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=276470380' AS project_line
WITH split(project_line.tags, ',') AS project_tags, project_line.projectid AS project_Id
UNWIND project_tags AS project_tag
MATCH (project:Project { projectId: project_Id })
WITH project, project_tag
MATCH (tag:Tag { tagName: project_tag })
CREATE (project)-[rel:IS_TAGGED]->(tag) 
SET rel.projectTaggedDate = date(), 
	rel.taggedByUser = '(userHandle)';

// (Image)-[:IS_TAGGED]->(Tag)
WITH max(1) AS dummy
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=0' AS image_line
WITH image_line.url AS image_URL, split(image_line.tags, ',') AS image_tags
UNWIND image_tags AS image_tag
MATCH (image:Image { imageURL: image_URL })
WITH image, image_tag
MATCH (tag:Tag { tagName: image_tag })
CREATE (image)-[rel:IS_TAGGED]->(tag)
SET rel.imageTaggedDate = date(), 
	rel.taggedByUser = 'userHandle',
    rel.tagType = 'IMAGE';

// (User)-[:IS_TAGGED_IN]->(Image)
WITH max(1) AS dummy
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0/export?format=csv&id=1LpluS0A4aPHeftGW3R6tyCRHqc3czRVxzogXrWMI3o0&gid=0' AS image_line
WITH split(image_line.users, ',') AS user_handles, image_line.url AS image_URL
UNWIND user_handles AS user_handle
MATCH (user:User { userHandle: user_handle})
WITH user, image_URL
MATCH (image:Image { imageURL: image_URL })
CREATE(user)-[rel:IS_TAGGED_IN]->(image)
SET rel.userTaggedDate = date(), rel.taggedByUser = '(userHandle)';
// User LIKES Image
// User LIKES Project
// User FOLLOWS Project, Tag
// Constraints