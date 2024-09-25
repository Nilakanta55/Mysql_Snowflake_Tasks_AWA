
-- 1. Database Creation and Table Creation (DDL)
-- i). Create a Database:
-- o Create a database named CompanyDB.
create database COMPANY_DB;
use COMPANY_DB;

-- ii).	Create Tables
-- o In the CompanyDB database, create a table named Employees with the following columns
CREATE TABLE EMPLOYEES (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DateOfBirth VARCHAR(50),
    JobTitle VARCHAR(50),
    Salary DECIMAL(10, 2),
    DepartmentID INT,
    Email VARCHAR(50)
);
-- Loading data from local infile:
load data local infile "C:/NewN/AWA/2 Snowflake/Assignment/A1/Employees.csv"
into table EMPLOYEES 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- global variable setting On
show global variables like 'local_infile';
set global local_infile = 1;

-- checking no of records in employees table
select count(*) from employees;

-- o Create a table named Departments in CompanyDB with the following columns
CREATE TABLE DEPARTMENTS(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100)
);
-- Data preview
select * from departments;

-- iii). Modify Table Structure:
-- o Alter the Employees table to add a new column HireDate (DATE).
 
 ALTER TABLE Employees
 ADD HireDate DATE;

select * from Employees;

-- o Modify the Departments table to change the DepartmentName column's data type to VARCHAR(150).
ALTER TABLE Departments
MODIFY COLUMN DepartmentName VARCHAR(150);

-- 2. Data Insertion, Updating, and Deletion (DML)
-- i).	Insert Data:
-- o  Insert five records into the Employees table.
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, JobTitle, Salary, DepartmentID, Email)
VALUES
(1001, 'John', 'Doe', '1990-01-15', 'Software Engineer', 75000, 3, 'john.doe@example.com'),
(1002, 'Jane', 'Smith', '1985-06-30', 'Project Manager', 85000, 4, 'jane.smith@example.com'),
(1003, 'Emily', 'Johnson', '1992-03-10', 'Data Analyst', 70000, 3, 'emily.johnson@example.com'),
(1004, 'Michael', 'Brown', '1988-04-05', 'UX Designer', 72000, 1, 'michael.brown@example.com'),
(1005, 'Sarah', 'Davis', '1991-11-25', 'HR Specialist', 68000, 5, 'sarah.davis@example.com');

select count(*) from employees;

-- o  Insert three records into the Departments table.
INSERT INTO DEPARTMENTS (DepartmentID, DepartmentName)
VALUES
(6,'Consultant'),
(7, 'Finance'),
(8, 'IT');

-- ii).	Update Data:
-- o	Update the Salary of the employee with EmployeeID = 3 to 75000.
UPDATE Employees 
SET Salary = 75000
WHERE EmployeeID = 3;

SELECT * FROM Employees limit 10;   -- salary updated to 75000

-- o	Update the Position of all employees where Position is Intern to Junior Developer.
UPDATE Employees 
SET Position = 'Junior Developer'
WHERE Position = 'Intern';

SELECT * FROM Employees limit 100;

-- iii)	Delete Data:
-- o Delete the employee record with EmployeeID = 4.
DELETE FROM Employees
WHERE EmployeeID = 4;

SELECT * FROM Employees
WHERE EmployeeID = 4;

-- iv).	Complex Insert and Update:
-- o Insert a new employee, ensuring that their DepartmentID exists in the Departments table.
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, JobTitle, Salary, DepartmentID, Email)
SELECT 1006, 'Praveen', 'kali', '1994-07-19', 'Software Engineer', 
65000, 3, 'praveen.kali@yahoo.com'
WHERE EXISTS (SELECT 1 FROM Departments WHERE DepartmentID=3);

SELECT * FROM Employees 
WHERE EmployeeID = 1006;

-- o Update all employees who have NULL in the HireDate column to the current date.
UPDATE Employees
SET HireDate = CURDATE()
WHERE HireDate IS NULL;

SELECT * FROM Employees
WHERE HireDate = CURDATE();

-- 3. Data Selection and Filtering (DML)
-- i).	Select Data:
-- o  Select all columns from the Employees table.
SELECT * FROM Employees;

-- o  Select the FirstName, LastName, and Salary of all employees who have a salary greater than 60000.
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary > 60000;

