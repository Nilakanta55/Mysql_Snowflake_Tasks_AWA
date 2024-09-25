-- o	Create another database named SchoolDB
CREATE DATABASE SCHOOL_DB;
USE SCHOOL_DB;

CREATE TABLE STUDENTS (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DateOfBirth DATE,
    EnrollmentDate DATE,
    Major VARCHAR(50)
);

load data local infile "C:/NewN/AWA/2 Snowflake/Assignment/A1/Students.csv"
into table STUDENTS 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

SELECT count(*) FROM STUDENTS;

-- 4 Primary Key and Foreign Key Constraints
-- iv. Enforce Referential Integrity:
-- o Add a foreign key constraint to the Students table, linking the Major column to a hypothetical Majors table that contains all valid majors offered by the school.
-- Create the Majors table:
CREATE TABLE Major(
	MajorID INT PRIMARY KEY,
    MajorName VARCHAR(100) NOT NULL
    );
-- Add the foreign key constraint
ALTER TABLE Students
ADD CONSTRAINT FK_Major
FOREIGN KEY (Major)
REFERENCES Majors(MajorID);

-- Update invalid date values in EnrollmentDate
UPDATE Students
SET EnrollmentDate = '2000-01-01'
WHERE EnrollmentDate = '0000-00-00';

-- Alter DateOfBirth column to VARCHAR
ALTER TABLE Students
MODIFY COLUMN DateOfBirth VARCHAR(50);


-- o Add a check constraint to the Students table to ensure that the EnrollmentDate is not earlier than 2000-01-01.
-- message indicates that there is an issue with the DateOfBirth column in one of the rows, where it has an invalid date value of '0000-00-00'. This is causing the check constraint to fail.
-- To resolve this, you need to update the invalid date values in the DateOfBirth column before adding the check constraint.
-- Update invalid DateOfBirth values: This sets the invalid DateOfBirth values to a valid date.
UPDATE Students
SET DateOfBirth = '2000-01-01'
WHERE DateOfBirth = '0000-00-00';

ALTER TABLE Students
ADD CONSTRAINT chk_EnrollmentDate_NotBefore2000
CHECK (EnrollmentDate >= '2000-01-01');

-- 7. Composite Keys and Indexes
-- 1. Composite Primary Key:
-- o  Create a composite primary key on the combination of FirstName and LastName in the Students table (assuming StudentID is no longer the primary key).
-- Drop the existing primary key
ALTER TABLE Students
DROP PRIMARY KEY;
-- Add the composite primary key
ALTER TABLE Students
ADD PRIMARY KEY (FirstName, LastName);

-- o Rename the Major column in the Students table to Course to better reflect the data it stores.
ALTER TABLE Students
RENAME COLUMN Major TO Course;
-- verify
DESCRIBE Students;

-- o Change the default value for the EnrollmentDate in the Students table to the current date.
ALTER TABLE Students
MODIFY COLUMN EnrollmentDate DATETIME DEFAULT 
CURRENT_TIMESTAMP;

-- o  For all students who enrolled before 2020-01-01, change their Course to 'Alumni'.
INSERT INTO major (MajorID, MajorName)
VALUES (1,'Alumni');

UPDATE Students
SET Course = 1
WHERE EnrollmentDate < '2020-01-01';

-- 3. iii.	Add and Drop Indexes:
-- To add an index on the EnrollmentDate column in the Students table
CREATE INDEX idx_EnrollmentDate
ON Students (EnrollmentDate);

-- To verify that the index on the EnrollmentDate column in the Students table has been added
SELECT INDEX_NAME, TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_NAME = 'Students' AND COLUMN_NAME = 'EnrollmentDate';

-- You can also monitor the usage of the index over time to ensure it is being utilized effectively.
SHOW INDEX FROM Students WHERE Column_name = 'EnrollmentDatee';
-- Use the EXPLAIN statement to see the query execution plan. you can compare the performance of a query that uses the EnrollmentDate column
EXPLAIN SELECT * FROM Students WHERE EnrollmentDate = '2024-09-10';

-- o  Add a column Graduated (BOOLEAN) to the Students table, then update this column to TRUE for all students whose Course is 'Alumni'.
-- Add the Graduated column
ALTER TABLE Students
ADD COLUMN Graduated BOOLEAN DEFAULT FALSE;

