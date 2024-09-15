select *From Customer
select *from Job where OrganizationId=10473
select *from Assignment where jobid=131128

select *From [Transaction] t
inner join TransactionLink tl on tl.TransactionId=t.transactionid
inner join Payment p on p.PaymentId=tl.PaymentId
where p.PaymentId=48

select *From [Transaction] t
inner join TransactionLink tl on tl.TransactionId=t.transactionid
inner join Invoice i on i.InvoiceId=tl.InvoiceId
where i.InvoiceId=3


where AssignmentId=1948
select *from AssignmentRate

select *from ARBatch
select *from invoice
select *from invoicebatch
select *from InvoicePayment where InvoiceId=581


select *from invoice i
inner join InvoicePayment ip on ip.InvoiceId=i.InvoiceId
inner join ARBatch arb on arb.ARBatchId=ip.ARBatchId
where ip.InvoiceId=204
--==============================================================================================
select *From Employee 
where PersonId=1000340766


--person and contact
select *from Person where PersonId=1000340766
select *from PersonCurrent where PersonId=1000340766
select *from PersonEducation where PersonId=1000340766
select *from PersonContactInformation where PersonId=1000340766
select *from ContactInformation where ContactInformationId=5750475
select *from ContactInformation where ContactInformationId=5750476
select *from ContactInformation where ContactInformationId=5750515
order by 1 desc

select *from bank
---bankaccount
select b.bankid,pa.Bank,b.RoutingNumber,pa.AccountNumber,li.ListItem,li2.listitem,pa.Value,li3.listitem,pa.Sequence from PersonBankAccount pa
inner join Bank b on b.BankId=pa.BankId
inner join listitem li on li.ListItemId=pa.AccountTypeListItemId 
inner join listitem li2 on li2.ListItemId=pa.AccountTypeListItemId 
inner join listitem li3 on li3.ListItemId=pa.StatusListItemId 
where pa. PersonId=1000340766

select *from Deduction
select *from TransactionFinance
select li.listitem,*from TransactionLink tl 
inner join listitem li on li.ListItemId=tl.PayPeriodListItemId
select *from TransactionItem;
select *from PersonCurrent


--------deduction
select pa.PersonId,tc.TransactionCode,li.ListItem,pa.Adjustment,li1.ListItem,pa.Reference,*from PersonAdjustment pa
inner join deduction d on d.TransactionCodeId=pa.TransactionCodeId
inner join TransactionCode tc on tc.TransactionCodeId=pa.TransactionCodeId
inner join ListItem li on li.ListItemId=pa.AdjustmentTypeListItemId
inner join ListItem li1 on li1.ListItemId=pa.StatusListItemId
where personid=1000340766


--------employee tax

select pa.personid,tc.TransactionCode,tc.Description,tp.Parameter,tp.Description,tpv.Value,*From PersonTax pa
inner join TransactionCode tc on tc.TransactionCodeId=pa.TransactionCodeId
inner join tax t on t.TransactionCodeId=tc.TransactionCodeId
inner join TaxParameter tp on tp.TransactionCodeId=t.TransactionCodeId
inner join TaxParameterValue tpv on tpv.TaxParameterId=tp.TaxParameterId
where PersonId=1000340766
and t.IsEmployerTax=0


-------employer tax

select pa.personid,tc.TransactionCode,tc.Description,tp.Parameter,tp.Description,*From PersonTax pa
inner join TransactionCode tc on tc.TransactionCodeId=pa.TransactionCodeId
inner join tax t on t.TransactionCodeId=tc.TransactionCodeId
inner join TaxParameter tp on tp.TransactionCodeId=t.TransactionCodeId
--inner join TaxParameterValue tpv on tpv.TaxParameterId=tp.TaxParameterId
where pa.PersonId=1000340766
and t.IsEmployerTax=1

select *from Tax
select *From TaxParameterValue
select *from PersonAdjustment
-------payperiod

select li.listitem,*from TransactionLink tl 
inner join listitem li on li.ListItemId=tl.PayPeriodListItemId

