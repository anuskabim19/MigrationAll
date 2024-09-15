--Payment

--1.	Write a query to find the Check Equation issue.
--Check Eqn: Gross - Tax + Reimbursement - Deduction
--correct code
SELECT distinct PaymentId, CheckNumber, Gross, Reimbursement, Tax, Deduction, Advance, Net, 
       (Gross - Tax  - Deduction - Advance + Reimbursement ) AS CalculatedTotalNet
FROM payment
WHERE Net <> (Gross - Tax  - Deduction - Advance + Reimbursement );

select *From Payment --43015


--6.	Payment Missing Federal Income Tax.

 ----------------------------------------
 ---revised code

select p.PaymentId,tc.Description from payment p
inner join paymenttax pt on pt.paymentid=p.paymentid
inner join persontax ptt on ptt.PersonTaxId=pt.persontaxid
inner join  transactioncode tc ON tc.transactioncodeid = ptt.transactioncodeid
where p.PaymentId not in (
select p.PaymentId from Payment p
inner join paymenttax pt on pt.paymentid=p.paymentid
inner join persontax ptt on ptt.PersonTaxId=pt.persontaxid
inner join  transactioncode tc ON tc.transactioncodeid = ptt.transactioncodeid
where tc.Description  like '%Federal%'
)




--4.	Check has FICA EE Tax but not equals to FICA ER Tax .
--revised code

with
EmployeeTax AS (
    SELECT distinct
      ptt.PaymentId,
     p.tax AS EmployeeFicaTax
    FROM 
        TransactionCode tc
		inner join tax t on t.TransactionCodeId= tc.TransactionCodeId
		inner join PersonTax pt on pt.TransactionCodeId=tc.TransactionCodeId
		inner join PaymentTax ptt on ptt.PersonTaxId=pt.PersonTaxId
		inner join Payment p on p.PaymentId=ptt.PaymentId

    WHERE 
        IsEmployerTax = 0
		and tc.Description LIKE '%FICA%' 
   
),


EmployerTax AS (
   SELECT distinct
      ptt.PaymentId,
      
	  p.tax AS EmployerFicaTax
    FROM 
        TransactionCode tc
		inner join tax t on t.TransactionCodeId= tc.TransactionCodeId
		inner join PersonTax pt on pt.TransactionCodeId=tc.TransactionCodeId
		inner join PaymentTax ptt on ptt.PersonTaxId=pt.PersonTaxId
		inner join Payment p on p.PaymentId=ptt.PaymentId

    WHERE 
        IsEmployerTax = 1 and tc.Description LIKE '%FICA%'
  
)


SELECT  distinct
    p.checknumber,
    e.PaymentId,
    e.EmployeeFicaTax,
    r.EmployerFicaTax,
	 tc.TransactionCodeId,
     tc.Description
    
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





--5.	Check has MEDI EE Tax but not equals but MEDI ER Tax .