-- ii).	Filtering and Sorting:
-- o  Select all employees from the Employees table who were hired after 2018-01-01.
SELECT * 
FROM Employees 
WHERE HireDate > '2018-01-01';

-- o Select all employees from the Employees table and order them by LastName in ascending order.
SELECT *
FROM Employees
ORDER BY LastName ASC;

-- iii). Aggregate Functions:
-- o  Count the total number of employees in the Employees table.
SELECT count(*) AS TotalEmployees
FROM Employees;

-- o  Calculate the average Salary of all employees.
SELECT AVG(Salary) AS AverageSalary
FROM Employees;

-- 4. Primary Key and Foreign Key Constraints
-- i. Enforce Uniqueness:
-- o  Ensure that the EmployeeID in the Employees table is unique and cannot be NULL
ALTER TABLE Employees
MODIFY EmployeeID INT NOT NULL,
ADD CONSTRAINT UC_EmployeeID UNIQUE (EmployeeID);

-- Check for NULL values:
SELECT *
FROM Employees
WHERE EmployeeID IS NULL;

-- Check for duplicate values
SELECT EmployeeID, COUNT(*)
FROM Employees
GROUP BY EmployeeID
HAVING COUNT(*) >1;

-- Check table constraints
SHOW CREATE TABLE Employees;

-- o  Ensure that each department in the Departments table has a unique DepartmentID that is also not NULL.
ALTER TABLE Departments
MODIFY DepartmentID INT NOT NULL,
ADD CONSTRAINT UC_DepartmentID UNIQUE (DepartmentID);

-- Check for NULL values:
SELECT *
FROM Departments
WHERE DepartmentID IS NULL;

-- Check for duplicate values:
SELECT DepartmentID, COUNT(*)
FROM Departments
GROUP BY DepartmentID
HAVING COUNT(*) > 1;

-- Check table constraints:
SHOW CREATE TABLE Departments;

-- ii).	Establish Relationships:
-- o	Modify the Employees table to add a DepartmentID column (if not already present) and create a foreign key relationship 
		-- between the Employees table and the Departments table on DepartmentID

-- Create a foreign key relationship between Employees and Departments:
-- Temporarily disable foreign key checks to perform bulk operations or data migrations.
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE Employees
ADD CONSTRAINT FK_Department
FOREIGN KEY (DepartmentID)
REFERENCES Departments(DepartmentID);


-- To check whether the modifications to the Employees table were successful,
-- Check if the DepartmentID column exists:
SHOW COLUMNS FROM Employees LIKE 'DepartmentID';

-- Verify the foreign key relationship
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES (9,'Construction');
SELECT * FROM Departments;

-- o  Ensure that the DepartmentID in the Employees table cannot have a value that does not exist in the Departments table.
-- This should fail if DepartmentID 99 does not exist in Departments table
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, JobTitle, Salary, DepartmentID, Email, HireDate)
VALUES (1008, 'Sham', 'Sundar', '1998-03-04', 'Software Engineer', 
87000, 99, 'sham.sundar@yahoo.com', NULL);


-- iii). Cascade on Delete:
-- o Modify the foreign key in the Employees table so that if a department is deleted from the Departments table, all employees associated with that department are also deleted.
ALTER TABLE Employees
DROP FOREIGN KEY FK_Department;

ALTER TABLE Employees
ADD CONSTRAINT FK_Department
FOREIGN KEY (DepartmentID)
REFERENCES Departments(DepartmentID)
ON DELETE CASCADE;

-- Delete the test record from the Departments table.
DELETE FROM Departments WHERE DepartmentID = 1;

-- Check the Employees table to ensure that the corresponding record has been deleted.
SELECT * FROM Employees WHERE DepartmentID =1;
use company_db;
-- 5 Unique and Not Null Constraints
-- i. Ensure Unique Values:
-- o Add a unique constraint on the FirstName and LastName combination in the Employees table, ensuring that no two employees can have the same first and last name combination.
ALTER TABLE Employees 
ADD CONSTRAINT unique_fullname
UNIQUE (FirstName, LastName);

-- This should succeed
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, JobTitle, Salary, DepartmentID, Email, HireDate)
VALUES (1009, 'Ram', 'pandey', '1999-10-10', 'Software Engineer', 
87000, 99, 'Ram.pandey@yahoo.com', NULL);