-- Update the Graduated column to TRUE for students whose Course is ‘Alumni’
UPDATE STUDENTS
SET Graduated = TRUE
WHERE Course = 'Alumni';

-- verification Check the table structure
SHOW COLUMNS FROM Students LIKE 'Graduated';

-- Verify the updates. This query should return rows where the Graduated column is TRUE for students with the Course ‘Alumni’.
SELECT Course, Graduated
FROM Students
WHERE Course = 'Alumni';

-- 1 i. o  Remove the student from the Students table whose StudentID is 3.
DELETE FROM Students
WHERE StudentID = 3;
-- Run a SELECT query to check if the record exists
SELECT * FROM Students WHERE StudentID = 3;

-- o	Remove all students from the Students table who enrolled before 2019-01-01.
DELETE FROM Students
WHERE EnrollmentDate < '2019-01-01';
-- Verify
SELECT * FROM Students WHERE EnrollmentDate < '2019-01-01';

-- o	Remove all students from the Students table whose Course is 'History' and who enrolled before 2021-01-01.
DELETE FROM Students
WHERE Course = 'History' AND EnrollmentDate < '2021-01-01';
-- Run a SELECT query to check the affected rows
SELECT * FROM Students
WHERE Course = 'History' AND EnrollmentDate < '2021-01-01';

-- o	Remove all students from the Students table if there is no record of their major in a hypothetical Majors table
DELETE FROM Students
WHERE MajorID NOT IN (SELECT MajorID FROM Major);

-- o	Remove a course from the Courses table (hypothetical) and ensure all students enrolled in that course are also removed.
-- Create the Tables with Foreign Key Constraint: Ensure your Enrollments table has a foreign key that references the Courses table with the ON DELETE CASCADE option.
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100));

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentName VARCHAR(100),
    CourseID INT,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE);
-- CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100)
);

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentName VARCHAR(100),
    CourseID INT,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);

-- Insert Sample Data: Insert some sample data into both tables
INSERT INTO Courses (CourseID, CourseName) VALUES (1, 'Math'), (2, 'Science');

INSERT INTO Enrollments (EnrollmentID, StudentName, CourseID) VALUES 
(1, 'Mani', 1),
(2, 'Vikas', 1),
(3, 'Virat', 2);

-- Verify Data Insertion: Check that the data has been inserted correctly.
SELECT * FROM Courses;
SELECT * FROM Enrollments;

-- Delete a Course: Delete a course and verify that related enrollments are also deleted.
DELETE FROM Courses WHERE CourseID = 1;

-- Verify Deletion: Check the Enrollments table to ensure that students enrolled in the deleted course are also removed.
SELECT * FROM Enrollments;

-- o	Attempt to delete a student from the Students table if they are referenced in another table, such as a Grades table (hypothetical).
CREATE TABLE Students (
    id INT PRIMARY KEY,
    name VARCHAR(100));

CREATE TABLE Grades (
    id INT PRIMARY KEY,
    student_id INT,
    grade CHAR(1),
    FOREIGN KEY (student_id) REFERENCES Students(id) ON DELETE CASCADE);
    
-- Delete related records in Grades table
DELETE FROM Grades WHERE student_id = 1;

-- Now delete the student from Students table
DELETE FROM Students WHERE id = 1;

-- Update related records in Grades table
UPDATE Grades SET student_id = NULL WHERE student_id = 1;

-- Now delete the student from Students table
DELETE FROM Students WHERE id = 1;

-- Delete the student from Students table
DELETE FROM Students WHERE id = 1;

-- o Remove all records from the Students table where the Course is 'Art'.
DELETE FROM Students WHERE Course = 'Art';

-- o Remove all students from the Students table where the EnrollmentDate is NULL
DELETE FROM Students WHERE EnrollmentDate IS NULL;

-- o Remove students from the Students table who enrolled after the latest enrollment date in the table
DELETE FROM Students
WHERE EnrollmentDate > (SELECT max_enrollment_date FROM (
        SELECT MAX(EnrollmentDate) AS max_enrollment_date FROM Students) AS temp
);

use school_db;



-- iv) Drop Tables and Database:
-- o Drop the Students table from SchoolDB.
-- o Drop the SchoolDB database.