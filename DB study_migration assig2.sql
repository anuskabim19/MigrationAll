--1	Did we find table for employee?

select *from EmployeeData

--2	Did we find column for Employee Office?
--no


--3	Did we find column for Employee Status?
select e.name,e.MaritalStatus, eb.status from EmployeeData e
inner join EmployeeBank eb on eb.employeeid=e.EmployeeID

--4	Did we find column for SSN?
select e.Name,e.SSN from EmployeeData e

--5	Is there any data without SSN? example needed.
--no
select e.SSN from EmployeeData e where e.SSN is not null

--6	Is there any SSN less than 9 digit? example needed.
--No
select e.SSN from EmployeeData e where len(e.SSN) <9

--7	Did we find any non W2 employee? Example needed. If not verify with Client if they has non W2 Employee.
--Yes
select e.Name , et.W2_2020 from EmployeeData e
inner join EmployeeTax et on et.EmployeeId=e.EmployeeID
where et.W2_2020 is null

-----------------------------------------------------------------------------------------------------------------------------

--1	Did we find table for employee address?
--yes
select e.name,e.fulladdress from EmployeeData e

--2	Is there any address without state? example needed.
--no

select e.name,e.fulladdress from EmployeeData e

---------------------------------------------------------------------------------------------------------
--1	Did we find table for employee contact information?
--yes, its in EmployeeData table in ContactInformation column
select e.name,e.ContactInformation from EmployeeData e

------------------------------------------------------------------------------------------------------------

--1	Did we find table for Personbank?

--yes
select *from EmployeeBank

--2	Did we find Column for Account Type? (eg. Checking and Saving)
--yes
select eb.BankName,eb.AccountType from EmployeeBank eb

--3	Did we find Column for Amount Type? (eg. Remaining,Fixed,Perentage)
--yes
select eb.BankName,eb.AmountType from EmployeeBank eb

--4	Are there any inactive Bank Accounts?
--yes
select eb.BankName,eb.Status from EmployeeBank eb where eb.Status like '%Inactive%'

--5	Did we find column for Amount?
--yes
select eb.BankName ,eb.AmountValue from EmployeeBank eb

--6	Is there a column for Prenote?
--No

--7	Is there any bank setup with routing number less than 9 digit? example needed.
--Yes
select eb.BankName,eb.RoutingNumber from EmployeeBank eb where len(eb.RoutingNumber)<9


--8	Is there any data without Routing number and Account Number? example needed.
--No
select eb.BankName,eb.RoutingNumber,eb.AccountNumber from EmployeeBank eb 
where  eb.RoutingNumber is  null and eb.AccountNumber is  null


-----------------------------------------------------------------------------------------------------------------------
--1	Did we find table for person tax?
--yes 
select *from EmployeeTax

--2	Did we find column Employee Federal Exemptions?
--Yes
select e.Name,et.TaxName,et.FilingStatus  from EmployeeTax et
inner join EmployeeData e on e.EmployeeID=et.employeeid
where et.TaxName like '%federal%'

--3	Did we find column for Employee State Exemptions?
--Yes
select e.Name,et.TaxName,et.FilingStatus  from EmployeeTax et
inner join EmployeeData e on e.EmployeeID=et.employeeid
where et.TaxName like '%state%'

--4	Did we find column for Employee Filing Status?
--yes
select e.Name,et.FilingStatus  from EmployeeTax et
inner join EmployeeData e on e.EmployeeID=et.employeeid

--5	Did we find 2020 Tax setup for employees for federal income tax?
--Yes
select et.TaxName,et.W2_2020  From EmployeeTax et
WHERE et.TaxName like '%federal%' and et.W2_2020 ='YES'

--6	Did we find Employee Tax for "Exempt?
--Yes
select taxname,W2_2020 From EmployeeTax
where W2_2020 is null

-- w2 is compulsory tax but tax with null w2 2020 is exempt tax

--------------------------------------------------------------------------------------------------------------------
--1	Did we find table for deduction?
--yes
select *from EmployeeDeduction


