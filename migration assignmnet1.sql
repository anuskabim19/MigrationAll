---------migration assignment-------\


 --q1  7)List out the Customer missing worksite address. (List: Customerid, name, Departmentname, status)
 -- after correction code
  SELECT DISTINCT 
    o.OrganizationId,
    o.Organization,
    o.Department as DepartmentName,
 dbo.SfListItemGet (OC.EntityListItemId) as EntityList,
 dbo.SfListItemGet (a.StatusListItemId) as Status,
 li.ListItem

FROM Organization o
inner JOIN OrganizationAddress oa ON oa.OrganizationId = o.OrganizationId
inner join OrganizationCurrent oc on oc.OrganizationId=o.OrganizationId
    inner join Address a on a.AddressId = oa.AddressId
	inner join listitem li on li.ListItemId=a.AddressTypeListItemId
	--where a.StatusListItemId =  dbo.SfListItemIdGet('Status', '') 

and o.OrganizationId NOT IN (
    SELECT distinct o2.OrganizationId
    FROM Organization o2
    inner JOIN OrganizationAddress oa2 ON oa2.OrganizationId = o2.OrganizationId
    inner JOIN Address a2 ON a2.AddressId = oa2.AddressId
    inner JOIN listitem lt2 ON lt2.listitemid = a2.AddressTypeListItemId
    WHERE lt2.ListItem ='Jobsite' 
)
AND dbo.SfListItemGet (OC.EntityListItemId) IN ( 'Customer', 'NewCustomer', 'Target', 'Lead' )


	

 ---------------------------------------------------------------------------------------------------------------------------------
 ---q2 8)List out the customer having single department. (List: Customerid, name, Departmentname, status)
 -- if parent is null and root is the same as org then thats the department...check with that.

--corrected
	SELECT  *
FROM   dbo.Organization AS o
WHERE  o.ParentOrganizationId IS NULL
AND    o.RootOrganizationId IN ( SELECT   o.RootOrganizationId
                                  FROM     Organization o
                                  WHERE    o.ParentOrganizationId IS NOT NULL
                                  GROUP BY o.RootOrganizationId
                                  HAVING   COUNT (DISTINCT o.ParentOrganizationId) = 1
    )
ORDER BY o.RootOrganizationId

-------------------------------------------------------------------------------------------------------------------------------------

--q3  9)List out the Customer having multiple hierarchy department (list root, and its multiple hierarchy customer only)
--corrected code
SELECT  *
FROM   dbo.Organization AS o
WHERE  o.ParentOrganizationId IS NULL
AND    o.RootOrganizationId IN ( SELECT   o.RootOrganizationId
                                  FROM     Organization o
                                  WHERE    o.ParentOrganizationId IS NOT NULL
                                  GROUP BY o.RootOrganizationId
                                  HAVING   COUNT (DISTINCT o.ParentOrganizationId) > 1
    )
ORDER BY o.RootOrganizationId

--------------------------------------------------------------------------------------------------------------------------
--q4 10 ROOT Customer office and its department office are different.


SELECT   
    RT.Organization,
	rt.RootOrganizationId,
RT.OfficeId AS RootOfficeId,
dt.ParentOrganizationId,
    DT.OfficeId AS DepartmentOfficeId

FROM   ( SELECT *
         FROM   dbo.Organization AS O
         WHERE  ParentOrganizationId IS NULL ) AS RT   --if parent is null then they are root org
       LEFT JOIN ( SELECT *
                   FROM   dbo.Organization AS O
                   WHERE  ParentOrganizationId IS NOT NULL ) AS DT  ---if parent is not null then they are departments 
				   ON RT.RootOrganizationId = DT.RootOrganizationId  --both of them have rootorgid that links them together
WHERE  RT.OfficeId <> DT.OfficeId;



SELECT * FROM  dbo.Organization AS O WHERE  O.RootOrganizationId=10285

