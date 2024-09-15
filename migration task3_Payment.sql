--Payment

--1.	Write a query to find the Check Equation issue.

SELECT distinct PaymentId, CheckNumber, Gross, Reimbursement, Tax, Deduction, Advance, Net, 
       (Gross - Tax  - Deduction - Advance + Reimbursement ) AS CalculatedTotalNet
FROM payment
WHERE Net <> (Gross - Tax  - Deduction - Advance + Reimbursement );

select *From Payment --43015


--6.	Payment Missing Federal Income Tax.

select DISTINCT
       tc.transactioncodeid,
       p.PersonId,
	   CONCAT_WS(' ', p.FirstName, ISNULL(p.MiddleName, ''), p.LastName) AS FullName,
	   p.Title,
	   tc.Description,
	   pt.MTD,
	   pt.QTD,
	   pt.YTD,
	   pt.LTD,
	   tp.Parameter,
	   tp.Description AS TaxParameterDescription,
	   tp.IsRequired
from Person p
inner join PersonTax pt ON pt.PersonId = p.PersonId
inner join  transactioncode tc ON tc.transactioncodeid = pt.transactioncodeid
inner join tax t ON t.transactioncodeId = tc.transactioncodeId
inner join taxparameter tp ON tp.transactioncodeId = tc.transactioncodeid
WHERE 
   tc.Description <>'Federal Income Tax' 




--4.	Check has FICA EE Tax but not equals to FICA ER Tax .

WITH FicaTax AS (
    SELECT distinct
        ptt.PaymentId,
        t.TransactionCodeId,
        tc.Description,
        t.IsEmployerTax,
        p.Tax as TaxAmount
    FROM 
        tax t
    INNER JOIN 
        TransactionCode tc ON tc.TransactionCodeId = t.TransactionCodeId
		inner join PersonTax pt on pt.TransactionCodeId=tc.TransactionCodeId
		inner join PaymentTax ptt on ptt.PersonTaxId=pt.PersonTaxId
		inner join Payment p on p.PaymentId=ptt.PaymentId
    WHERE 
        tc.Description LIKE '%FICA Tax%'
),

EmployeeTax AS (
    SELECT distinct
      ptt.PaymentId,
      sum(p.tax) AS EmployeeFicaTax
    FROM 
        TransactionCode tc
		inner join tax t on t.TransactionCodeId= tc.TransactionCodeId
		inner join PersonTax pt on pt.TransactionCodeId=tc.TransactionCodeId
		inner join PaymentTax ptt on ptt.PersonTaxId=pt.PersonTaxId
		inner join Payment p on p.PaymentId=ptt.PaymentId

    WHERE 
        IsEmployerTax = 0
		and tc.Description LIKE '%FICA Tax%'
    GROUP BY 
        ptt.PaymentId,p.tax
),


EmployerTax AS (
   SELECT distinct
      ptt.PaymentId,
      sum
	  (p.tax) AS EmployerFicaTax
    FROM 
        TransactionCode tc
		inner join tax t on t.TransactionCodeId= tc.TransactionCodeId
		inner join PersonTax pt on pt.TransactionCodeId=tc.TransactionCodeId
		inner join PaymentTax ptt on ptt.PersonTaxId=pt.PersonTaxId
		inner join Payment p on p.PaymentId=ptt.PaymentId

    WHERE 
        IsEmployerTax = 1 and tc.Description LIKE '%FICA Tax%'
    GROUP BY 
        ptt.PaymentId,p.tax
)


SELECT  distinct
    p.checknumber,
    e.PaymentId,
    e.EmployeeFicaTax,
    r.EmployerFicaTax,
	 tc.TransactionCodeId,
     tc.Description,
	 t.IsEmployerTax
    
FROM 
    EmployeeTax e
INNER JOIN 
    EmployerTax r ON e.PaymentId = r.PaymentId
	inner join Payment p on p.PaymentId=r.PaymentId
	inner join PaymentTax pt on pt.PaymentId=r.PaymentId
	inner join PersonTax ptt on ptt.PersonTaxId=pt.PersonTaxId
	inner join TransactionCode tc on tc.TransactionCodeId=ptt.TransactionCodeId
	inner join tax t on t.TransactionCodeId=tc.TransactionCodeId
WHERE 
    e.EmployeeFicaTax <> r.EmployerFicaTax

	and   
        tc.Description LIKE '%FICA Tax%'



--5.	Check has MEDI EE Tax but not equals but MEDI ER Tax .

with EmployeeMedi as(
	       SELECT tptds.PaymentId,tptds.TransactionType,tptds.TransactionTypeDescription,tptds.TransactionCodeDescription,sum(tptds.Tax) as TotalEmployeeTax
                                           FROM   dbo.TfPaymentTaxDataSel (2)AS tptds
										   inner join tax t on t.TransactionCodeId=tptds.TransactionCodeId   
                                           WHERE  tptds.IsEmployerTax = 0
                                           AND    tptds.TransactionType = 'MEDI'
										     GROUP BY 
      tptds.PaymentId,tptds.TransactionType,tptds.TransactionTypeDescription,TransactionCodeDescription,tptds.Tax
  ),

 EmployerMedi as(
	       SELECT tptds.PaymentId,tptds.TransactionType,tptds.TransactionTypeDescription,tptds.TransactionCodeDescription,sum(tptds.Tax) as TotalEmployerTax
                                           FROM   dbo.TfPaymentTaxDataSel (2)AS tptds
										   inner join tax t on t.TransactionCodeId=tptds.TransactionCodeId   
                                           WHERE  tptds.IsEmployerTax = 1
                                           AND    tptds.TransactionType = 'MEDI'
										   group by
										   tptds.PaymentId,tptds.TransactionType,tptds.TransactionTypeDescription,TransactionCodeDescription,tptds.Tax
  )

  select  tptds.checknumber,
    tptds.PaymentId,
    e.TotalEmployeeTax,
    r.TotalEmployerTax,
	 tptds.TransactionCodeId,
     tptds.Description,
	 tptds.IsEmployerTax from  dbo.TfPaymentTaxDataSel (2)AS tptds

	 inner join EmployeeMedi e on e.PaymentId=tptds.PaymentId
