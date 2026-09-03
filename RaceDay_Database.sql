/* ============================================================

   RaceDay Database

   Part 1 - Section C: SQL Database Script

   Microsoft SQL Server / SSMS

   ============================================================ */
 
-- ------------------------------------------------------------

-- Create Database

-- ------------------------------------------------------------
 
IF DB_ID('RaceDay') IS NULL

BEGIN

    CREATE DATABASE RaceDay;

END;

GO
 
USE RaceDay;

GO
 
-- ------------------------------------------------------------

-- Drop existing tables so the script can be re-run during

-- development/testing.

-- ------------------------------------------------------------
 
DROP TABLE IF EXISTS Results;

DROP TABLE IF EXISTS Enrolments;

DROP TABLE IF EXISTS EventCategories;

DROP TABLE IF EXISTS Events;

DROP TABLE IF EXISTS Categories;

DROP TABLE IF EXISTS Participants;

DROP TABLE IF EXISTS Organisers;

DROP TABLE IF EXISTS Users;

GO
 
-- ============================================================

-- USERS

-- ============================================================
 
CREATE TABLE Users

(

    UserID INT IDENTITY(1,1) NOT NULL,

    FirstName NVARCHAR(50) NOT NULL,

    LastName NVARCHAR(50) NOT NULL,

    Email NVARCHAR(255) NOT NULL,

    PasswordHash NVARCHAR(255) NOT NULL,

    Role NVARCHAR(20) NOT NULL

        CONSTRAINT DF_Users_Role DEFAULT ('Participant'),

    IsActive BIT NOT NULL

        CONSTRAINT DF_Users_IsActive DEFAULT (1),

    CreatedAt DATETIME2 NOT NULL

        CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSDATETIME()),
 
    CONSTRAINT PK_Users PRIMARY KEY (UserID),
 
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
 
    CONSTRAINT CK_Users_Role

        CHECK (Role IN ('Participant', 'Organiser', 'Admin'))

);

GO
 
-- ============================================================

-- ORGANISERS

-- ============================================================
 
CREATE TABLE Organisers

(

    OrganiserID INT IDENTITY(1,1) NOT NULL,

    UserID INT NOT NULL,

    OrganisationName NVARCHAR(150) NOT NULL,

    ContactNumber NVARCHAR(30) NULL,
 
    CONSTRAINT PK_Organisers PRIMARY KEY (OrganiserID),
 
    CONSTRAINT UQ_Organisers_UserID UNIQUE (UserID),
 
    CONSTRAINT FK_Organisers_Users

        FOREIGN KEY (UserID)

        REFERENCES Users(UserID)

        ON DELETE CASCADE

);

GO
 
-- ============================================================

-- PARTICIPANTS

-- ============================================================
 
CREATE TABLE Participants

(

    ParticipantID INT IDENTITY(1,1) NOT NULL,

    UserID INT NOT NULL,

    DateOfBirth DATE NOT NULL,

    EmergencyContactName NVARCHAR(100) NOT NULL,

    EmergencyContactNumber NVARCHAR(30) NOT NULL,
 
    CONSTRAINT PK_Participants PRIMARY KEY (ParticipantID),
 
    CONSTRAINT UQ_Participants_UserID UNIQUE (UserID),
 
    CONSTRAINT FK_Participants_Users

        FOREIGN KEY (UserID)

        REFERENCES Users(UserID)

        ON DELETE CASCADE

);

GO
 
-- ============================================================

-- EVENTS

-- ============================================================
 
CREATE TABLE Events

(

    EventID INT IDENTITY(1,1) NOT NULL,

    OrganiserID INT NOT NULL,

    EventName NVARCHAR(150) NOT NULL,

    Description NVARCHAR(500) NULL,

    EventDate DATE NOT NULL,

    Location NVARCHAR(200) NOT NULL,

    Status NVARCHAR(20) NOT NULL

        CONSTRAINT DF_Events_Status DEFAULT ('Open'),
 
    CONSTRAINT PK_Events PRIMARY KEY (EventID),
 
    CONSTRAINT FK_Events_Organisers

        FOREIGN KEY (OrganiserID)

        REFERENCES Organisers(OrganiserID),
 
    CONSTRAINT CK_Events_Status

        CHECK (Status IN ('Draft', 'Open', 'Closed', 'Cancelled')),
 
    CONSTRAINT CK_Events_Date

        CHECK (EventDate >= '2020-01-01')

);

