DROP TABLE IF EXISTS #TempPayment;

                    SELECT DISTINCT P.*,pb.CheckDate,p2.Name
                    INTO   #TempPayment
                    FROM   dbo.Payment AS p
					INNER JOIN dbo.PaymentBatch AS pb ON pb.PaymentBatchId = p.PaymentBatchId
					INNER JOIN dbo.Person AS p2 ON p2.PersonId = p.PersonId
					WHERE p.ReferenceNote IS NOT NULL

					SELECT tp.PaymentId ,
       tp.CheckNumber ,
       tp.CheckDate ,
       tp.PersonId ,
       tp.Name ,
       p.Tax ,
       x.TransactionType ,
       x.Tax AS EmployerTax ,
       y.Tax AS EmployerTax ,
       p.ReferenceId ,
       p.ReferenceNote
FROM   dbo.Payment AS p
       INNER JOIN #TempPayment AS tp ON tp.PaymentId = p.PaymentId
       INNER JOIN ( SELECT   tptds.PaymentId ,
                             tptds.TransactionType ,
                             SUM (tptds.Tax) Tax
                    FROM     dbo.TfPaymentTaxDataSel (3) AS tptds
                             INNER JOIN #TempPayment ON #TempPayment.PaymentId = tptds.PaymentId
                    WHERE    tptds.IsEmployerTax = 1
                    AND      tptds.TransactionType = 'MEDI'
                    GROUP BY tptds.PaymentId ,
                             tptds.TransactionType ) x ON x.PaymentId = tp.PaymentId
       INNER JOIN ( SELECT   tptds1.PaymentId ,
                             SUM (tptds1.Tax) Tax
                    FROM     dbo.TfPaymentTaxDataSel (3) AS tptds1
                             INNER JOIN #TempPayment ON #TempPayment.PaymentId = tptds1.PaymentId
                    WHERE    tptds1.IsEmployerTax = 0
                    AND      tptds1.TransactionType = 'MEDI'
                    GROUP BY tptds1.PaymentId ) y ON y.PaymentId = tp.PaymentId
WHERE  x.Tax <> y.Tax;



select *from TransactionBatch
select *from TransactionBatchNode
select *From TransactionLink
select *From TransactionSummary




--3.Check with total employer tax not equal to total employer tax from transaction.

select top 5 *FROM   dbo.TfPaymentTaxDataSel (2)AS tptds
SELECT TOP 5 * FROM dbo.TfTransactionDataSel(2) AS ttds