INNER JOIN 
    EmployerMedi r ON e.PaymentId = r.PaymentId
WHERE 
    e.TotalEmployeeTax <> r.TotalEmployerTax
	and tptds.TransactionType = 'medi'
	and e.TotalEmployeeTax != 0

	
--3.Check with total employer tax not equal to total employer tax from transaction.

with EmployerTaxFromCheck as(
select p.paymentId,SUM (P.Tax) as EmployerTaxFromCheck1,t.IsEmployerTax from Payment p
inner join PaymentTax pt on pt.PaymentId=p.paymentId
inner join persontax ptt on ptt.PersonTaxId=pt.PersonTaxId
inner join TransactionCode tc on tc.TransactionCodeId=ptt.TransactionCodeId
inner join tax t on t.TransactionCodeId=tc.TransactionCodeId
where t.IsEmployerTax=1
 group by p.PaymentId,p.Tax,t.IsEmployerTax
 ),

EmployerTaxFromTransction as(
 select tf.TransactionId,sum(tf.EmployerTax) as EmployerTaxFromTransction1 from TransactionItem ti
 inner join TransactionFinance tf on tf.TransactionId=ti.TransactionId
 inner join transactioncode tc on tc.TransactionCodeId=ti.TransactionCodeId
 group by tf.TransactionId,tf.EmployerTax 
 )

 select p.CheckNumber,p.paymentId,ec.EmployerTaxFromCheck1,t.IsEmployerTax, tf.TransactionId,et.EmployerTaxFromTransction1
 from Payment p
inner join PaymentTax pt on pt.PaymentId=p.paymentId
inner join persontax ptt on ptt.PersonTaxId=pt.PersonTaxId
inner join TransactionCode tc on tc.TransactionCodeId=ptt.TransactionCodeId
inner join TransactionItem ti on ti.TransactionCodeId=tc.TransactionCodeId
inner join TransactionFinance tf on tf.TransactionId=ti.TransactionId
inner join tax t on t.TransactionCodeId=tc.TransactionCodeId
inner join EmployerTaxFromCheck ec on ec.PaymentId=pt.PaymentId
inner join EmployerTaxFromTransction et on et.TransactionId=ti.TransactionId

where ec.EmployerTaxFromCheck1 <> et.EmployerTaxFromTransction1



--2.Check with total employee tax not equal to total employee tax from check tax.


with TotalEmployeeTax as (
select distinct p.checknumber,pyt.paymentid,sum(pyt.tax) as TotalPaymentTax,t.IsEmployerTax as Employee from PaymentTax pyt
inner join Payment p on p.PaymentId=pyt.PaymentId
inner join PersonTax pt on pt.PersonTaxId=pyt.PersonTaxId
inner join TransactionCode  tc on tc.TransactionCodeId=pt.transactioncodeid
inner join tax t on t.TransactionCodeId=tc.transactioncodeid
where t.IsEmployerTax=0
group by p.CheckNumber,pyt.PaymentId,pyt.Tax,t.IsEmployerTax
),


 TotalEmployeeTaxFromCheck as(
 select distinct p.CheckNumber,p.paymentid,sum(p.Tax) as TotalTaxFromCheck,t.isemployertax as Employee from Payment p
 inner join paymenttax pyt on pyt.PaymentId=p.PaymentId
 inner join PersonTax pt on pt.PersonTaxId=pyt.PersonTaxId
inner join TransactionCode  tc on tc.TransactionCodeId=pt.transactioncodeid
inner join tax t on t.TransactionCodeId=tc.transactioncodeid
where t.IsEmployerTax=0
group by p.CheckNumber,p.PaymentId,p.Tax,t.IsEmployerTax
)

select distinct p.checknumber,et.TotalPaymentTax,ec.TotalTaxFromCheck,t.isemployertax from payment p
 inner join paymenttax pyt on pyt.PaymentId=p.PaymentId
inner join persontax ptt on ptt.PersonTaxId=pyt.PersonTaxId
inner join TransactionCode  tc on tc.TransactionCodeId=ptt.transactioncodeid
inner join tax t on t.TransactionCodeId=tc.transactioncodeid
inner join TotalEmployeeTax et on et.PaymentId=p.PaymentId
inner join TotalEmployeeTaxFromCheck ec on ec.PaymentId=p.PaymentId

where et.TotalPaymentTax <> ec.TotalTaxFromCheck
and t.IsEmployerTax=0

select top 2 *from TimeClock
select top 2 *from NewHire
select top 2 *from DirectHireJob 
select top 2 *from employee
select top 2 *from TransactionBatch where Note like '%Tonico Batch%'
select *from MappingData order by 1 desc