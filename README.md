RaceDay Event Management System
1. Project Overview

RaceDay is an Event Management System designed to manage running events and the people involved in them. The system provides functionality for managing users, organisers, participants, events, event categories, enrolments, and race results.

The project consists of a relational database implemented in Microsoft SQL Server together with a REST API that provides access to the main system functionality.

The database is designed to maintain data integrity through the use of primary keys, foreign keys, unique constraints, and validation rules. The SQL implementation also includes sample data and verification queries.

2. Project Objectives

The main objectives of the RaceDay system are to:

Allow users to register and authenticate.
Manage participant and organiser profiles.
Allow organisers to create and manage running events.
Manage event categories and age requirements.
Allow categories to be associated with events.
Allow participants to enrol in event categories.
Assign unique race numbers to participants.
Record and retrieve race results.
Enforce appropriate access based on user roles.
Maintain accurate and consistent data using database constraints.
Provide a structured REST API for communication with the system.
3. Main System Features
User Management
User registration
User login
JWT authentication
User profile management
User roles
Active/inactive account status
Event Management
Create events
View all events
View individual event details
Update events
Delete events
Track event status
Associate events with organisers
Category Management
Create categories
View categories
Update categories
Delete categories
Define minimum and maximum age requirements
Set entry fees
Set maximum participant capacity
Participant Enrolment
Enrol participants into event categories
Generate race numbers
Track enrolment status
Prevent duplicate enrolments
Validate category capacity
Validate participant age
Cancel enrolments
Results Management
Record race results
Record finishing position
Record finishing time
Track result status
Retrieve individual results
Display event results publicly
4. Database Design

The RaceDay database is called:

RaceDay

The database contains the following eight main tables:

Table	Purpose
Users	Stores user account information and roles
Organisers	Stores organiser profiles
Participants	Stores participant information
Events	Stores running event information
Categories	Stores available race categories
EventCategories	Links events with their categories
Enrolments	Stores participant enrolments
Results	Stores race results

The SQL script creates the database, tables, relationships, constraints, sample data, and verification queries.

5. Entity Relationship Diagram

The Entity Relationship Diagram represents the structure of the RaceDay database and shows how the entities are connected.

The main relationships include:

Users
 ├── Organisers
 │      └── Events
 │             └── EventCategories
 │                    └── Categories
 │
 └── Participants
        └── Enrolments
               └── Results

The EventCategories table is used to resolve the many-to-many relationship between Events and Categories.

ERD

The complete database design is available in:

ERD.PNG
6. Database Relationships
Users → Organisers

An organiser profile is associated with a user through UserID.

Users.UserID
      ↓
Organisers.UserID
Users → Participants

A participant profile is associated with a user through UserID.

Users.UserID
      ↓
Participants.UserID
Organisers → Events

An organiser can create events.

Organisers.OrganiserID
          ↓
Events.OrganiserID
Events ↔ Categories

An event can offer multiple categories, while a category can be available at multiple events.

Events
   ↓
EventCategories
   ↑
Categories
Participants → Enrolments

Participants enrol in event categories through the Enrolments table.

Enrolments → Results

A participant's race result is linked to their enrolment through EnrolmentID.

7. Data Integrity

The database uses several constraints to ensure that incorrect or duplicate data is not stored.

Primary Keys

Each main entity has a primary key, including:

UserID
OrganiserID
ParticipantID
EventID
CategoryID
EnrolmentID
ResultID

The EventCategories table uses a composite primary key consisting of:

EventID + CategoryID
Foreign Keys

Foreign keys maintain relationships between the tables.

Examples include:

Organisers.UserID → Users.UserID
Participants.UserID → Users.UserID
Events.OrganiserID → Organisers.OrganiserID
Enrolments.ParticipantID → Participants.ParticipantID
Results.EnrolmentID → Enrolments.EnrolmentID
Unique Constraints

The system also prevents duplicate information such as:

Duplicate email addresses
Duplicate category names
Duplicate race numbers
Duplicate participant/event/category enrolments
Multiple results for the same enrolment
Check Constraints

Validation rules are also implemented for important fields, including:

User roles
Event statuses
Category age ranges
Entry fees
Maximum entries
Enrolment statuses
Result positions
Result statuses
8. User Roles

The RaceDay system supports three main roles:

Role	Description
Participant	Can manage their profile, enrol in events and access their results
Organiser	Can create and manage events, categories, enrolments and results
Admin	Has administrative privileges, including category management

Role-based access helps ensure that users can only perform actions appropriate to their responsibilities.

9. REST API

The RaceDay REST API provides endpoints for interacting with the system.

The API is organised into the following functional areas:

Authentication
User profiles
Events
Categories
Event categories
Enrolments
Results

The API documentation contains the HTTP methods, routes, roles, request bodies, expected responses, and status codes for the system endpoints.

10. Authentication API
Register User
POST /api/auth/register

Registers a new user and participant profile.

Example request:

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "password": "Password123!",
  "role": "PARTICIPANT",
  "dateOfBirth": "2000-05-10",
  "emergencyContactName": "Jane Doe",
  "emergencyContactNumber": "0821234567"
}

Successful registration returns:

201 Created
Login
POST /api/auth/login

Authenticates a user and returns a JWT token.

Example request:

{
  "email": "john@example.com",
  "password": "Password123!"
}

A successful response provides the authentication token, user ID and role.

11. User Profile API
Get Current User
GET /api/users/me

Returns information about the currently authenticated user.

Update Current User
PUT /api/users/me

Allows an authenticated user to update their profile information.

12. Event API
Create Event
POST /api/events

Role: Organiser

Creates a new running event.

Get All Events
GET /api/events

Returns a list of available events.

Get Event
GET /api/events/{eventId}

Returns details for a specific event.

Update Event
PUT /api/events/{eventId}

Allows an organiser to update an event they own.

Delete Event
DELETE /api/events/{eventId}

Deletes an event when it is permitted by the system rules.

13. Category API
Create Category
POST /api/categories

Role: Organiser/Admin

Creates a new event category.

Example:

{
  "categoryName": "10 KM Open",
  "description": "10 kilometre open category",
  "minimumAge": 18,
  "maximumAge": 60
}
Get Categories
GET /api/categories

Returns all available categories.

Get Category
GET /api/categories/{categoryId}

Returns details for a specific category.

Update Category
PUT /api/categories/{categoryId}

Updates an existing category.

Delete Category
DELETE /api/categories/{categoryId}

Deletes a category when it is not restricted by existing event associations.

14. Event Category API

Organisers can associate categories with events.

Add Category to Event
POST /api/events/{eventId}/categories

Example request:

{
  "categoryId": 2,
  "entryFee": 250.00,
  "maximumEntries": 500
}
View Event Categories
GET /api/events/{eventId}/categories

Returns the categories offered by a specific event.

Remove Category
DELETE /api/events/{eventId}/categories/{categoryId}

Removes a category from an event when no existing enrolments prevent the operation.

15. Enrolment API

Participants can enrol in an event category using:

POST /api/events/{eventId}/categories/{categoryId}/enrolments

The system validates:

Event existence
Category existence
Participant eligibility
Age requirements
Category capacity
Duplicate enrolments

A successful enrolment creates an enrolment record and race number.

View My Enrolments
GET /api/enrolments/me

Returns the current participant's enrolments.

View Event Enrolments
GET /api/events/{eventId}/enrolments

Allows an organiser to view enrolments for their event.

View Enrolment
GET /api/enrolments/{enrolmentId}

Returns details of an individual enrolment.

Cancel Enrolment
DELETE /api/enrolments/{enrolmentId}

Allows a participant to cancel an eligible enrolment.

16. Results API

Organisers can record race results using:

POST /api/enrolments/{enrolmentId}/result

Example request:

{
  "position": 12,
  "finishTime": "01:24:35",
  "resultStatus": "FINISHED"
}

A result contains:

Result ID
Enrolment ID
Position
Finish Time
Result Status
Get Enrolment Result
GET /api/enrolments/{enrolmentId}/result
Get Event Results
GET /api/events/{eventId}/results