--2	Did we find duplicate deduction setup?example needed?
--yes
SELECT 
    DeductionType, COUNT(*) as numberoftimesoccured
FROM 
    EmployeeDeduction
GROUP BY 
    DeductionType
HAVING 
    COUNT(*) > 1;


--3	Does deduction has Start and End Date?
--Yes
	select StartDate,EndDate from EmployeeDeduction


----------------------------------------------------------------------------------------
--1	Did we find table for benefit?
--no

--2	Did benefit codes can be mapped correcly?
--no
------------------------------------------------------------------------------------

--1	Did we find table for Accrual?
--no

--2	Did we need accrual mapping?
--no

------------------------------------------------------------------------------------
--Did we find table for job history?
--no
---------------------------------------------

--Did we find table for Comment?
--no

----------------------------------------------------

--Did we find table for document?
--no
--------------------------------------------------------
--1	Did we find table for Agency?
--2	Did we find Agency Address ?
--3	Did we find link between Agency and Person Deduction?
-----------------------------------------------------------------

--1	Did we find table for Customer?
--yes
select *from CustomerData

--2	Did we find any kind of Customer heirarchy?
--yes
select *from CustomerData where ParentcustomerId is not null

--3	Did we find column for Customer Office?
-- we did find the table for customer and office (branch detail) but we couldnt link it to extract data.

--4	Did we find column for Customer Status?
--no
--5	Did we find Customer Address?
--yes
	select  cd.address from CustomerData cd

--6	Did we find Customer Contact information (Phone,email etc.)?
--yes
select cd.ContactInformation from CustomerData cd

--7	Did we find Customer Wccode setup?
--yes
select cd.customername,j.wccode from customerdata cd
		inner join job j on j.CustomerID=cd.customerid
		where j.WcCode is not null

--8	Did we find Customer Service Info (OT Plan, Payment Term, Payperiod etc.)?
--yes

		select
		  cd.CustomerName,
		  STRING_AGG(j.PayCodeType, ', ') AS PayCodeType
		  from CustomerData cd
		  inner join job j on j.CustomerID=cd.customerid
		  group by cd.customername,j.PayCodeType

--9	Did we find 9 Sales Info (Industry, OrganizationType, SalesLevel, Source etc.)?
--no

--10	Did we find Customer Skill?
--no

--11	Did we find Customer Discount?
--no
--12	Did we find Customer Sales Tax?
--no

--13	Did we find Customer Document
--no

--14	Did we find Customer Comment?
--no

--15	Did we find Customer charge?
--no
------------------------------------------------------------------------------------

--1	Did we find table for assignments?
--yes
select *from Assignment


--2	Did we find column for Assignment Office?
--no

--3	Did we find column for Assignment Performance Code (may be Assignment status in client system)?
--no

--4	Did we find rates for Assignment? 
--yes
select payrate ,billrate from Assignment

--5	Did we find link between Job and Assignments?
--yes
select *from Assignment a
inner join job j on j.JobID=a.JobID

--6	Are there any assignments that do not link with orders, or the respective Job is missing?
--yes
SELECT 
    a.*
FROM 
    Assignment a

left JOIN 
    Job j ON j.JobID = a.JobID

	where j.JobID is null


--7	Do assignments created from single order have different WcCode?
--yes

	SELECT
    j.JobID,
    COUNT(DISTINCT j.WcCode) AS WcCodeCount
FROM
    Assignment a
	inner join job j on j.JobID=a.JobID
GROUP BY
    j.JobID
HAVING
    COUNT(DISTINCT j.WcCode) > 1;

--8	Do assignments created from single order have different Job Titles?
--no

--9	Did we find Start and End date for Assignment?
--yes
select Startdate,enddate from Assignment 


--10	Did we find link between Employee and Assignment?
--yes
select *From EmployeeData e
inner join Assignment a on a.EmployeeID=e.EmployeeID

--11	Are there any assignments that do not link back with employee, or Assignments with employee that doesn't exist in Employee table?
--no

