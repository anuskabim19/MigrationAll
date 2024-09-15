--1)	List out the person information (PersonId, Name, Office Name, 
--person status, Bankid, bank Name, bank status, account type, amount type, value, sequence) for following cases.




select *from Person
select *from personusertype 
select *from Office
select *from PersonBankAccount
select *from Organization
select *from PersonCurrent
select *from ListItemCategoryProperty
select *from bank


;

--where inative bank count is > 1
---------------------------------------------------------------------------------------------------------------------------------------------------

--a) Person having multiple bank setup as inactive.

--select distinct p.personid,CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName)AS FullName,o.Office as OfficeName ,li.listitem as PersonStatus,
--b.BankId,b.Bank as BankName,li2.ListItem as BankStatus, li3.ListItem as AccountType , 
--li4.ListItem as AmountType,licp.ValueList,
--pba.Sequence
--from person p
--inner join Office o on o.OrganizationId=p.OrganizationId
--inner join PersonUserType pt on pt.PersonId=p.PersonId
--inner join ListItem li on li.ListItemId=pt.StatusListItemId
--inner join ListItemCategory lic on lic.ListItemCategoryId=li.ListItemCategoryId
--inner join ListItemCategoryProperty licp on licp.ListItemCategoryId=lic.ListItemCategoryId
--inner join PersonBankAccount pba on pba.PersonId=p.PersonId
--inner join bank b on b.BankId=pba.BankId
--inner join ListItem li2 on li2.ListItemId=pba.StatusListItemId and  pba.StatusListItemId = dbo.sflistitemidget('status', 'Inactive')
--inner join ListItem li3 on li3.ListItemId=pba.AccountTypeListItemId
--inner join ListItem li4 on li4.ListItemId=pba.AmountTypeListItemId
----where dbo.SfListItemGet(pba.StatusListItemId)<>'Active'
----and b.BankId>
--group by p.PersonId,CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName),o.Office,li.ListItem,b.BankId,b.Bank,li2.ListItem,li3.ListItem,li4.ListItem,licp.ValueList,pba.Sequence
--having count(b.Bank)>1
--order by p.PersonId desc


--corrected code


WITH InactiveBanks AS (
    SELECT 
        p.PersonId,
        CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
        o.Office AS OfficeName,
        li.ListItem AS PersonStatus,
        b.BankId,
        b.Bank AS BankName,
        li2.ListItem AS BankStatus,
        li3.ListItem AS AccountType,
        li4.ListItem AS AmountType,
        licp.ValueList,
        pba.Sequence
    FROM 
        Person p
    INNER JOIN 
        Office o ON o.OrganizationId = p.OrganizationId
    INNER JOIN 
        PersonUserType pt ON pt.PersonId = p.PersonId
    INNER JOIN 
        ListItem li ON li.ListItemId = pt.StatusListItemId
    INNER JOIN 
        ListItemCategory lic ON lic.ListItemCategoryId = li.ListItemCategoryId
    INNER JOIN 
        ListItemCategoryProperty licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
    INNER JOIN 
        PersonBankAccount pba ON pba.PersonId = p.PersonId
    INNER JOIN 
        Bank b ON b.BankId = pba.BankId
    INNER JOIN 
        ListItem li2 ON li2.ListItemId = pba.StatusListItemId AND pba.StatusListItemId = dbo.sflistitemidget('status', 'Inactive')
    INNER JOIN 
        ListItem li3 ON li3.ListItemId = pba.AccountTypeListItemId
    INNER JOIN 
        ListItem li4 ON li4.ListItemId = pba.AmountTypeListItemId
)
SELECT DISTINCT
    ib.PersonId,
    ib.FullName,
    ib.OfficeName,
    ib.PersonStatus,
    ib.BankId,
    ib.BankName,
    ib.BankStatus,
    ib.AccountType,
    ib.AmountType,
    ib.ValueList,
    ib.Sequence
FROM 
    InactiveBanks ib
INNER JOIN 
    (SELECT PersonId
     FROM InactiveBanks
     GROUP BY PersonId
     HAVING COUNT(DISTINCT BankId) > 1) multipleBanks
ON ib.PersonId = multipleBanks.PersonId
ORDER BY 
    ib.PersonId DESC;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

--b) Person having single bank but is InActive.