The event results endpoint allows results to be retrieved for an event.

17. HTTP Status Codes

The API uses HTTP status codes to communicate the result of requests.

Status Code	Meaning
200	Request completed successfully
201	Resource successfully created
204	Request completed with no response body
400	Invalid request
401	Authentication required or failed
403	User is not authorised
404	Requested resource does not exist
409	Request conflicts with existing data or business rules
18. Sample Data

The SQL database includes sample data to allow the system to be tested.

Sample Events
Cape Town Summer Run
Johannesburg City Challenge
Durban Coastal Run
Sample Categories
5K Run
10K Run
21K Half Marathon
42K Marathon

The sample data also includes organisers, participants, event-category associations, enrolments and race results.

19. Technologies Used
Technology	Purpose
Microsoft SQL Server	Database management
SQL	Database implementation
SQL Server Management Studio (SSMS)	Database development and testing
REST API	Communication between application components
JSON	API request and response format
JWT	Authentication
ERD	Database modelling
20. Installation and Setup
Step 1: Clone or Download the Project

Obtain the RaceDay project files and open the project in your development environment.

Step 2: Open SQL Server Management Studio

Open SQL Server Management Studio (SSMS) and connect to your SQL Server instance.

Step 3: Open the SQL Script

Open:

SQL/RaceDay.sql
Step 4: Execute the Script

Run the complete SQL script.

The script will:

Create the RaceDay database if it does not exist.
Select the RaceDay database.
Remove existing development tables when appropriate.
Create the required tables.
Create primary and foreign keys.
Create unique and check constraints.
Insert sample data.
Execute verification queries.
Step 5: Verify the Database

Run the supplied verification queries and confirm that the tables contain the expected records.

21. Database Verification

The SQL script contains verification queries for all major tables:

SELECT * FROM Users;
SELECT * FROM Organisers;
SELECT * FROM Participants;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM EventCategories;
SELECT * FROM Enrolments;
SELECT * FROM Results;

A join query is also provided to verify that event, category, participant, enrolment and result information can be retrieved together.

22. Testing

The system should be tested using both valid and invalid scenarios.

Database Testing
Confirm database creation.
Confirm all eight tables exist.
Verify primary keys.
Verify foreign keys.
Verify unique constraints.
Verify check constraints.
Verify sample data.
Test relationships between tables.
API Testing
Test successful user registration.
Test successful login.
Test invalid login credentials.
Test profile retrieval and updating.
Test event creation.
Test event retrieval.
Test event updating and deletion.
Test category management.
Test event-category associations.
Test participant enrolment.
Test duplicate enrolment prevention.
Test age restrictions.
Test category capacity.
Test enrolment cancellation.
Test result creation.
Test result retrieval.
Test role-based authorisation.
Verify appropriate HTTP status codes.
23. Project Deliverables

The project contains the following main deliverables:

RaceDay/
│
├── README.md
│
├── ERD.PNG
│
├── SQL/
│   └── RaceDay.sql
│
├── API/
│   └── API-Documentation.pdf
│
└── Presentation/
    └── RaceDay-Presentation.pptx
ERD

ERD.PNG

Contains the Entity Relationship Diagram and shows the database entities, attributes, keys and relationships.

SQL

SQL/RaceDay.sql

Contains the complete SQL Server database implementation, including database creation, tables, constraints, sample data and verification queries.

API Documentation

API/API-Documentation.pdf

Contains the REST API endpoints, HTTP methods, roles, request bodies, responses and status codes.

Presentation

Presentation/RaceDay-Presentation.pptx

Contains the project presentation and is maintained as a separate deliverable from this README.

24. Conclusion

The RaceDay Event Management System provides a structured solution for managing running events from user registration and participant enrolment through to the recording and retrieval of race results.

The relational database separates the system into logical entities while using primary keys, foreign keys, unique constraints and validation rules to maintain data integrity. The REST API provides a structured interface for authentication, profile management, event management, category management, enrolments and results.

Overall, the project demonstrates the application of database design, relational modelling, SQL, REST API design, authentication, validation, role-based access control and system testing to develop a practical Event Management System.# RacwDay


