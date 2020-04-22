LOAD CSV WITH HEADERS // User
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=1801331028' AS profile_line
CREATE (user:User {
    userId: apoc.create.uuid(),
    userHandle: profile_line.userHandle,
	userSiteName: trim(profile_line.userSiteName),
    userFirstName: trim(profile_line.userFirstName),
    userLastName: trim(profile_line.userLastName),
    userFullName: profile_line.userFirstName + " " + profile_line.userLastName,
    userEmail: profile_line.userEmail,
    userPassword: trim(profile_line.userPassword) + "123",
    userGender: profile_line.userGender,
    userSince: date(),
    userRating: profile_line.userRating,
    userCreativeField: split(profile_line.userRoles, ','),
    userCreativeInterestTags: split(profile_line.userInterestTags, ','),
    userBio: trim(profile_line.userBio),
    userSkills: split(profile_line.userSkills, ','),
    userClients: split(profile_line.userClients, ','),
    userCity: profile_line.userLocation,
    userCountry: 'United States',
    userWebsite: profile_line.userWebsite,
    userProfile_FG: profile_line.userProfile_FG,
    userProfile_BG: profile_line.userProfile_BG,
    userRateAmount: 100.00,
    userRatePeriod: 'Hourly',
    userAvailability: 'Part-time',
    userAvailableDays: '[Weekdays, Weekends]',
    reactionNotifications: TRUE,
    userPhone: '310-321-7654',
    userCompany: 'MyCompany'
    } )
WITH profile_line, split(profile_line.userFollowers, ',') AS followers // (User)-[:FOLLOWS]->(User)
UNWIND followers AS follower
MERGE (user:User { userHandle: profile_line.userHandle })
WITH user, follower
MATCH (f:User { userHandle: follower })
CREATE (f)-[r:FOLLOWS]->(user)
SET r.followedDate = date(), r.followedType = 'USER';

WITH max(1) AS dummy // Project nodes
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=276470380' AS project_line
CREATE (project:Project { 
    projectUUID: apoc.create.uuid(),
    projectId: project_line.projectId,
    projectName: project_line.projectName,
	projectCreator: project_line.projectCreator,
    projectDescription: project_line.projectDescription,
    projectCreatedDate: project_line.projectCreatedDate,
    projectCollaborators: split(project_line.projectCollaborators, ','),
    projectTagNames: split(project_line.projectTagNames, ','),
    projectCreativeInterestTags: 'tag name'
    } )
WITH project_line, 
	split(trim(project_line.projectCollaborators), ',') AS collaborators, 
    project_line.projectId AS project_Id // (User)-[:COLLABORATED_ON]->(Project)
UNWIND collaborators AS collaborator
MATCH (user:User { userHandle: collaborator} )
WITH user, project_Id
MATCH (project:Project { projectId: project_Id })
CREATE (user)-[rel:COLLABORATED_ON]->(project)
SET rel.workedOnDate = date(), 
	rel.userRoles = split("userRole 1, userRole 2", ',');

WITH max(1) AS dummy // (User)-[:FOLLOWS]->(Project)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=276470380' AS project_line
WITH project_line,
    split(project_line.projectFollowers, ',') as followers,
    project_line.projectId as project_Id
UNWIND followers as follower
MATCH (user:User { userHandle: follower } )
WITH user, project_Id
MATCH (project:Project { projectId: project_Id } )
CREATE (user)-[rel:FOLLOWS]->(project)
SET rel.followedDate = date(), rel.followedType = 'PROJECT';

WITH max(1) AS dummy // (User)-[:CREATED]->(Project)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=276470380' AS project_line
WITH project_line, 
    project_line.projectCreator as project_creator,
    project_line.projectId as project_Id
MATCH (user:User { userHandle: project_creator } )
WITH user, project_Id
MATCH (project:Project { projectId: project_Id } )
CREATE (user)-[rel:CREATED]->(project)
SET rel.createdDate = date(), rel.createdType = 'PROJECT';