with EmployeeMedi as(
	       SELECT tptds.PaymentId,tptds.TransactionType,tptds.TransactionTypeDescription,tptds.TransactionCodeDescription,tptds.Tax as TotalEmployeeTax
                                           FROM   dbo.TfPaymentTaxDataSel (2)AS tptds
										   inner join tax t on t.TransactionCodeId=tptds.TransactionCodeId   
                                           WHERE  tptds.IsEmployerTax = 0
                                           AND    tptds.TransactionType = 'MEDI'
							
  ),

 EmployerMedi as(
	       SELECT tptds.PaymentId,tptds.TransactionType,tptds.TransactionTypeDescription,tptds.TransactionCodeDescription,tptds.Tax as TotalEmployerTax
                                           FROM   dbo.TfPaymentTaxDataSel (2)AS tptds
										   inner join tax t on t.TransactionCodeId=tptds.TransactionCodeId   
                                           WHERE  tptds.IsEmployerTax = 1
                                           AND    tptds.TransactionType = 'MEDI'
										   
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
--revised code

with EmployerTaxFromCheck as(
select distinct p.paymentId,P.Tax as EmployerTaxFromCheck1 from Payment p
inner join PaymentTax pt on pt.PaymentId=p.paymentId
inner join persontax ptt on ptt.PersonTaxId=pt.PersonTaxId
inner join TransactionCode tc on tc.TransactionCodeId=ptt.TransactionCodeId
inner join tax t on t.TransactionCodeId=tc.TransactionCodeId
where t.IsEmployerTax=1
 ),

EmployerTaxFromTransction as(
 select distinct p.paymentid,tf.EmployerTax as EmployerTaxFromTransction1 from TransactionItem ti
 inner join TransactionFinance tf on tf.TransactionId=ti.TransactionId
 inner join transactioncode tc on tc.TransactionCodeId=ti.TransactionCodeId
 inner join TransactionLink tl on tl.TransactionBatchId=tf.TransactionId
 inner join Payment p on p.PaymentId=tl.PaymentId

 )

 select p.CheckNumber,p.paymentId,ec.EmployerTaxFromCheck1,et.EmployerTaxFromTransction1
 from Payment p
inner join EmployerTaxFromCheck ec on ec.PaymentId=p.PaymentId
inner join EmployerTaxFromTransction et on et.PaymentId=p.PaymentId

where ec.EmployerTaxFromCheck1 <> et.EmployerTaxFromTransction1



--2.Check with total employee tax not equal to total employee tax from check tax.
--revised code

with TotalEmployeeTax as (
select distinct p.checknumber,pyt.paymentid,pyt.tax as TotalPaymentTax from PaymentTax pyt
inner join Payment p on p.PaymentId=pyt.PaymentId
inner join PersonTax pt on pt.PersonTaxId=pyt.PersonTaxId
inner join TransactionCode  tc on tc.TransactionCodeId=pt.transactioncodeid
inner join tax t on t.TransactionCodeId=tc.transactioncodeid
where t.IsEmployerTax=0
),


 TotalEmployeeTaxFromCheck as(
 select distinct p.CheckNumber,p.paymentid,p.Tax as TotalTaxFromCheck from Payment p
 inner join paymenttax pyt on pyt.PaymentId=p.PaymentId
 inner join PersonTax pt on pt.PersonTaxId=pyt.PersonTaxId
inner join TransactionCode  tc on tc.TransactionCodeId=pt.transactioncodeid
inner join tax t on t.TransactionCodeId=tc.transactioncodeid
where t.IsEmployerTax=0
)

select distinct p.checknumber,et.TotalPaymentTax,ec.TotalTaxFromCheck from payment p
inner join TotalEmployeeTax et on et.PaymentId=p.PaymentId
inner join TotalEmployeeTaxFromCheck ec on ec.PaymentId=p.PaymentId

where et.TotalPaymentTax <> ec.TotalTaxFromCheck



--make two cte and last ma in select query compare if the employee tax is not equals to emplyee from payment table

--=================================================================================

--Invoice
--1.	Invoices Missing Organization Address.

-----
select distinct o.organizationid,o.organization,i.InvoiceId,i.InvoiceNumber,i.OrganizationAddressId  from invoice i
left join Organization o on o.OrganizationId=i.OrganizationId
left join OrganizationAddress od on od.OrganizationId=o.OrganizationId 
left join Address ad on ad.AddressId=od.AddressId 
where i.OrganizationAddressId is null
------
--check

select distinct o.organizationid,o.organization,i.InvoiceId,i.InvoiceNumber,i.OrganizationAddressId  from invoice i
left join Organization o on o.OrganizationId=i.OrganizationId
left join OrganizationAddress od on od.OrganizationId=o.OrganizationId 
left join Address ad on ad.AddressId=od.AddressId  where i.InvoiceId=4946




--2.	Invoices has Invoice Date Greater Than Due Date.

select i.InvoiceId,i.InvoiceNumber,i.InsertDate,i.DueDate  from Invoice i
where i.InsertDate>i.DueDate

--3.	Invoice Equation.

--Invoice Eqn: Total Bill + Tax - Discount + charge
select distinct i.InvoiceId,i.InvoiceNumber,i.TotalBill,i.SalesTax,i.Discount,i.Charge,i.Balance,
(TotalBill+SalesTax-Discount+Charge-Balance) as CalculatedTotalInvoice, i.InvoiceAmount from Invoice i
where i.InvoiceAmount<>(TotalBill+SalesTax-Discount+Charge-Balance)

--4.	Payment In Invoice Payment is not equal to the sum of payment in Organization Payment


select distinct sum(ip.PaymentAmount) as InvoicePayment,sum (op.PaymentAmount)as OrganizationPaymnet from invoice i
inner join InvoicePayment ip on ip.InvoiceId=i.InvoiceId
inner join OrganizationPayment op on op.OrganizationId=i.OrganizationId
where ip.PaymentAmount<> op.PaymentAmount
group by i.InvoiceId

--===================================================================================================================
--===================================================================================================================

--Transaction
--1. Transaction Missing Organization Link.

select *From Organization
SELECT  *FROM transactionlink where OrganizationId is null


--2. Transaction Missing TransactionItem.

select *from [Transaction] t
inner join TransactionItem  ti on ti.TransactionId=t.TransactionId
where ti.TransactionItemId is null


--3. Sum of GrossAmount in PaymentCheck is not equal to the Sum of GrossWages in TransactionFinance


with GrossPaymentCheck as(
select p.paymentId,p.checknumber,sum(p.gross) as GrossAmountPaymentCheck from Payment p
group by p.PaymentId,p.checknumber
),
 GrossTransactionFinance as(
 select tf.transactionid,sum(tf.gross) as GrossWagesTransactionFinance from transactionfinance tf
 group by tf.TransactionId
 )

 select p.checknumber,pc.GrossAmountPaymentCheck,tf.transactionid,tff.GrossWagesTransactionFinance
from Payment p 
inner join TransactionLink tl on tl.PaymentId=p.PaymentId
inner join TransactionFinance tf on tf.TransactionId=tl.TransactionId
inner join GrossPaymentCheck pc on pc.PaymentId=p.PaymentId
inner join GrossTransactionFinance tff on tff.TransactionId=tf.TransactionId
where pc.GrossAmountPaymentCheck <> tff.GrossWagesTransactionFinance


--4. Sum of Bill and Discount Amt. in Invoice is not equal to the Sum of TotalBill and Discount in TransactionFinance

with invoicesum as(
select i.InvoiceId,i.totalbill, i.Discount,(TotalBill+Discount) as SumBillAndDiscountTran from invoice i
),

TransactionFinanceSum as (
select tf.TransactionId ,tf.TotalBill,tf.Discount,(TotalBill+Discount) as SumBillAndDiscountInv from TransactionFinance tf
)

select si.SumBillAndDiscountTran,st.SumBillAndDiscountInv from invoice i
inner join TransactionLink tl on tl.InvoiceId=i.InvoiceId
inner join TransactionFinance tf on tf.TransactionId=tl.TransactionId
inner join invoicesum si on si.InvoiceId=i.InvoiceId
inner join TransactionFinanceSum st on st.TransactionId=tf.TransactionId
where si.SumBillAndDiscountTran <> st.SumBillAndDiscountInv



--5. Transaction Missing Assignment Link

select * from [Transaction] t where t.AssignmentId is null



--6. Sum of Transaction Item for earnings category is not equal to gross wages

with TransactionItemSum as(
select  distinct t.transactionid,ti.itempay,ti.itembill,(itempay+itembill) as TotalItemBill,li.listitem,lic.category from [Transaction] t
inner join TransactionLink tl on tl.transactionid=t.transactionid
inner join TransactionItem ti on ti.transactionid=ti.transactionid
inner join transactioncode tc on tc.transactioncodeid=ti.transactioncodeid
inner join transactiontype ty on ty.transactiontypeid=tc.transactiontypeid
inner join listitem li on li.listitemid=ty.transactioncategorylistitemid
inner join listitemcategory lic on lic.listitemcategoryid=li.listitemcategoryid
where li.listitem like '%earnings%'
),

GrossWage as(
select distinct tf.transactionid,tf.gross as GrossWage from TransactionFinance tf
)

select tf.transactionid,ec.TotalItemBill, gw.GrossWage from transactionfinance tf
inner join TransactionItemSum ec on ec.transactionid=tf.transactionid
inner join GrossWage gw on gw.transactionid=tf.transactionid
where ec.TotalItemBill <> gw.GrossWage
and ec.totalitembill != 0