-- This should fail due to the unique constraint
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, JobTitle, Salary, DepartmentID, Email, HireDate)
VALUES (1009, 'Ram', 'pandey', '1999-10-10', 'Software Engineer', 
87000, 99, 'Ram.pandey@yahoo.com', NULL);

-- o Ensure that the DepartmentName in the Departments table is unique
ALTER TABLE Departments
ADD CONSTRAINT unique_departmentname
UNIQUE (DepartmentName);

UPDATE Departments
SET DepartmentID = 1 
WHERE DepartmentID IS NULL;

UPDATE Departments
SET DepartmentName = 'HR'
WHERE DepartmentID IS NULL;
SELECT * FROM DEPARTMENTS;

-- This should fail due to the unique constraint
INSERT INTO Departments (DepartmentID, DepartmentName)
VALUES (1, 'HR');

-- ii). Prevent NULL Values:
-- o  Modify the Employees table to ensure that the FirstName, LastName, DateOfBirth, and Salary columns cannot contain NULL values.
ALTER TABLE Employees
MODIFY FirstName VARCHAR(100) NOT NULL,
MODIFY LastName VARCHAR(100) NOT NULL,
MODIFY DateofBirth VARCHAR(100) NOT NULL,
MODIFY Salary DECIMAL(10,2) NOT NULL;

-- This should fail due to the NOT NULL constraint
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, JobTitle, Salary, DepartmentID, Email, HireDate)
VALUES (1010, NULL, 'pandey', '1999-10-10', 'Software Engineer', 
87000, 99, 'Ram.pandey@yahoo.com', NULL);

-- 6. Default and Check Constraints
-- i. Set Default Values:
-- o  Add a default value of 'Unknown' to the Position column in the Employees table, so if no position is specified, it will default to 'Unknown'.
ALTER TABLE Employees
MODIFY JobTitle VARCHAR(100) DEFAULT 'Unknown';

-- To verify that the default value is working, you can insert a record without specifying the JobTitle column:
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, Salary, DepartmentID, Email, HireDate)
VALUES (1012, 'Hemanth', 'shiva', '2001-10-10',
87080, 1, 'Hemanth.shiva@yahoo.com', NULL);

-- Check the inserted record
SELECT * FROM Employees WHERE EmployeeID = 1012;  -- The Position column for the inserted record should have the value ‘Unknown’.

-- o  Set a default value of '1000' for the Salary column in the Employees table.
ALTER TABLE Employees 
ALTER COLUMN Salary SET DEFAULT 1000;

-- To check whether the default value of ‘1000’ has been set for the Salary column in the Employees table,
SELECT COLUMN_NAME, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employees' AND COLUMN_NAME = 'Salary';

-- ii). Enforce Valid Data Ranges with CHECK:
-- o Add a check constraint to the Employees table that ensures the Salary is greater than 0.
ALTER TABLE Employees 
ADD CONSTRAINT chk_salary_positive
CHECK (Salary > 0);

-- To verify that the check constraint ensuring the Salary is greater than 0 has been added to the Employees table
SELECT CONSTRAINT_NAME, CHECK_CLAUSE
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE TABLE_NAME = 'Employees';   -- This query will return the names and conditions of all check constraints on the Employees table. Look for the constraint you added, which should have a CHECK_CLAUSE similar to (Salary > 0).

--  test the constraint by attempting to insert a row with a Salary value of 0 or less. If the constraint is working correctly, the database should reject this insertion:
INSERT INTO Employees (salary) VALUES (0);  -- This should fail
INSERT INTO Employees (salary) VALUES (-100)  -- This should also fail

-- o Add a check constraint to the Departments table to ensure that the DepartmentName is at least 3 characters long.
ALTER TABLE Departments
ADD CONSTRAINT chk_department_name_length
CHECK (CHAR_LENGTH(DepartmentName)>=2);

-- iii). Ensure Valid Date Values:
-- o Add a check constraint to the Employees table to ensure that the HireDate is not in the future.
DELIMITER //

CREATE TRIGGER trg_CheckHireDate_Update
BEFORE UPDATE ON Employees
FOR EACH ROW
BEGIN
    IF NEW.HireDate > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'HireDate cannot be in the future';
    END IF;
END; //

DELIMITER ;