select *From EmployeeData e
inner join Assignment a on a.EmployeeID=e.EmployeeID
where  e.EmployeeID is null

--12	Did we find column for Assignment End reason?
--yes
select endreason from Assignment

-----------------------------------------------------------------------------------------------------------------------------
--1	Did we find table for transaction?

--no

--2	Did we find column for Transaction Office?
--no

--3	Did we find logic to find the weekworked for transactions?
--no

--4	Did we find the link between Transaction and Assignments?  If "Yes", Then Yes for #5 and #6.
--no

--5	Did we find link between Transaction and Employee?
--no

--6	Did we find link between Transaction and Customer?
--no

--7	Did we find column for WcCode?
--yes
select  WcCode from Job

--8	Did we find few columns or logic to find these columns: 
--	Gross Amount
--	Bill Amount
--	Worker Comp Cost

--no

--9	Did we find the table or logic for transactionItems (Eg: Reg, OT , DT etc.)
--yes

select
		  cd.CustomerName,
		  STRING_AGG(j.PayCodeType, ', ') AS PayCodeType
		  from CustomerData cd
		  inner join job j on j.CustomerID=cd.customerid
		  group by cd.customername,j.PayCodeType


--------------------------------------------------------------------------------------------------------------
--1	Did we find table for Payment?
--no
--select PaymentTerms from CustomerData

--2	Did we find column for Check office?
--no

--3	Did we find column for Check number?
--no

--4	Did we find column for Gross Wage?
--no

--5	Did we find these taxes with tax amount and taxable amount?
--	Employee Portion
--	Federal Income Tax
--	Medicare EE
--	FICA EE
--	State Income Tax
--	Employer Portion 
--	State Unemployment (SUI /  SUTA)
--	FUTA ER
--	Medicare ER
--	FICA ER

--yes

select taxname from EmployeeTax

--6	Are there any local taxes?
--no

--7	Did we find the column to link Check with Employee?
--no

--8	Check if any Paychecks from current or previous year is missing link with Employee or if Employee does not exits in Employee table.
--no

--9	Did we find any link between checks and transactions?
--no

-----------------------------------------------------------------------------------------------------------------------
--1	Did we find table for payment bankaccount?
--yes but not exact name
select *from EmployeeBank

--2	Did we find link between paymentbankaccount, payment, personbankaccount?
--no

-------------------------------------------------------------------------------------------------------------------------
--1	Did we find table for paymentadjustment?
--no

--3	Did we find column for deduction type and deduction amount for checks?

select DeductionType,Amount as DeductionType from EmployeeDeduction

--4	Did we find link between paymentadjustment, payment and personadjustment?
--no

-----------------------------------------------------------------------------------------------------------------------
--1	Did we find table for paymentbenefit?
--no

--2	Did we find link between paymentbenefit, payment and personbenefit?
--no

------------------------------------------------------------------------------------------------------------------------
--1	Did we find the Invoice Branch?
--no

--2	Did we find the link between Invoice and Customer?
--no

--3	Any Invoice/s without link with Customer, or the customer does not exist in Customer table?
--no

--4	Did we find AR payment reason?
--no

--5	Did we find the link between Invoice and Payments?
--no

-------------------------------------------------------
--1	Did we find table for Job? yes
--2	Did we find Column for Job office? no
--3	Did we find column for Job Status? no
--4	Did we find column for job type? no
--5	Did we find link between Order and Customer? no
--6	Are there any orders without Customer, or orders with Customer that does not exist in Customer table?
--7	Do orders have rates? Required: Reg and OT
--8	Do orders have direct link with Customer Address?
--9	Did we find column for WcCode for orders?
--10	Did we find column for Job Jobtitle?
--11	Did we find Start and End date for Job?
--12	Did we find the direct hire job?

select *From job


--------------------------------------------------

--Did we find link between Customer and Contact?
--Are there any contacts that dont have link with Customer? If yes provide example.
--Did we find Contact Address?
--Did we find Contact contact Info (Eg:email)?


select *From CustomerData where CustomerID <> ContactInformation

