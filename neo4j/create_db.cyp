MATCH (n) DETACH DELETE n;
LOAD CSV WITH HEADERS // Passenger nodes
FROM "file:///titanic_clean.csv" AS row
CREATE (p:Passenger {
	name: row.name,
    age: toFloat(row.age),
    embarked: row.embarked,
    destination: row.`home.dest`,
    pclass: toInteger(row.pclass),
	fare: toFloat(row.fare),
    ticket: row.ticket,
    sibsp: row.sibsp,
    parch: row.parch,
    family_size: toInteger(row.`family.size`),
    surname: row.surname,
    cabin: row.cabin,
    deck: row.deck,
    sex: row.sex,
    survived: toInteger(row.survived),
    lifeboat_no: row.boat,
    body: row.body
    });

// Class nodes (pclass)
MATCH (p:Passenger)
WITH DISTINCT p.pclass as class
CREATE (c:Class { pclass: class });

// Cabin nodes
MATCH (p:Passenger)
WITH DISTINCT split(p.cabin, ' ') as cabins
UNWIND cabins AS cabin
CREATE (c:Cabin { cabin: cabin });

// Embarked nodes
MATCH (p:Passenger)
WITH DISTINCT p.embarked as embarked
CREATE (:Embarked { embarked: embarked });

// Lifeboat
MATCH (p:Passenger)
WITH split(p.lifeboat_no, ' ') AS lifeboats
UNWIND lifeboats AS lifeboat
WITH DISTINCT lifeboat AS boat
CREATE (:Lifeboat { lifeboat_no: boat });

// Ticket nodes
MATCH (p:Passenger)
WITH DISTINCT p.ticket AS ticket
CREATE (:Ticket { ticket: ticket });

// Deck nodes
MATCH (p:Passenger)
WITH DISTINCT p.deck AS deck
CREATE (:Deck { deck: deck });









// (p)-[:IN_CLASS]->(c)
MATCH (c:Class)
WITH c, c.pclass as class
MATCH (p:Passenger { pclass: class })
MERGE (p)-[:IN_CLASS]->(c)

WITH max(1) AS dummy // Cabin nodes (cabin)
LOAD CSV WITH HEADERS
FROM "file:///titanic_clean.csv" AS row
WITH row, split(row.cabin, ' ') as cabins
UNWIND cabins AS cabin
WITH DISTINCT cabin AS cabin_no
CREATE (c:Cabin { no: cabin_no });

WITH max(1) AS dummy // (Passenger)-[:SLEPT_IN]->(Cabin)
LOAD CSV WITH HEADERS
FROM "file:///titanic_clean.csv" AS row
WITH row.name as name, split(row.cabin, ' ') as cabins
UNWIND cabins AS cabin
MATCH (p:Passenger { name: name })
WITH p, cabin
MATCH (c:Cabin { no: cabin })
CREATE (p)-[:SLEPT_IN]->(c);

WITH max(1) AS dummy // Embarked nodes
LOAD CSV WITH HEADERS
FROM "file:///titanic_clean.csv" AS row
WITH DISTINCT row.embarked AS embarked
CREATE (e:Embarked { city: embarked });

WITH max(1) AS dummy // (Passenger)-[:EMBARKED_FROM]->(Embarked)
LOAD CSV WITH HEADERS
FROM "file:///titanic_clean.csv" AS row
MATCH (p:Passenger { name: row.name })
WITH row, p
MATCH (e:Embarked { city: row.embarked })
CREATE (p)-[:EMBARKED_FROM]->(e)

WITH max(1) AS dummy // Update Embarked labels
MATCH (e:Embarked)
SET e.city = CASE WHEN e.city = "S" THEN "Southampton"
	WHEN e.city = "Q" THEN "Queenstown"
    WHEN e.city = "C" THEN "Cherbourg" END;

WITH max(1) AS dummy // Lifeboat nodes
LOAD CSV WITH HEADERS
FROM "file:///titanic_clean.csv" AS row
WITH row, split(row.boat, ' ') as boats
UNWIND boats AS boat
WITH DISTINCT boat AS boat
CREATE (l:Lifeboat { lifeboat: boat })

WITH max(1) AS dummy // (Passenger)-[:BOARDED]->(Lifeboat)
LOAD CSV WITH HEADERS
FROM "file:///titanic_clean.csv" AS row
WITH row.name as name, split(row.boat, ' ') as boats
UNWIND boats AS boat
MATCH (p:Passenger { name: name })
WITH DISTINCT boat as lifeboat, p
MATCH (l:Lifeboat { lifeboat: lifeboat })
CREATE (p)-[:BOARDED]->(l)

WITH max(1) AS dummy // Update Lifeboat labels
MATCH (l:Lifeboat)
SET l.lifeboat =  "Lifeboat " + l.lifeboat