-- To verify that the trigger is working correctly, you can perform a couple of tests by attempting to insert or update records in the Employees table with both valid and invalid HireDate values. 
-- Here’s how you can do it: Test with a valid HireDate (not in the future): This should succeed without any errors.
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, Salary, DepartmentID, Email, HireDate)
VALUES (1013, 'Robin', 'Uttappa', '2001-10-10',
87670, 1, 'Robin.Uttappa@yahoo.com', CURRENT_DATE());

-- Test with an invalid HireDate (in the future): This should fail and raise an error with the message “HireDate cannot be in the future”.
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, Salary, DepartmentID, Email, HireDate)
VALUES (1014, 'Rohit', 'Sharma', '1991-07-02',
88770, 1, 'Rohit.Sharma@yahoo.com', DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY));

-- Test updating an existing record to a future HireDate: This should also fail with the same error message. By running these tests, you can confirm that the trigger is correctly preventing future dates from being inserted or updated in the HireDate column.
UPDATE Employees
SET HireDate = DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY)
WHERE EmployeeID = 1;

-- 7.i. Composite Keys and Indexes
-- o In the Employees table, create a composite primary key on the combination of EmployeeID and HireDate (if HireDate is unique for each employee).
-- Drop the existing primary key
ALTER TABLE Employees
DROP PRIMARY KEY;

-- Identify rows with NULL values
SELECT * FROM Employees
WHERE EmployeeID IS NULL OR HireDate IS NULL;

-- update or remove rows with NULL values
-- option 1: update NULL values
UPDATE Employees
SET HireDate = '2000-01-01'
WHERE HireDate IS NULL;

-- Add the composite primary key
ALTER TABLE Employees
ADD PRIMARY KEY (EmployeeId, HireDate);

-- verification (If this query returns no rows, it means the combination is unique.)
SELECT EmployeeID, HireDate, COUNT(*)
FROM Employees
GROUP BY EmployeeID, HireDate
HAVING COUNT(*) > 1;

-- ii). Composite Unique Key:
-- Add the Columns: If the columns don’t exis
ALTER TABLE Departments
ADD FirstName VARCHAR(50),
ADD LastName VARCHAR(50);

-- Add the Unique Constraint: Once the columns are added, you can then add the unique constrain
ALTER TABLE Departments
ADD CONSTRAINT unique_head_name UNIQUE (FirstName, LastName);

-- Check for Existing Duplicates: Before adding the unique constraint, ensure there are no existing duplicate combinations of FirstName and LastName.
-- If this query returns no rows, it means there are no duplicates, and you can proceed with adding the unique constraint.
SELECT FirstName, LastName, COUNT(*)
FROM Departments
GROUP BY FirstName, LastName
HAVING COUNT(*) > 1;

-- Questions on UPDATE, ALTER, and MODIFY Commands
-- 1. Altering and Modifying Table Structures
-- i. Modify Data Types:
-- o  Change the Salary column in the Employees table to a larger precision, for example, DECIMAL(12,2) to allow for higher salaries.
ALTER TABLE Employees
MODIFY Salary DECIMAL(12,2);

-- Verify the column definition to ensure it has been updated correctly.
SHOW COLUMNS FROM Employees LIKE 'Salary';

-- Insert a test record with a high salary value to ensure the new precision is working as expected:
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, Salary, DepartmentID, Email, HireDate)
VALUES (1016, 'Robin', 'Uttappa', '2001-10-10',
823456781.34, 1, 'Robin.Uttappa@yahoo.com', CURRENT_DATE());

-- Retrieve the test record to confirm the value was inserted correctly
SELECT EmployeeID, FirstName, LastName, Salary
FROM Employees
WHERE EmployeeID = 1016;

-- o Modify the DateOfBirth column in the Employees table from DATE to DATETIME to include time of birth.
-- Step 1: Drop the old VARCHAR column
ALTER TABLE Employees
DROP COLUMN DateOfBirth;

-- Step 2: Rename the new column to the original name
ALTER TABLE Employees
CHANGE DateOfBirth_temp DateOfBirth DATE;

-- Step 3: Add a new column with DATE type
ALTER TABLE Employees
ADD DateOfBirth_temp DATE;

-- Step 4: Convert and copy data
UPDATE Employees
SET DateOfBirth_temp = STR_TO_DATE(DateOfBirth, '%Y-%m-%d'); -- Adjust the format as needed


-- Modify the DateOfBirth column in the Employees table from DATE to DATETIME to include the time of birth
ALTER TABLE Employees 
MODIFY DateofBirth DATETIME;