select *from PersonTaxParameter


----------------======================================================================================
---for assignmnet


select dbo.SfListItemGet (a.StatusListItemId) as Status,dbo.SfListItemGet (a.addresstypelistitemid) as addressstatus,*from Organization o
inner JOIN OrganizationAddress oa ON oa.OrganizationId = o.OrganizationId
inner join Address a on a.AddressId = oa.AddressId
where o.Organizationid=201179 

select *From PersonAddress
select *from organizationaddress
select *from address where City like '%Morrisville North Carolina%'
select *from location where county like '%Morrisville North Carolina%'

select a.Address1, a.Address2, * from OrganizationAddress oa
inner join Address a on a.AddressId = oa.AddressId
inner join Organization o on o.OrganizationId = oa.OrganizationId
inner join Customer c on c.OrganizationId = o.OrganizationId
where o.OrganizationId = 201179

select * from Assignment a where a.AssignmentId = 7878

select a.Address1, a.Address2, * from PersonAddress pa 
inner join Address a on a.AddressId = pa.AddressId
inner join Person p on p.PersonId = pa.PersonId
where p.PersonId = 1000340766

select * from Address a 
where Address1 like '%Morrisville%north'


select * from TempJob tj
inner join job j on j.JobId = tj.JobId
where tj.JobId =  138429


---current status assignment ko status ho


SELECT dbo.SfListItemGet(j.WorksiteSourceListItemId), * FROM dbo.TempJob AS tj
INNER JOIN dbo.Job AS j ON j.JobId = tj.JobId
WHERE tj.JobId = 138430

SELECT a.Address1, a.Address2, a.City, s.State, * FROM dbo.OrganizationAddress AS oa
INNER JOIN dbo.Address AS a ON a.AddressId = oa.AddressId
INNER JOIN State s ON s.StateId = a.StateId
WHERE oa.OrganizationAddressId = 214783

select p.personid as EmployeeId,concat(p.FirstName,' ',p.LastName) as Name ,cif.Value as Phone,ef.Value as Email,*
from person p 
inner join PersonContactInformation pci on pci.PersonId=p.PersonId
inner join (select ci.ContactInformationId,ci.value from ContactInformation ci where ci.ContactInformationId=5750475) as cif
on pci.ContactInformationId=cif.ContactInformationId
inner join (select ci.ContactInformationId,ci.value from ContactInformation ci where ci.ContactInformationId=5750476) as ef
on pci.ContactInformationId=cif.ContactInformationId
where p.PersonId=1000340766

select *From ContactInformation

select dbo.SfListItemGet (a.StatusListItemId) as Status,dbo.SfListItemGet (a.addresstypelistitemid) as addressstatus,*from Organization o
inner JOIN OrganizationAddress oa ON oa.OrganizationId = o.OrganizationId
inner join Address a on a.AddressId = oa.AddressId
where o.Organizationid=201179 

select o.organization as Customer ,o.Department,dbo.SfListItemGet (a.assignmenttypelistitemid) as Status,
cif.Value as Phone,ef.Value as Email
from Organization o
inner join assignment a on a.OfficeId=o.OfficeId
inner join Person p on p.PersonId=a.PersonId
inner join PersonContactInformation pci on pci.PersonId=p.PersonId
inner join (select ci.ContactInformationId,ci.value from ContactInformation ci where ci.ContactInformationId=5750475) as cif
on pci.ContactInformationId=cif.ContactInformationId
inner join (select ci.ContactInformationId,ci.value from ContactInformation ci where ci.ContactInformationId=5750476) as ef
on pci.ContactInformationId=cif.ContactInformationId
where o.Organizationid=201179 

select li.listitem,*from assignment a
inner join listitem li on li.ListItemId=a.assignmenttypelistitemid where li.ListItem like '%c%'
--=================================================================


---EIS info