// Returns distinct destinations, needs to be parsed and cleaned
// to avoid duplicate destinations
LOAD CSV WITH HEADERS
FROM "file:///titanic_clean.csv" AS row
WITH DISTINCT split(row.`home.dest`, ' / ') AS destinations
UNWIND destinations as destination
WITH DISTINCT trim(destination) as dest
RETURN DISTINCT dest ORDER BY dest

// remove "? "
// split "Asarum, Sweden Brooklyn, NY"
// split "Aughnacliff, Co Longford, Ireland New York, NY"
// split "Austria Niagara Falls, NY"
// add "NI" to "Belfast"
// split "Belgium Montreal, PQ" and "Belgium Detroit, MI"
// split "Birkdale, England Cleveland, Ohio"
// "Bournemouth, England Newark, NJ"
// resolve "Bournmouth, England" and "Bournemouth, England"
// split "Brennes, Norway New York"
// split "Bristol, England Cleveland, OH"
// resolve "Bryn Mawr, PA, USA" and "Bryn Mawr, PA"
// split "Bulgaria Chicago, IL" and "Bulgaria Chicago, IL"
// resolve "Chicago, IL" and "Chicago"
// split "Co Athlone, Ireland New York, NY", "Co Clare, Ireland Washington, DC",
//     "Co Cork, Ireland Charlestown, MA", "Co Cork, Ireland Roxbury, MA", 
//     "Co Limerick, Ireland Sherbrooke, PQ", "Co Longford, Ireland New York, NY", 
//     "Co Sligo, Ireland Hartford, CT", "Co Sligo, Ireland New York, NY"
// split "Cornwall, England Houghton, MI"
// split "Dagsas, Sweden Fower, MN"
// split "Devon, England Wichita, KS"
// split "England Albion, NY", "England Brooklyn, NY", "England New York, NY", "England Oglesby, IL",
//     "England Salt Lake City, Utah"
// split "Finland Sudbury, ON"
// split "Foresvik, Norway Portland, ND", split "Goteborg, Sweden Huntley, IL"
// split "Helsinki, Finland Ashtabula, Ohio"
// split "Hong Kong New York, NY"
// split "Ireland Brooklyn, NY",  "Ireland Chicago, IL", "Ireland New York, NY", "Ireland Philadelphia, PA"
// split "Italy Philadelphia, PA"
// split "Karberg, Sweden Jerome Junction, AZ"
// split "Kilmacowen, Co Sligo, Ireland New York, NY"
// split "Kingwilliamstown, Co Cork, Ireland Glens Falls, NY"
// split "Kingwilliamstown, Co Cork, Ireland New York, NY"
// split "Kingwilliamstown, Co Cork, Ireland New York, NY"
// split "Liverpool, England Bedford, OH"
// split "London Vancouver, BC"
// split "London Brooklyn, NY"
// split "London New York, NY"
// split "London Skanteales, NY"
// resolve "London, England", "London"
// split "London, England Norfolk, VA"
// resolve "Lower Clapton, Middlesex or Erdington, Birmingham", "Marietta, Ohio and Milwaukee, WI"
// split "Medeltorp, Sweden Chicago, IL"

replace Ohio with OH
replace Guernsey with Guernsey, England


///END TITANIC

// BEGIN EXAMPLE FROM PREVIOUS PROJECT

LOAD CSV WITH HEADERS // User
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=1801331028' AS profile_line
CREATE (user:User {
    userId: profile_line.userId,
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
CREATE (user)-[rel:IS_TAGGED_IN]->(image)
SET rel.userTaggedDate = date(), rel.taggedByUser = '(userHandle)';

WITH max(1) AS dummy // Comment nodes
LOAD CSV WITH HEADERS
FROM 'https://docs.google.com/spreadsheets/d/1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg/export?format=csv&id=1cuv7D-urC6ZZsulGfmNuDpbWdnIQ_pfbWK2SPVCJGpg&gid=451905057' AS row
MERGE (comment:Comment { 
	commentId: row.commentId,
    commentUserId: row.commentUserId,
    commentDate: date(),
    commentBody: row.commentBody,
    commentType: row.commentType,
    commentLang: row.commentLang,
    commentLikes: toInt(round(rand()*100)),
    projectId: row.projectId
    });

// (Comment)-[:ABOUT]->(Project)
MATCH (c:Comment), (p:Project)
WHERE c.projectId = p.projectId
CREATE (c)-[rel:ABOUT]->(p);

// (User)-[:POSTED]->(Comment)
MATCH (u:User), (c:Comment)
WHERE u.userId = c.commentUserId
CREATE (u)-[rel:POSTED]->(c)
SET rel.postedDate = c.commentDate, c.commentAuthor = u.userHandle;