WITH max(1) AS dummy  // Image nodes
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=0' AS image_line
CREATE (image:Image { 
    imageUUID: apoc.create.uuid(),
    imageId: image_line.imageId,
    imageCreator: image_line.imageCreator,
	imageCreatedDate: date(),
    imageCaption: '(caption)',
    imageDescription: '(description)',
    imageURL: image_line.imageURL,
    imageTagNames: split(image_line.imageTagNames, ','),
    imageTaggedUsers: split(image_line.imageTaggedUsers, ',')
    } )
WITH image_line, split(image_line.imageTagNames, ',') AS tagnames // Tag nodes
UNWIND tagnames AS tagname
WITH DISTINCT tagname AS tag_node
CREATE (tag:Tag { 
    tagId: apoc.create.uuid(),
    tagName: tag_node,
	tagCreatedDate: date(),
    tagCreatedBy: '(userHandle)'
    } );
WITH max(1) AS dummy // (Image)-[:FROM]->(Project) - there is no project for the value 'Display' in media.csv
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=0' AS image_line
WITH image_line, image_line.projectId AS project_Id, image_line.imageURL AS image_URL
MATCH (image:Image { imageURL: image_URL })
WITH image, project_Id
MATCH (project:Project { projectId: project_Id })
CREATE (image)-[rel:FROM]->(project)
SET rel.imageTaggedDate = date(), rel.taggedByUser = '(userHandle)'
WITH max(1) AS dummy // (User)-[:CREATED]->(Image)
MATCH (user:User)
WITH user
MATCH (image:Image)
WHERE user.userHandle = image.imageOwner
CREATE (user)-[r:CREATED]->(image) SET r.createdDate = date(), r.createdType = 'IMAGE';

WITH max(1) AS dummy // (User)-[:FOLLOWS]->(Tag)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=1801331028' AS profile_line
WITH profile_line.userHandle AS user_handle, 
    split(profile_line.userInterestTags, ',') AS interests
UNWIND interests AS interest
MATCH (user:User { userHandle: user_handle })
WITH user, interest
MATCH (tag:Tag { tagName: interest })
CREATE (user)-[r:FOLLOWS]->(tag)
SET r.followedDate = date(), r.followedType = 'TAG';

WITH max(1) AS dummy // (Project)-[:IS_TAGGED]->(Tag)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=276470380' AS project_line
WITH split(project_line.projectTagNames, ',') AS project_tags, project_line.projectId AS project_Id
UNWIND project_tags AS project_tag
MATCH (project:Project { projectId: project_Id })
WITH project, project_tag
MATCH (tag:Tag { tagName: project_tag })
CREATE (project)-[rel:IS_TAGGED]->(tag) 
SET rel.projectTaggedDate = date(), 
	rel.taggedByUser = '(userHandle)';

WITH max(1) AS dummy // (Image)-[:IS_TAGGED]->(Tag)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=0' AS image_line
WITH image_line.imageURL AS image_URL, split(image_line.imageTagNames, ',') AS image_tags
UNWIND image_tags AS image_tag
MATCH (image:Image { imageURL: image_URL })
WITH image, image_tag
MATCH (tag:Tag { tagName: image_tag })
CREATE (image)-[rel:IS_TAGGED]->(tag)
SET rel.imageTaggedDate = date(), 
	rel.taggedByUser = 'userHandle',
    rel.tagType = 'IMAGE';

WITH max(1) AS dummy // (User)-[:IS_TAGGED_IN]->(Image)
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=0' AS image_line
WITH split(image_line.imageTaggedUsers, ',') AS user_handles, image_line.imageURL AS image_URL
UNWIND user_handles AS user_handle
MATCH (user:User { userHandle: user_handle})
WITH user, image_URL
MATCH (image:Image { imageURL: image_URL })
CREATE(user)-[rel:IS_TAGGED_IN]->(image)
SET rel.userTaggedDate = date(), rel.taggedByUser = '(userHandle)';