ALTER TABLE Employees
DROP COLUMN DateOfBirth_temp;

-- Verification
-- Check the table Structure
DESCRIBE Employees;

-- Insert a test record
INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth, Salary, DepartmentID, Email, HireDate)
VALUES (1017, 'Robin', 'Uttappa','2024-09-09 12:34:56',
823456781.34, 1, 'Robin.Uttappa@yahoo.com', CURRENT_DATE());

-- Query the table
SELECT DateOfBirth FROM Employees WHERE EmployeeID = 1017;

-- ii.	Add New Columns:
-- o Add a new column Email (VARCHAR(110)) to the Employees table to store employee email addresses.
ALTER TABLE Employees
MODIFY Email VARCHAR(110);
-- Verification
DESCRIBE Employees;

-- o Add a new column DepartmentHead (BOOLEAN) to the Departments table to indicate if a department has a head.
ALTER TABLE Departments
ADD DepartmentHead BOOLEAN;

-- Verify
DESCRIBE Departments;

-- Insert a test record
INSERT INTO DEPARTMENTS (DepartmentID, DepartmentName, FirstName, LastName, DepartmentHead)
VALUES
(10,'SalesMan', 'Krish', 'Gaurav',TRUE);

-- Query the table:
SELECT DepartmentHead FROM Departments WHERE DepartmentID = 10;

-- iii.	Rename Columns:
-- o Rename the Position column in the Employees table to JobTitle.
ALTER TABLE Employees
RENAME COLUMN JobTitle TO Position;
-- Verify
DESCRIBE Employees;

-- iv. Remove Columns:
-- o Drop the HireDate column from the Employees table as it is no longer needed.
ALTER TABLE Employees
DROP COLUMN HireDate;
-- Verify
DESCRIBE Employees;

-- o   Remove the DepartmentHead column from the Departments table.
ALTER TABLE Departments
DROP COLUMN DepartmentHead;
-- Verify
DESCRIBE Departments;

-- v.	Change Default Values:
-- o	Modify the default value for the Position column in the Employees table to 'Employee' instead of 'Unknown'.
ALTER TABLE Employees
ALTER COLUMN Position SET DEFAULT 'Employee';
-- Verify
SHOW COLUMNS FROM Employees LIKE 'Position';

-- Updating Data
-- i.	Basic Updates:
-- o	Update the Salary of all employees with the Position of 'Junior Developer' to 70000.
SHOW TRIGGERS LIKE 'Employees';
DROP TRIGGER trg_CheckHireDate_Update;

UPDATE Employees
SET Salary = 70000
WHERE Position = 'Junior Developer';
-- Verify
SELECT EmployeeId, FirstName, Position, Salary
FROM Employees
WHERE Position = 'Junior Developer';
-- Or
SELECT EmployeeId, FirstName, Position, Salary
FROM Employees
WHERE Position = 'Junior Developer'; AND Salary != 70000;

-- o  Change the DepartmentName of the department with DepartmentID = 2 to 'Research & Development'.
UPDATE Departments
SET DepartmentName = 'Research & Development2'
WHERE DepartmentID = 2;
-- verify
SELECT DepartmentID, DepartmentName 
FROM Departments
WHERE DepartmentID = 2;
-- or 
SELECT * FROM Departments;

-- ii. Conditional Updates:
-- o  Update the JobTitle of employees who were DateOfBirth before 2015-01-01 to 'Senior Developer'.
UPDATE Employees
SET Position = 'Senior Developer'
WHERE DateOfBirth < '1995-01-01';
-- verify
SELECT EmployeeId, FirstName, Position, DateOfBirth
FROM Employees
WHERE DateOfBirth < '1995-01-01';

-- iii.	Bulk Updates:
-- o	Increase the Salary of all employees by 10%.
UPDATE Employees
SET Salary = Salary * 1.10;
-- verify
SELECT EmployeeID, Salary FROM employees;
-- Compare the Results
SELECT EmployeeID, Salary, Salary / 1.10 AS OriginalSalary FROM employees;

-- o   Set the DepartmentID of all employees currently in the HR department to NULL (assuming the department is being dissolved).
UPDATE Employees
SET DepartmentID = NULL 
WHERE DepartmentID =(SELECT DepartmentID FROM departments WHERE DepartmentName = 'HR');

