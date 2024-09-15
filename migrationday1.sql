exec sp_helptext SpApplicantDataImport
----------------for import-----------------
select *from import as i
inner join ImportBatch ib on ib.ImportId=i.ImportId
inner join ImportParameter ip on ip.ImportId=i.ImportId
inner join ImportBatchData ibd on ibd.importbatchid=ib.ImportBatchId
inner join ImportBatchException ibe on ibe.importbatchid=ib.ImportBatchId
 

 select *from ImportBatchException as ib order by 1 desc
 select *From ImportBatchData

 ----------for mapping-----------
 select *from MappingType as mt
 inner join Mapping m on m.MappingTypeId=mt.MappingTypeId
 inner join MappingData md on md.MappingId=m.MappingId
 where MapFrom='Communications-computer systems control specialist'

 select *from MappingType where MappingType='FridayStaffing'
 select *from Mapping where MappingTypeId=200017 AND Mapping='CustomerStatus'
 select *from MappingData where MappingId=20301

 select *from ListItem lt
 inner join ListItemCategory lc on  lc.ListItemCategoryId= lt.ListItemCategoryId
 where lc.Category='AddressType' and lt.ListItem='JobSite'

 select lc.ListItem,*from Person p
inner join PersonCurrent pc on pc.PersonId=p.PersonId
inner join ListItem lc on lc.ListItemId=pc.EntityListItemId
inner join ListItemCategory lic on lic.ListItemCategoryId= lc.ListItemCategoryId
where p.PersonId=1000340733 AND lic.Category LIKE '%Status%'

--jobsite

select *from ListItemCategory--active inactive
select *from ListItem where Description='active'
select *From Address


select  count(*) From Person

 select lc.ListItem,count(*)from Person p
inner join PersonCurrent pc on pc.PersonId=p.PersonId
inner join ListItem lc on lc.ListItemId=pc.EntityListItemId
--where lc.ListItem='OfficeStaff' 
group by lc.ListItem


 select top 5 lc.ListItem, ap.*from Person p
inner join PersonCurrent pc on pc.PersonId=p.PersonId
inner join ListItem lc on lc.ListItemId=pc.EntityListItemId
inner join Applicant ap on ap.PersonId=p.PersonId
where lc.ListItem='Employee' 



 select top 5 lc.ListItem, ap.*from Person p
inner join PersonCurrent pc on pc.PersonId=p.PersonId
inner join ListItem lc on lc.ListItemId=pc.EntityListItemId
inner join NewHire ap on ap.PersonId=p.PersonId
where lc.ListItem='Employee' 



 select top 5 lc.ListItem, ap.StatusListItemId,li.ListItem,*from Person p
inner join PersonCurrent pc on pc.PersonId=p.PersonId
inner join ListItem lc on lc.ListItemId=pc.EntityListItemId
inner join Employee ap on ap.PersonId=p.PersonId
inner join ListItem li on li.ListItemId=ap.StatusListItemId
where lc.ListItem='Employee' 


SELECT lic.ListItemCategoryId ,
       lic.Category ,
       li.ListItem ,
       li.ListItemId ,
       licp.Property ,
       lip.ListItemPropertyId ,
       lip.Value ,
       lip.*
FROM   dbo.ListItem AS li
       INNER JOIN dbo.ListItemCategory AS lic ON lic.ListItemCategoryId = li.ListItemCategoryId
       INNER JOIN dbo.ListItemCategoryProperty AS licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
       INNER JOIN dbo.ListItemProperty AS lip ON  lip.ListItemCategoryPropertyId = licp.ListItemCategoryPropertyId
                                              AND lip.ListItemId = li.ListItemId
WHERE  licp.Property LIKE '%relatesTo%'
AND    lic.Category LIKE '%Status%'
AND    lip.Value LIKE '%%';





--where FirstName='anjal'

select *from personcurrent

select *From ListItemCategory where category like '%AddressType%'
select *From listitem where listitemcategoryid=200008


select *from person where PersonId=1000340733

--select  l.listitem ffrom listitm l
--inner join

select *from payment
select top 5*from TransactionFinance
where transactionId=1

select lt.ListItem, tc.transactionCode,*from transactionItem  ti
inner join TransactionCode tc on  tc.TransactionCodeId=ti.TransactionCodeId
inner join TransactionType tt on tt.TransactionTypeId=tc.TransactionTypeId
inner join ListItem lt on lt.ListItemId=tt.TransactionTypeId
where TransactionId=1


--inner join TransactionFinance tf on tf.TransactionId=
--where transactionId=1

select  *From MappingType
select *from Mapping
select *from MappingData
select *from MappingType

select *from Mapping where MappingTypeId=200017 AND MappingType like '%Employee_Status%'

 select *from MappingType as mt
 inner join Mapping m on m.MappingTypeId=mt.MappingTypeId
 inner join MappingData md on md.MappingId=m.MappingId
 where m.Mapping='Employee_Status'





 --select *from Organization o
 -- inner join OrganizationAddress oa on oa.OrganizationId=O.OrganizationId
 --inner join Address a on a.AddressId=oa.AddressId
 --where a.Address1  is null

 select *From ImportBatchData
 select *from ImportBatch
 select *from Import
 select *from MappingData md
 inner join Mapping m on m.MappingId=md.MappingId
 where Mapping like '%Organization%'