WITH InactiveBanks AS (
    SELECT 
        p.PersonId,
        CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
        o.Office AS OfficeName,
        li.ListItem AS PersonStatus,
        b.BankId,
        b.Bank AS BankName,
        li2.ListItem AS BankStatus,
        li3.ListItem AS AccountType,
        li4.ListItem AS AmountType,
        licp.ValueList,
        pba.Sequence
    FROM 
        Person p
    INNER JOIN 
        Office o ON o.OrganizationId = p.OrganizationId
    INNER JOIN 
        PersonUserType pt ON pt.PersonId = p.PersonId
    INNER JOIN 
        ListItem li ON li.ListItemId = pt.StatusListItemId
    INNER JOIN 
        ListItemCategory lic ON lic.ListItemCategoryId = li.ListItemCategoryId
    INNER JOIN 
        ListItemCategoryProperty licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
    INNER JOIN 
        PersonBankAccount pba ON pba.PersonId = p.PersonId
    INNER JOIN 
        Bank b ON b.BankId = pba.BankId
    INNER JOIN 
        ListItem li2 ON li2.ListItemId = pba.StatusListItemId AND pba.StatusListItemId = dbo.sflistitemidget('status', 'Inactive')
    INNER JOIN 
        ListItem li3 ON li3.ListItemId = pba.AccountTypeListItemId
    INNER JOIN 
        ListItem li4 ON li4.ListItemId = pba.AmountTypeListItemId
)
SELECT DISTINCT
    ib.PersonId,
    ib.FullName,
    ib.OfficeName,
    ib.PersonStatus,
    ib.BankId,
    ib.BankName,
    ib.BankStatus,
    ib.AccountType,
    ib.AmountType,
    ib.ValueList,
    ib.Sequence
FROM 
    InactiveBanks ib
INNER JOIN 
    (SELECT PersonId
     FROM InactiveBanks
     GROUP BY PersonId
     HAVING COUNT(DISTINCT BankId) = 1) multipleBanks
ON ib.PersonId = multipleBanks.PersonId
ORDER BY 
    ib.PersonId DESC;





--c) Person Having multiple bank account.

WITH Banks AS (
    SELECT 
        p.PersonId,
        CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
        o.Office AS OfficeName,
        li.ListItem AS PersonStatus,
        b.BankId,
        b.Bank AS BankName,
       -- li2.ListItem AS BankStatus,
        li3.ListItem AS AccountType,
        li4.ListItem AS AmountType,
        licp.ValueList,
        pba.Sequence
    FROM 
        Person p
    INNER JOIN 
        Office o ON o.OrganizationId = p.OrganizationId
    INNER JOIN 
        PersonUserType pt ON pt.PersonId = p.PersonId
    INNER JOIN 
        ListItem li ON li.ListItemId = pt.StatusListItemId
    INNER JOIN 
        ListItemCategory lic ON lic.ListItemCategoryId = li.ListItemCategoryId
    INNER JOIN 
        ListItemCategoryProperty licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
    INNER JOIN 
        PersonBankAccount pba ON pba.PersonId = p.PersonId
    INNER JOIN 
        Bank b ON b.BankId = pba.BankId
   
    INNER JOIN 
        ListItem li3 ON li3.ListItemId = pba.AccountTypeListItemId
    INNER JOIN 
        ListItem li4 ON li4.ListItemId = pba.AmountTypeListItemId
)
SELECT DISTINCT
    ib.PersonId,
    ib.FullName,
    ib.OfficeName,
    ib.PersonStatus,
    ib.BankId,
    ib.BankName,
    --ib.BankStatus,
    ib.AccountType,
    ib.AmountType,
    ib.ValueList,
    ib.Sequence
FROM 
    Banks ib
INNER JOIN 
    (SELECT PersonId
     FROM Banks
     GROUP BY PersonId
     HAVING COUNT(DISTINCT BankId) > 1) multipleBanks
ON ib.PersonId = multipleBanks.PersonId
ORDER BY 
    ib.PersonId DESC;




--d) Person having multiple bank amount type as Remaining.

