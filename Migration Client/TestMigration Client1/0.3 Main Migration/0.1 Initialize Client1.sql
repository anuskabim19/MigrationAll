select *from CustomerData

alter table CustomerData
add  MigrationStatus nvarchar(max)
update CustomerData
set MigrationStatus='Migrate'
where CustomerID between 1 and 9

select *from Assignment

alter table Assignment
add  MigrationStatus nvarchar(max)

update Assignment
set MigrationStatus='Migrate'
where AssignmentID is null

select *From Job

alter table Job
add  MigrationStatus nvarchar(max)

update Job
set MigrationStatus='Migrate'
where MigrationStatus is null

select *From EmployeeData

alter table EmployeeData
add  MigrationStatus nvarchar(max)

update EmployeeData
set MigrationStatus='Migrate'
where MigrationStatus is null


update jobtitle
set MigrationStatus='Migrate'


alter table jobtitle
add  MigrationStatus nvarchar(max)

ALTER TABLE Assignment
ADD AssignmentId INT IDENTITY(1,1);

ALTER TABLE Assignment
ADD CONSTRAINT PK_Assignment PRIMARY KEY (AssignmentId);

alter table assignment
drop column assignmentid


select *from Assignment
----=========================================================================

alter table EmployeeData
add  EmployeeType nvarchar(max)

update EmployeeData
set EmployeeType='Employee'


UPDATE EmployeeData
SET Name = LEFT(Name, CHARINDEX(' ', Name) - 1),
    Name = SUBSTRING(Name, CHARINDEX(' ', Name) + 1, LEN(Name));


	select SUBSTRING(Name,1, CHARINDEX(',',Name)-1)as FirstName,
	SUBSTRING(Name,1, CHARINDEX(',',Name)+1)as MiddleName,
	SUBSTRING(Name,1, CHARINDEX(',',Name)+1)as LastName
	from EmployeeData


	SELECT 
    CASE 
        WHEN CHARINDEX(',', Name) > 0 
        THEN LTRIM(SUBSTRING(Name, CHARINDEX(',', Name) + 1, LEN(Name)))
        ELSE Name
    END AS FirstName,
    CASE 
        WHEN CHARINDEX(',', Name) > 0 AND LEN(Name) - LEN(REPLACE(Name, ' ', '')) > 1 
        THEN SUBSTRING(Name, CHARINDEX(' ', Name, CHARINDEX(',', Name) + 2) + 1, LEN(Name))
        ELSE NULL 
    END AS MiddleName,
    CASE 
        WHEN CHARINDEX(',', Name) > 0 
        THEN LTRIM(RTRIM(SUBSTRING(Name, 1, CHARINDEX(',', Name) - 1)))
        ELSE NULL
    END AS LastName
FROM EmployeeData


SELECT 
    EmployeeID,
    Name,
    PARSENAME(REPLACE(Name, ' ', '.'), 3) AS FirstName,
    CASE 
        WHEN LEN(Name) - LEN(REPLACE(Name, ' ', '')) = 2 
        THEN PARSENAME(REPLACE(Name, ' ', '.'), 2)
        ELSE NULL
    END AS MiddleName,
    PARSENAME(REPLACE(Name, ' ', '.'), 1) AS LastName --select *
FROM EmployeeData


-- Step 1: Add new columns to the EmployeeData table
ALTER TABLE EmployeeData
ADD FirstName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    LastName NVARCHAR(50);

-- Step 2: Update the new columns with split name data
UPDATE EmployeeData
SET 
    FirstName = PARSENAME(REPLACE(Name, ' ', '.'), 2),
    MiddleName = CASE 
                    WHEN LEN(Name) - LEN(REPLACE(Name, ' ', '')) = 2 
                    THEN PARSENAME(REPLACE(Name, ' ', '.'), 2)
                    ELSE NULL
                 END,
    LastName = PARSENAME(REPLACE(Name, ' ', '.'), 1);


	alter table dbo.employeedata
	drop column name


	select *from EmployeeBank
	alter table EmployeeBank
	add BankId int primary key identity(1,1)