GO
 
-- ============================================================

-- CATEGORIES

-- ============================================================
 
CREATE TABLE Categories

(

    CategoryID INT IDENTITY(1,1) NOT NULL,

    CategoryName NVARCHAR(100) NOT NULL,

    Description NVARCHAR(300) NULL,

    MinimumAge INT NOT NULL

        CONSTRAINT DF_Categories_MinimumAge DEFAULT (16),

    MaximumAge INT NULL,
 
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
 
    CONSTRAINT UQ_Categories_CategoryName UNIQUE (CategoryName),
 
    CONSTRAINT CK_Categories_MinimumAge

        CHECK (MinimumAge >= 0),
 
    CONSTRAINT CK_Categories_MaximumAge

        CHECK (MaximumAge IS NULL OR MaximumAge >= MinimumAge)

);

GO
 
-- ============================================================

-- EVENT CATEGORIES

-- Resolves the many-to-many relationship between Events

-- and Categories.

-- ============================================================
 
CREATE TABLE EventCategories

(

    EventID INT NOT NULL,

    CategoryID INT NOT NULL,

    EntryFee DECIMAL(10,2) NOT NULL,

    MaximumEntries INT NOT NULL,
 
    CONSTRAINT PK_EventCategories

        PRIMARY KEY (EventID, CategoryID),
 
    CONSTRAINT FK_EventCategories_Events

        FOREIGN KEY (EventID)

        REFERENCES Events(EventID)

        ON DELETE CASCADE,
 
    CONSTRAINT FK_EventCategories_Categories

        FOREIGN KEY (CategoryID)

        REFERENCES Categories(CategoryID),
 
    CONSTRAINT CK_EventCategories_EntryFee

        CHECK (EntryFee >= 0),
 
    CONSTRAINT CK_EventCategories_MaximumEntries

        CHECK (MaximumEntries > 0)

);

GO
 
-- ============================================================

-- ENROLMENTS

-- ============================================================
 
CREATE TABLE Enrolments

(

    EnrolmentID INT IDENTITY(1,1) NOT NULL,

    EventID INT NOT NULL,

    CategoryID INT NOT NULL,

    ParticipantID INT NOT NULL,

    EnrolledAt DATETIME2 NOT NULL

        CONSTRAINT DF_Enrolments_EnrolledAt DEFAULT (SYSDATETIME()),

    Status NVARCHAR(20) NOT NULL

        CONSTRAINT DF_Enrolments_Status DEFAULT ('Confirmed'),

    RaceNumber NVARCHAR(20) NOT NULL,
 
    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentID),
 
    CONSTRAINT UQ_Enrolments_RaceNumber UNIQUE (RaceNumber),
 
    CONSTRAINT UQ_Enrolments_Participant_Event_Category

        UNIQUE (EventID, CategoryID, ParticipantID),
 
    CONSTRAINT FK_Enrolments_EventCategory

        FOREIGN KEY (EventID, CategoryID)

        REFERENCES EventCategories(EventID, CategoryID),
 
    CONSTRAINT FK_Enrolments_Participants

        FOREIGN KEY (ParticipantID)

        REFERENCES Participants(ParticipantID),
 
    CONSTRAINT CK_Enrolments_Status

        CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled'))

);

GO
 
-- ============================================================

-- RESULTS

-- ============================================================
 
CREATE TABLE Results

(

    ResultID INT IDENTITY(1,1) NOT NULL,

    EnrolmentID INT NOT NULL,

    Position INT NULL,

    FinishTime TIME(0) NULL,

    ResultStatus NVARCHAR(20) NOT NULL

        CONSTRAINT DF_Results_ResultStatus DEFAULT ('Finished'),
 
    CONSTRAINT PK_Results PRIMARY KEY (ResultID),
 
    CONSTRAINT UQ_Results_EnrolmentID UNIQUE (EnrolmentID),
 
    CONSTRAINT FK_Results_Enrolments

        FOREIGN KEY (EnrolmentID)

        REFERENCES Enrolments(EnrolmentID)

        ON DELETE CASCADE,
 
    CONSTRAINT CK_Results_Position

        CHECK (Position IS NULL OR Position > 0),
 
    CONSTRAINT CK_Results_Status

        CHECK (ResultStatus IN ('Finished', 'DidNotFinish', 'Disqualified'))

);