WITH Banks AS (
    SELECT 
        p.PersonId,
        CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
        o.Office AS OfficeName,
        li.ListItem AS PersonStatus,
        b.BankId,
        b.Bank AS BankName,
       -- li2.ListItem AS BankStatus,
        li3.ListItem AS AccountType,
        li4.ListItem AS AmountType,
        licp.ValueList,
        pba.Sequence
    FROM 
        Person p
    INNER JOIN 
        Office o ON o.OrganizationId = p.OrganizationId
    INNER JOIN 
        PersonUserType pt ON pt.PersonId = p.PersonId
    INNER JOIN 
        ListItem li ON li.ListItemId = pt.StatusListItemId
    INNER JOIN 
        ListItemCategory lic ON lic.ListItemCategoryId = li.ListItemCategoryId
    INNER JOIN 
        ListItemCategoryProperty licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
    INNER JOIN 
        PersonBankAccount pba ON pba.PersonId = p.PersonId
    INNER JOIN 
        Bank b ON b.BankId = pba.BankId
   
    INNER JOIN 
        ListItem li3 ON li3.ListItemId = pba.AccountTypeListItemId
    INNER JOIN 
        ListItem li4 ON li4.ListItemId = pba.AmountTypeListItemId
		where li4.ListItem like 'Remaining'
)
SELECT DISTINCT
    ib.PersonId,
    ib.FullName,
    ib.OfficeName,
    ib.PersonStatus,
    ib.BankId,
    ib.BankName,
    --ib.BankStatus,
    ib.AccountType,
    ib.AmountType,
    ib.ValueList,
    ib.Sequence
FROM 
    Banks ib
INNER JOIN 
    (SELECT PersonId
     FROM Banks
     GROUP BY PersonId
     HAVING COUNT(DISTINCT BankId) > 1) multipleBanks
ON ib.PersonId = multipleBanks.PersonId

ORDER BY 
    ib.PersonId DESC;




--e) Person having Bank amount type remaining and Amount value <>0 .

WITH Banks AS (
    SELECT 
        p.PersonId,
        CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
        o.Office AS OfficeName,
        li.ListItem AS PersonStatus,
        b.BankId,
        b.Bank AS BankName,
       -- li2.ListItem AS BankStatus,
        li3.ListItem AS AccountType,
        li4.ListItem AS AmountType,
        licp.ValueList,
        pba.Sequence
    FROM 
        Person p
    INNER JOIN 
        Office o ON o.OrganizationId = p.OrganizationId
    INNER JOIN 
        PersonUserType pt ON pt.PersonId = p.PersonId
    INNER JOIN 
        ListItem li ON li.ListItemId = pt.StatusListItemId
    INNER JOIN 
        ListItemCategory lic ON lic.ListItemCategoryId = li.ListItemCategoryId
    INNER JOIN 
        ListItemCategoryProperty licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
    INNER JOIN 
        PersonBankAccount pba ON pba.PersonId = p.PersonId
    INNER JOIN 
        Bank b ON b.BankId = pba.BankId
   
    INNER JOIN 
        ListItem li3 ON li3.ListItemId = pba.AccountTypeListItemId
    INNER JOIN 
        ListItem li4 ON li4.ListItemId = pba.AmountTypeListItemId
		where li4.ListItem like 'Remaining' and pba.Value<>0
)
SELECT DISTINCT
    ib.PersonId,
    ib.FullName,
    ib.OfficeName,
    ib.PersonStatus,
    ib.BankId,
    ib.BankName,
    --ib.BankStatus,
    ib.AccountType,
    ib.AmountType,
    ib.ValueList,
    ib.Sequence
FROM 
    Banks ib
INNER JOIN 
    (SELECT PersonId
     FROM Banks
     GROUP BY PersonId
     HAVING COUNT(DISTINCT BankId) > 1) multipleBanks
ON ib.PersonId = multipleBanks.PersonId

ORDER BY 
    ib.PersonId DESC;


--f) Bank account with sequence 0.

select distinct p.personid,CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName)AS FullName,o.Office as OfficeName ,li.listitem as PersonStatus,
b.BankId,b.Bank as BankName,li2.ListItem as BankStatus, li3.ListItem as AccountType , 
li4.ListItem as AmountType,licp.ValueList,pba.Value,
pba.Sequence
from person p
inner join Office o on o.OrganizationId=p.OrganizationId
inner join PersonUserType pt on pt.PersonId=p.PersonId
inner join ListItem li on li.ListItemId=pt.StatusListItemId
inner join ListItemCategory lic on lic.ListItemCategoryId=li.ListItemCategoryId
inner join ListItemCategoryProperty licp on licp.ListItemCategoryId=lic.ListItemCategoryId
inner join PersonBankAccount pba on pba.PersonId=p.PersonId
inner join bank b on b.BankId=pba.BankId
inner join ListItem li2 on li2.ListItemId=pba.StatusListItemId 
inner join ListItem li3 on li3.ListItemId=pba.AccountTypeListItemId
inner join ListItem li4 on li4.ListItemId=pba.AmountTypeListItemId
where pba.Sequence =0
order by p.PersonId desc


--2)	List out employee missing residence address.