SELECT * FROM  dbo.Organization AS O WHERE ParentOrganizationId IS NULL AND  O.RootOrganizationId=10285

SELECT * FROM  dbo.Organization AS O WHERE ParentOrganizationId IS NOT NULL AND  O.RootOrganizationId=10285

----------------------------------------------------------------------------------------------------------------------

--q5 Find and list out the Assignment information with person information, job information for following cases:

---a) Assignment missing assignment rate. 
--correct 
SELECT
    a.AssignmentId,
    p.PersonId,
    p.FirstName,
    p.LastName,
    j.JobId,
    j.JobTitle,
    a.OfficeId
   
FROM
    Assignment a
    inner JOIN AssignmentRate ar ON ar.AssignmentId = a.AssignmentId
    inner JOIN Person p ON p.PersonId = a.PersonId
    inner JOIN Job j ON j.JobId = a.JobId
WHERE
    ar.AssignmentRateId is not null


	---------------------------------------------------------------------------------------------

-- b) Assignment missing OT rate.
--corrected
	SELECT 
    a.AssignmentId,
    a.PersonId,
    p.FirstName,
    p.LastName,
    j.JobTitle,
    ar.TransactionCodeId
FROM 
    Assignment a
    INNER JOIN Person p ON a.PersonId = p.PersonId
    INNER JOIN Job j ON a.JobId = j.JobId
    INNER JOIN AssignmentRate ar ON a.AssignmentId = ar.AssignmentId
WHERE 
    a.AssignmentId NOT IN (
        SELECT 
            ar1.AssignmentId
        FROM 
            AssignmentRate ar1
        INNER JOIN TransactionCode tc1 ON ar1.TransactionCodeId = tc1.TransactionCodeId
        WHERE 
            tc1.Description LIKE '%OT%' 
    )
	-------------------------------------------------
	--c)Assignment have same multiple transaction code.

--refined
   select  a.AssignmentId,
    a.PersonId,
    p.FirstName,
    p.LastName,
    j.JobTitle ,
	tc.TransactionCode
	from assignment a
	 INNER JOIN Person p ON a.PersonId = p.PersonId
    INNER JOIN Job j ON a.JobId = j.JobId
    INNER JOIN AssignmentRate ar ON a.AssignmentId = ar.AssignmentId
    INNER JOIN TransactionCode tc ON ar.TransactionCodeId = tc.TransactionCodeId

	where a.AssignmentId in(
	select ar.transactioncodeid from AssignmentRate ar
	group by  ar.transactioncodeid
	having count(ar.TransactionCodeId)>1
	)

select *From AssignmentRate
   ------------------------------------------------------------

   --d)Assignment StartDate is greater than End Date.

   SELECT
    a.AssignmentId,
    a.PersonId,
    p.FirstName,
    p.LastName,
    j.JobTitle,
    a.StartDate,
    a.EndDate
FROM
    Assignment a
    INNER JOIN Person p ON a.PersonId = p.PersonId
    INNER JOIN Job j ON a.JobId = j.JobId
WHERE
    a.StartDate > a.EndDate

	select *From Assignment where StartDate>EndDate

-----------------------------------------------------------------------------

--e)Assignment has End Date but End Reason is missing.

SELECT distinct  a.AssignmentId,
    a.PersonId,
    p.FirstName,
    p.LastName,
    j.JobTitle,
	lt.ListItem,lt.Description,ltc.Category,ltc.Description
FROM Assignment a
INNER JOIN Person p ON a.PersonId = p.PersonId
INNER JOIN Job j ON a.JobId = j.JobId
INNER JOIN ListItem lt ON lt.ListItemId = a.EndReasonListItemId
INNER JOIN ListItemCategory ltc ON ltc.ListItemCategoryId = lt.ListItemCategoryId    
WHERE a.EndDate IS NOT NULL
 and a.EndReasonListItemId IS NULL;


select *From Assignment where EndReasonListItemId is null and EndDate is not null