GO
 
-- ============================================================

-- SAMPLE USERS

-- ============================================================
 
INSERT INTO Users

    (FirstName, LastName, Email, PasswordHash, Role)

VALUES

    ('Sarah', 'Mokoena', 'sarah.mokoena@raceday.test',

     'HASH_SARAH_123', 'Organiser'),
 
    ('David', 'Naidoo', 'david.naidoo@raceday.test',

     'HASH_DAVID_123', 'Organiser'),
 
    ('Thabo', 'Dlamini', 'thabo.dlamini@raceday.test',

     'HASH_THABO_123', 'Participant'),
 
    ('Lerato', 'Molefe', 'lerato.molefe@raceday.test',

     'HASH_LERATO_123', 'Participant'),
 
    ('Admin', 'RaceDay', 'admin@raceday.test',

     'HASH_ADMIN_123', 'Admin');

GO
 
-- ============================================================

-- SAMPLE ORGANISERS

-- ============================================================
 
INSERT INTO Organisers

    (UserID, OrganisationName, ContactNumber)

VALUES

    (

        (SELECT UserID FROM Users

         WHERE Email = 'sarah.mokoena@raceday.test'),

        'Cape Active Events',

        '0215551001'

    ),

    (

        (SELECT UserID FROM Users

         WHERE Email = 'david.naidoo@raceday.test'),

        'Run South Africa',

        '0115552002'

    );

GO
 
-- ============================================================

-- SAMPLE PARTICIPANTS

-- ============================================================
 
INSERT INTO Participants

    (UserID, DateOfBirth, EmergencyContactName, EmergencyContactNumber)

VALUES

    (

        (SELECT UserID FROM Users

         WHERE Email = 'thabo.dlamini@raceday.test'),

        '1998-04-15',

        'Nomsa Dlamini',

        '0825553001'

    ),

    (

        (SELECT UserID FROM Users

         WHERE Email = 'lerato.molefe@raceday.test'),

        '2001-09-22',

        'Kabelo Molefe',

        '0835554002'

    );

GO
 
-- ============================================================

-- SAMPLE EVENTS

-- ============================================================
 
INSERT INTO Events

    (OrganiserID, EventName, Description, EventDate, Location, Status)

VALUES

    (

        (SELECT OrganiserID FROM Organisers

         WHERE OrganisationName = 'Cape Active Events'),

        'Cape Town Summer Run',

        'Annual road running event for recreational and competitive runners.',

        '2026-11-15',

        'Cape Town Stadium',

        'Open'

    ),

    (

        (SELECT OrganiserID FROM Organisers

         WHERE OrganisationName = 'Cape Active Events'),

        'Johannesburg City Challenge',

        'City road race suitable for runners of different abilities.',

        '2027-02-21',

        'Johannesburg CBD',

        'Open'

    ),

    (

        (SELECT OrganiserID FROM Organisers

         WHERE OrganisationName = 'Run South Africa'),

        'Durban Coastal Run',

        'Scenic coastal running event.',

        '2027-04-18',

        'Durban Golden Mile',

        'Open'

    );

GO
 
-- ============================================================

-- SAMPLE CATEGORIES

-- ============================================================
 
INSERT INTO Categories

    (CategoryName, Description, MinimumAge, MaximumAge)

VALUES

    ('5K Run', 'Five kilometre road race.', 12, NULL),

    ('10K Run', 'Ten kilometre road race.', 16, NULL),

    ('21K Half Marathon', 'Half marathon road race.', 18, NULL),

    ('42K Marathon', 'Full marathon road race.', 18, NULL);

GO
 
-- ============================================================

-- EVENT CATEGORIES

-- Each event receives multiple categories.

-- ============================================================
 
-- Cape Town Summer Run

