 use Anuska_2024_new
select *from dbo.EmployeeInfo
select * from dbo.EmployeeInfo where SSN is null

select SSN from dbo.EmployeeInfo where len(SSN ) <9

SELECT CONCAT(ei.FirstName, ' ', ei.LastName) AS EmployeeName,
bd.* FROM dbo.EmployeeInfo ei
INNER JOIN dbo.BranchDetail bd
ON ei.BranchId = bd.BranchId
select *from EmployeeInfo


select Address,Address2,City,Zip,State from EmployeeInfo
select *from EmployeeInfo where State is null
select *from CustomerInfo
select *from CustomerInfo where ParentCustomerId is not null

select ci.CustomerName, bd.*
from dbo.CustomerInfo as ci
inner join BranchDetail as bd
on ci.BranchId=bd.BranchId

select status from CustomerInfo
select *from CustomerInfo
select Street1,Street2,City,Country,State,Zip from CustomerInfo
select *from CustomerInfo 
where State is null
or Street1 is null
or Street2 is null
or City is null
or Country is null


select * from dbo.EmployeeInfo where SSN is null

select SSN from dbo.EmployeeInfo where len(SSN ) <9

SELECT CONCAT(ei.FirstName, ' ', ei.LastName) AS EmployeeName,
bd.* FROM dbo.EmployeeInfo ei
INNER JOIN dbo.BranchDetail bd
ON ei.BranchId = bd.BranchId


select *from CustomerInfo where ParentCustomerId is not null