-- Run the same query again to get the updated DepartmentID values.
SELECT EmployeeID, DepartmentID
FROM employees
WHERE DepartmentID is NULL;

-- Compare the before and after results to ensure that the DepartmentID for all employees previously in the HR department is now NULL.
-- This query will show the employees who were in the HR department and now have their DepartmentID set to NULL.
SELECT EmployeeID, DepartmentID
FROM employees
WHERE DepartmentID IS NULL
AND EmployeeID IN (
    SELECT EmployeeID
    FROM employees
    WHERE DepartmentID = (SELECT DepartmentID FROM departments WHERE DepartmentName = 'HR')
) LIMIT 0, 1000;

-- iv.	Update Using Joins:
-- o	Update the Salary of employees in the Sales department to 80000 using a join between Employees and Departments on DepartmentID.
UPDATE Employees
JOIN departments ON employees.DepartmentID = departments.DepartmentID
SET employees.Salary = 80000
WHERE departments.DepartmentName = 'Sales';

-- Compare the before and after results to ensure that the salary for all employees in the Sales department is now 80,000.
SELECT e.EmployeeID, e.Salary 
FROM employees e
JOIN departments d ON e.DepartmentID = d.DepartmentID 
WHERE d.DepartmentName = 'Sales' AND e.Salary = 80000;

-- o	Set the DepartmentHead to TRUE for the department that has an employee named 'Natalie'.
-- Identify the DepartmentID of the department where ‘Natalie’ works:
SELECT DepartmentID
FROM employees
WHERE FirstName = 'Natalie';

-- Add the DepartmentHead Column
ALTER TABLE departments
ADD COLUMN DepartmentHead BOOLEAN DEFAULT FALSE;

-- Directly update suing the known DepartmentID
UPDATE departments
SET DepartmentHead = True
WHERE DepartmentID = 1;

-- Update the DepartmentHead to TRUE for the identified department: SQL
UPDATE departments
SET DepartmentHead = TRUE
WHERE DepartmentID IN (
	SELECT DepartmentID
    FROM Employees
    WHERE FirstName = 'Natalie');

-- For verification Run the same query again to get the updated DepartmentHead status.
SELECT d.DepartmentID, d.DepartmentHead 
FROM departments d 
JOIN employees e ON d.DepartmentID = e.DepartmentID 
WHERE e.FirstName = 'Natalie';

-- 3. Advanced Table Modifications
-- i. Reorganize Table:
-- o  Change the order of columns in the Employees table to have LastName appear before FirstName.
--  Create a New Table with the desired column order
CREATE TABLE employees_new (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    DateOfBirth DATETIME,
    Position VARCHAR(100),
    Salary DECIMAL(12, 2),
    DepartmentID INT,
    Email VARCHAR(110)
);
 -- Copy Date from the old table to the new table
INSERT INTO Employees_new (EmployeeID, LastName, FirstName,  DateOfBirth, Position, Salary, DepartmentID, Email)
SELECT EmployeeID, LastName, FirstName, DateOfBirth, Position, Salary, DepartmentID, Email FROM employees;

-- Drop the Old Table
DROP TABLE Employees;

-- Rename the new table to the original table name
ALTER TABLE employees_new RENAME TO Employees;

-- verification. This will help you confirm that LastName appears before FirstName and that the data is accurate.
SELECT EmployeeID, LastName, FirstName
FROM employees
LIMIT 10;

-- o  Reorder the Departments table so that DepartmentID is the last column.
describe departments;
-- Create a New Table with the desired column order
CREATE TABLE departments_new (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(150),
    FirstName VARCHAR(50),
	LastName VARCHAR(50),
    DepartmentHead BOOLEAN);
-- Copy Data from the old table to the new table
INSERT INTO departments_new (DepartmentName, DepartmentHead, FirstName, LastName, DepartmentID)
SELECT DepartmentName, DepartmentHead, FirstName, LastName, DepartmentID
FROM departments;
-- Drop the Old Table
DROP TABLE departments;
-- Rename the New Table to the original table name
ALTER TABLE departments_new RENAME TO departments;

-- ii. Drop and Add Constraints:
-- o   Drop the foreign key constraint on DepartmentID in the Employees table, and then add it back with ON DELETE CASCADE.
-- There are existing records in the Employees table with DepartmentID values that do not match any DepartmentID in the Departments table.
-- To update the DepartmentID values in the Employees table to valid ones
SELECT DepartmentID FROM Departments;