select  distinct p.personid,CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName)AS FullName,li.ListItem From Person p
inner join Employee e on e.PersonId=p.PersonId
inner join PersonAddress pa on pa.PersonId=e.PersonId
inner join Address a on a.AddressId=pa.AddressId
inner join ListItem li on li.ListItemId=a.AddressTypeListItemId
where p.PersonId=1000096559
and dbo.SfListItemGet(a.AddressTypeListItemId)<>'Resident'
--shows onlly previous address though the person has resident as address.

---------------------------------
---revised code

   	SELECT p.PersonId,p.FirstName,li.listitem
FROM Employee AS e
INNER JOIN Person AS p ON p.PersonId=e.PersonId
	inner join PersonAddress pa on pa.PersonId=e.PersonId
				inner join Address a on a.AddressId=pa.AddressId
				inner join ListItem li on li.ListItemId=a.AddressTypeListItemId
WHERE not  EXISTS (SELECT 1
				From Person pe
				inner join Employee e on e.PersonId=pe.PersonId
				inner join PersonAddress pa on pa.PersonId=e.PersonId
				inner join Address a on a.AddressId=pa.AddressId
				inner join ListItem li on li.ListItemId=a.AddressTypeListItemId
				   WHERE li.ListItem='Resident' AND pe.PersonId=e.PersonId )
ORDER BY p.FirstName



--3)	Find out the person whose Person Role is different from Role in User Table

select top 1*from Person
select top 1*from [User]
select top 1*from PersonRole
select *from Role

--select distinct p.personId,p.FirstName,pr.RoleId,r.Role as PersonTable,u.UserName,u.RoleId,ur.Role as UserTable from person p
--inner join [User] u on u.PersonId=p.PersonId
--inner join role r on r.RoleId=u.RoleId
--inner join PersonRole pr on pr.PersonId=u.PersonId
--inner join role ur on ur.RoleId=u.RoleId
--where  pr.RoleId!=u.RoleId
;



with PersonRoleInPerson as(
select distinct p.personId,p.FirstName,pr.RoleId as PersonRoleId,r.Role as PersonRole from person p
inner join PersonRole pr on pr.PersonId=p.PersonId
inner join role r on r.RoleId=pr.RoleId
)
,
UserRoleInUserTable as (

select distinct p.personId,p.FirstName,u.RoleId as UserRoleId,r.Role as UserRole from person p
inner join [user] u on u.PersonId=p.PersonId
inner join role r on r.RoleId=u.RoleId
)

select distinct p.personId,p.FirstName,ur.UserRoleId, ur.UserRole,
prr.PersonRoleId,prr.PersonRole from person p
inner join UserRoleInUserTable ur on ur.personid=p.personid
inner join PersonRoleInPerson prr on prr.PersonId=p.PersonId
where ur.UserRole <> prr.PersonRole

select top 2*from PersonRole
select top 2 *from [User]

--4)	Find out the person whose Person Role and person application has different Applicantid.

select top 1*from Applicant
 --
select top 1*from PersonCurrent
select top 1 *from PersonRole 
select top 1*from PersonApplication
select top 1 *from role


select p.PersonId,
    CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
    pr.ApplicationId AS PersonRoleApplicantId,
    pa.ApplicationId AS PersonApplicationApplicantId from Person p
	inner join PersonApplication pa on pa.PersonId=p.PersonId
inner join PersonRole pr on pr.PersonId=p.PersonId
where 
P.PersonId  IN(
SELECT DISTINCT P.PersonId FROM Person
inner join PersonApplication pa on pa.PersonId=p.PersonId
inner join PersonRole pr on pr.PersonId=p.PersonId
WHERE PR.ApplicationId <> PA.ApplicationId
)





--5)	Person Table title and Person current Entity are different.

select top 2*from person
select top 2*from PersonCurrent 

select p.PersonId,
    CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
	p.Title AS PersonTitle,
    li.ListItem AS PersonCurrentEntity  From person p
inner join PersonCurrent pc on pc.PersonId=p.PersonId
inner join listitem li on li.listitemid=pc.entitylistitemid
where p.Title <> li.ListItem
order by 1 desc


--6)	Person and person tax whose Mandatory tax parameter is missing.

select distinct p.personId,p.FirstName,p.LastName,tp.IsRequired,tc.Description  From Person p
	inner join PersonTax pt on pt.PersonId=p.PersonId
	inner join TaxParameter tp on tp.TransactionCodeId=pt.TransactionCodeId
   INNER JOIN TransactionCode tc on tc.TransactionCodeId=tp.TransactionCodeId
	where tp.IsRequired <>1 
	order by 1 desc