INSERT INTO EventCategories

    (EventID, CategoryID, EntryFee, MaximumEntries)

VALUES

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Cape Town Summer Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '5K Run'),

        120.00,

        500

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Cape Town Summer Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '10K Run'),

        180.00,

        750

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Cape Town Summer Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '21K Half Marathon'),

        280.00,

        1000

    );
 
-- Johannesburg City Challenge

INSERT INTO EventCategories

    (EventID, CategoryID, EntryFee, MaximumEntries)

VALUES

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Johannesburg City Challenge'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '5K Run'),

        100.00,

        400

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Johannesburg City Challenge'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '10K Run'),

        160.00,

        600

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Johannesburg City Challenge'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '21K Half Marathon'),

        250.00,

        800

    );
 
-- Durban Coastal Run

INSERT INTO EventCategories

    (EventID, CategoryID, EntryFee, MaximumEntries)

VALUES

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Durban Coastal Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '5K Run'),

        100.00,

        500

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Durban Coastal Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '10K Run'),

        170.00,

        700

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Durban Coastal Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '21K Half Marathon'),

        270.00,

        900

    );

GO
 
-- ============================================================

-- SAMPLE ENROLMENTS

-- ============================================================
 
INSERT INTO Enrolments

    (EventID, CategoryID, ParticipantID, Status, RaceNumber)

VALUES

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Cape Town Summer Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '10K Run'),

        (SELECT ParticipantID FROM Participants

         WHERE UserID =

            (SELECT UserID FROM Users

             WHERE Email = 'thabo.dlamini@raceday.test')),

        'Confirmed',

        'CT-1001'

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Cape Town Summer Run'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '21K Half Marathon'),

        (SELECT ParticipantID FROM Participants

         WHERE UserID =

            (SELECT UserID FROM Users

             WHERE Email = 'lerato.molefe@raceday.test')),

        'Confirmed',

        'CT-2101'

    ),

    (

        (SELECT EventID FROM Events

         WHERE EventName = 'Johannesburg City Challenge'),

        (SELECT CategoryID FROM Categories

         WHERE CategoryName = '5K Run'),

        (SELECT ParticipantID FROM Participants

         WHERE UserID =

            (SELECT UserID FROM Users

             WHERE Email = 'thabo.dlamini@raceday.test')),

        'Confirmed',

        'JHB-5001'

    );

GO
 
-- ============================================================

-- SAMPLE RESULTS

-- ============================================================
 
INSERT INTO Results

    (EnrolmentID, Position, FinishTime, ResultStatus)

VALUES

    (

        (SELECT EnrolmentID FROM Enrolments

         WHERE RaceNumber = 'CT-1001'),

        15,

        '00:48:32',

        'Finished'

    ),

    (

        (SELECT EnrolmentID FROM Enrolments

         WHERE RaceNumber = 'CT-2101'),

        8,

        '01:52:14',

        'Finished'

    );

GO
 
-- ============================================================

-- VERIFICATION QUERIES

-- ============================================================
 
SELECT * FROM Users;

SELECT * FROM Organisers;

SELECT * FROM Participants;

SELECT * FROM Events;

SELECT * FROM Categories;

SELECT * FROM EventCategories;

SELECT * FROM Enrolments;

SELECT * FROM Results;

GO
 
-- ============================================================

-- USEFUL JOIN TO VERIFY THE DATABASE DESIGN

-- ============================================================
 
SELECT

    e.EventName,

    e.EventDate,

    e.Location,

    c.CategoryName,

    p.ParticipantID,

    u.FirstName + ' ' + u.LastName AS ParticipantName,

    en.RaceNumber,

    en.Status AS EnrolmentStatus,

    r.Position,

    r.FinishTime,

    r.ResultStatus

FROM Enrolments en

INNER JOIN Events e

    ON en.EventID = e.EventID

INNER JOIN Categories c

    ON en.CategoryID = c.CategoryID

INNER JOIN Participants p

    ON en.ParticipantID = p.ParticipantID

INNER JOIN Users u

    ON p.UserID = u.UserID

LEFT JOIN Results r

    ON en.EnrolmentID = r.EnrolmentID

ORDER BY e.EventDate, c.CategoryName, r.Position;

GO

 