-- Assuming you want to update all invalid DepartmentID values to a specific valid DepartmentID (let’s say 1), you can use the following query:
UPDATE Employees 
SET DepartmentID = 1
WHERE DepartmentID NOT IN (SELECT DepartmentID FROM Departments);
-- verification 
SELECT * FROM Employees 
WHERE DepartmentID NOT IN (SELECT DepartmentID FROM Departments);

-- Add the foreign key constraint back with ON DELETE CASCADE
ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_DepartmentID
FOREIGN KEY (DepartmentID) REFERENCES 
Departments(DepartmentID)
ON DELETE CASCADE;

-- To ensure that the ON DELETE CASCADE option is working, you can perform a test delete operation on the Departments table and check if the corresponding records in the Employees table are deleted.
DELETE FROM Departments WHERE DepartmentID = 1;
-- Then, check the Employees table to see if the related records have been deleted:
SELECT * FROM Employees WHERE DepartmentID = 1;  -- If the records with DepartmentID = 1 are deleted from the Employees table, the ON DELETE CASCADE is working correctly.

-- o	Drop the unique constraint on the combination of FirstName and LastName in the Employees table.
-- To create a unique constraint on the combination of FirstName and LastName in the Employees table
-- Update the duplicate records to make them unique. To delete the duplicate records while keeping one instance of each combination:

DELETE e1
FROM Employees e1
INNER JOIN Employees e2
WHERE e1.EmployeeID > e2.EmployeeID
AND e1.FirstName = e2.FirstName
AND e1.LastName = e2.LastName;

-- Add the unique constraint:
ALTER TABLE Employees
ADD CONSTRAINT UQ_Employees_FirstName_LastName
UNIQUE (FirstName, LastName);

-- Find the name of the unique constraint:
SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Employees' AND CONSTRAINT_TYPE = 'UNIQUE';

-- Drop the unique constraint:
ALTER TABLE Employees
DROP CONSTRAINT UQ_Employees_FirstName_LastName;

-- 3. iii. o	Drop the composite index on FirstName and LastName in the Employees table.
-- To create a composite index on the FirstName and LastName columns in the Employees table.
CREATE INDEX idx_FirstName_LastName
ON Employees (FirstName, LastName);

-- This query will list all indexes on the FirstName and LastName columns in the Employees table.
SELECT INDEX_NAME
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_NAME = 'Employees' AND (COLUMN_NAME = 'FirstName' OR COLUMN_NAME = 'LastName');

-- Once you have the correct index name, use it in the following command to drop the index
ALTER TABLE Employees
DROP INDEX idx_FirstName_LastName;

-- 4. Combined Operations
-- i. Update and Alter Combined:
-- o  First, update all employee Salaries to NULL, then modify the Salary column to set a NOT NULL constraint with a default value of 50000.
-- Update all employee salaries to NULL
UPDATE Employees
SET Salary = NULL;

-- This query will help you find any Salary values that are outside the range allowed by the DECIMAL(10,2) data type.
SELECT * FROM Employees WHERE Salary IS NOT NULL 
AND (Salary < -99999999.99 OR Salary > 99999999.99);

-- Update these records to a value within the acceptable range. you can set them to 50000
UPDATE Employees
SET Salary = 50000
WHERE Salary IS NOT NULL AND (Salary < -99999999.99 
OR Salary > 99999999.99);

-- Modify the Salary column to set a NOT NULL constraint with a default value of 50000
ALTER TABLE Employees 
MODIFY COLUMN Salary DECIMAL(10,2) NOT NULL 
DEFAULT 50000;

-- Verify the NOT NULL constraint and default value. 
-- The output should indicate that the Salary column is NOT NULL and has a default value of 50000
SHOW COLUMNS FROM Employees LIKE 'Salary';

-- o  Add a new column PhoneNumber to the Employees table and immediately populate it with a default value for all existing rows.
ALTER TABLE Employees 
ADD COLUMN PhoneNumber VARCHAR(15) DEFAULT 'N/A'; 

-- Use the SHOW COLUMNS command to verify that the PhoneNumber column has been added
SHOW COLUMNS FROM Employees LIKE 'PhoneNumber';
SELECT DISTINCT PhoneNumber FROM Employees; -- to check the values in the PhoneNumber column for all existing rows:

-- ii.	Modify and Update Combined:
-- Modify the JobTitle column to accept a maximum of 100 characters, then update all employees with the title 'Intern' to have the title 'Temporary Employee'.
-- Modify the JobTitle column
ALTER TABLE Employees
MODIFY COLUMN Position VARCHAR(100);
-- Update the job titles
UPDATE Employees
SET Position = 'Temporary Employee'
WHERE Position = 'Intern';
-- Verify the column modification
SHOW COLUMNS FROM Employees LIKE 'Position';
-- Verify the updates
SELECT DISTINCT Position FROM Employees;

-- Practice Questions on DELETE Commands with Conditions
-- 1. Basic DELETE Operations
-- i.	Delete a Specific Record:
-- o	Delete the employee from the Employees table where the EmployeeID is 5
DELETE FROM Employees
WHERE EmployeeID = 5;
-- To verify
SELECT * FROM Employees WHERE EmployeeID = 5;

-- ii.	Delete Multiple Records Based on a Condition:
DELETE FROM Employees
where Salary < 50000;
-- Verify
SELECT * FROM Employees WHERE Salary < 50000;

-- 2. DELETE with Complex Conditions
-- i.	Delete Using AND/OR Conditions
-- o	Delete all employees from the Employees table who are either in the HR department or have a JobTitle of 'Intern'
DELETE FROM Employees
WHERE DepartmentID = (SELECT DepartmentID FROM Departments WHERE DepartmentName = 'HR')
OR Position = 'Intern';
-- Verification: This query should return no rows if the deletion was successful.
SELECT * FROM Employees
WHERE DepartmentID = (SELECT DepartmentID from Departments WHERE DepartmentName = 'HR')
OR Position = 'Intern';

-- ii.	Delete Using EXISTS Clause
-- o	Delete all employees from the Employees table where the department they belong to no longer exists in the Departments table.
DELETE FROM Employees
WHERE DepartmentID NOT IN (SELECT DepartmentID FROM Departments);
-- Run a SELECT query to check the affected rows
SELECT * FROM Employees
WHERE DepartmentID NOT IN (SELECT DepartmentID FROM Departments);
-- Check the total number of rows before and after deletion:
SELECT COUNT(*) FROM Employees;

-- 3. DELETE with Cascading and Foreign Keys
-- i.	Cascade DELETE Operations:
-- o	Delete a department from the Departments table and ensure all related employees are also deleted (requires foreign key with ON DELETE CASCADE).
-- Create the Tables with Foreign Key Constraint: Ensure your Employees table has a foreign key that references the Departments table with the ON DELETE CASCADE option.
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100));

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID) ON DELETE CASCADE);

-- Delete a Department: When you delete a department, all related employees will be automatically deleted due to the ON DELETE CASCADE constraint
DELETE FROM Departments WHERE DepartmentID = 1;

-- Verify Deletion
SELECT * FROM Employees;

-- ii.	Delete Using a Restriction
-- o	Attempt to delete a department from the Departments table where there are still employees assigned to that department, and observe what happens (if foreign keys are not set to cascade).
-- Insert Sample Data: Insert some sample data into both tables
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES (1, 'HR'), (11, 'IT2');

INSERT INTO Employees (EmployeeID, FirstName, DepartmentID) VALUES 
(1015, 'Vivek', 2),
(1016, 'Sai', 1),
(1017, 'Mukesh', 1);

-- Attempt to Delete a Department: Try to delete a department that still has employees assigned to it.
DELETE FROM Departments WHERE DepartmentID = 1;

-- 4. Deleting All Records with a Condition
-- i.	Delete All Records Based on a Common Attribute:
-- o	Delete all records from the Employees table where the JobTitle is 'Consultant'.
DELETE FROM Employees WHERE Position = 'Consultant';

-- ii.	Delete Records with NULL Values:
-- o	Delete all employees from the Employees table where the Salary is NULL.
DELETE FROM Employees WHERE Salary IS NULL;

-- iii.	Conditional DELETE Using Aggregate Functions: 
-- o	Delete employees from the Employees table who earn less than the average salary of all employees.
DELETE FROM Employees
WHERE Salary < (SELECT avg_salary FROM (
	SELECT AVG(Salary) AS avg_salary FROM Employees) AS temp);

use company_db;