select o.organization as Customer ,o.Department,dbo.SfListItemGet (a.assignmenttypelistitemid) as Status,
ar.Location  ,cif.Value as Phone,ef.Value as Email,ofi.Office,jbb.JobTitle as JobPosition,wco.WCCode,
pyp.ListItem as PayPeriod,rate.PayRate,rate.BillRate,jbb.JobId,se.StartDate,se.EndDate,er.ListItem as EndReason,
pf.ListItem as Performance
from Organization o
inner join assignment a on a.OfficeId=o.OfficeId
inner join (select concat (a.City,' ',s.State) as Location,od.OrganizationId from organization o 
inner join OrganizationAddress od on od.OrganizationId=o.OrganizationId
inner join Address a on a.AddressId=od.AddressId
INNER JOIN State s ON s.StateId = a.StateId
 WHERE od.OrganizationAddressId = 214783)as ar on o.OrganizationId=ar.OrganizationId
inner join Person p on p.PersonId=a.PersonId
inner join PersonContactInformation pci on pci.PersonId=p.PersonId
inner join (select ci.ContactInformationId,ci.value from ContactInformation ci where ci.ContactInformationId=5750475) as cif
on pci.ContactInformationId=cif.ContactInformationId
inner join (select ci.ContactInformationId,ci.value from ContactInformation ci where ci.ContactInformationId=5750476) as ef
on pci.ContactInformationId=cif.ContactInformationId
inner join office ofi on ofi.officeid=o.officeid
inner join (select jb.jobid,jb.jobtitle,jb.OrganizationId from  job jb where jb.JobId=138429) as jbb on
jbb.OrganizationId=o.OrganizationId
--inner join shift sf on sf.OrganizationId=o.OrganizationId
inner join(select wc.WCCodeId,wcc.WCCode,wc.NodeId From Office j
inner join WCCodeNode wc on wc.NodeId=j.nodeid
inner join WCCode wcc on wcc.WCCodeId=wc.WCCodeId 
where wcc.WCCodeId=20108 and j.OfficeId=200001) as wco on
wco.NodeId=ofi.NodeId
inner join (select distinct li.listitem,tl.OrganizationId from TransactionLink tl inner join listitem li on li.ListItemId=tl.PayPeriodListItemId) as pyp
on pyp.OrganizationId=o.OrganizationId
inner join(select ti.BillRate,ti.PayRate,tl.OrganizationId from TransactionItem tiinner join TransactionLink tl on tl.TransactionId=ti.TransactionIdinner join Organization o on o.OrganizationId=tl.OrganizationId where ti.TransactionItemId=290492) as rate 
on rate.OrganizationId=o.OrganizationId
inner join (  select a.AssignmentId,a.StartDate,a.EndDate  from Assignment a where jobid=138429) as se on 
se.AssignmentId=a.AssignmentId
inner join (select  a.AssignmentId,li.ListItem from Assignment ainner join listitem li on li.ListItemId=a.EndReasonListItemId) as er 
on er.AssignmentId=a.AssignmentId
inner join(select li.ListItem,a.AssignmentId  from Assignment ainner join listitem li on li.ListItemId=a.PerformanceListItemId) as pf
on pf.AssignmentId=a.AssignmentId
where o.Organizationid=201179 



---------------------------------------------------------------------------------

select *from WCCode where StateId=200032

select *from TaxParameterValue

 select li.ListItem,*from office j --nodeid + Wcnode
  inner join ListItem li on li.ListItemId=j.OfficeTypeListItemId

 select *from TransactionFinance

 select li.ListItem From Job j
 inner join ListItem li on li.ListItemId=j.StatusListItemId

 select li.ListItem, *from assignment a
  inner join ListItem li on li.ListItemId=a.assignmenttypelistitemid   where ListItem like '%current%'
    inner join ListItem li2 on li2.ListItemId=a.StatusListItemId
 where jobid=138430

 select *from listitem li
 inner join ListItemCategory lic on lic.ListItemCategoryId=li.ListItemCategoryId
 inner join ListItemCategoryProperty lip on lip.ListItemCategoryId=lic.ListItemCategoryId
  where ListItem like '%current%'

  select *from Organization where OrganizationId=201179
  select *from Assignment where jobid=138429
  select *from job where OrganizationId=201179