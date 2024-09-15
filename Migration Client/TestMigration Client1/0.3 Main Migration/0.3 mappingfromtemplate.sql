SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
--USE DavisLive

-- commit
-- =============================================
-- Source: Avionte
-- Create date: 01/12/2023
-- Description:	migration mapping insert 
-- =============================================
--Replace client DB name: 'Anuska_2024_new'
--Replace MappingType = 'TestMigration_Anuska'


--(3865 rows affected)
--SELECT * FROM BackupTable.dbo.zzDavisLivemappingdata04182024

--Completion time: 2024-04-18T16:42:48.6431699+05:45

/*


EXEC dbo.SpAnuskaToZenopleMigrationMappingTsk @SourceDbName='Anuska_2024_new',@MappingType='TestMigration_Anuska',@MappingviewOnly=1,@MappingINSERT=0 -- View

EXEC dbo.SpAnuskaToZenopleMigrationMappingTsk @SourceDbName='Anuska_2024_new',@MappingType='TestMigration_Anuska',@MappingviewOnly=0,@MappingINSERT=1 -- Insert


*/

--rollback
--IF OBJECT_ID ('dbo.SpAnuskaToZenopleMigrationMappingTsk') IS NOT NULL
--    DROP PROCEDURE dbo.SpAnuskaToZenopleMigrationMappingTsk;

CREATE OR ALTER   PROCEDURE dbo.SpAnuskaToZenopleMigrationMappingTsk
(
    @SourceDbName VARCHAR (50) ,
    --, @ZenopleDbName VARCHAR(50) 
    @MappingType VARCHAR (50) ,
    @MappingviewOnly BIT ,
    @MappingINSERT BIT )
AS
    BEGIN
	select *from MappingData
        SET NOCOUNT ON;
        BEGIN TRY
            BEGIN TRANSACTION;

           
			EXEC dbo.SpMigrationMappingIns @MappingType = @MappingType;

            --DECLARE @FinalZenopleDbName VARCHAR(100)= QUOTENAME(@ZenopleDbName)
            DECLARE @MigrationUser INT = ( SELECT PersonId
                                           FROM   dbo.[User] AS u
                                           WHERE  UserName LIKE 'Converted%User%' );



            ---MappingTypeInsertEnd
            DECLARE @MappingTypeId INT = ( SELECT mt.MappingTypeId
                                           FROM   dbo.MappingType AS mt
                                           WHERE  mt.MappingType = @MappingType );


            BEGIN
                IF OBJECT_ID ('tempdb..#Mappingdata') IS NOT NULL
                    BEGIN
                        DROP TABLE tempdb..#Mappingdata;
                    END;

                CREATE TABLE #Mappingdata
                (   MappingId INT ,
                    MapFrom VARCHAR (250) ,
                    Note VARCHAR (250) ,
                    UserPersonId INT ,
                    InsertDate SMALLDATETIME ,
                    MapFromId INT ,
                    Data1 VARCHAR (250) ,
                    Data2 VARCHAR (250) ,
                    Data3 VARCHAR (250) ,
                    Example VARCHAR (MAX) ,
                    Data4 VARCHAR (250) ,
                    Data5 VARCHAR (250) ,
                    Mappingname VARCHAR (255));


                --Mapping Data Insert
                DECLARE @MappingId INT;
                DECLARE @MappingName VARCHAR (255);

				 /**********************************Mapping Data Insert:Start**********************************/
                PRINT 'Employee_EEOMaritalStatus';

         
				select employeeid,LEFT('EmployeeID: ' + CONVERT(VARCHAR(255), ed.EmployeeID) 
							 + ' Employee Name: ' + ISNULL(ed.Name, ''), 255) as example
							 into #ExampleEmployeeData
					from [Anuska_2024_new].dbo.EmployeeData ed
				SELECT @MappingId = NULL;
				SELECT @MappingName = 'Employee_EEOMaritalStatus';
				SELECT @MappingId = ( 
					SELECT MappingId
					FROM dbo.Mapping
					WHERE Mapping = 'Employee_EEOMaritalStatus'
					AND MappingTypeId = @MappingTypeId 
				);


				INSERT INTO #Mappingdata ( 
					MappingId,
					Mappingname,
					MapFromId,
					MapFrom,
					Data1,
					Data2,
					UserPersonId,
					InsertDate,
					Example 
				)
				SELECT
					@MappingId,
					@MappingName, --select 
					NULL AS MapFromId,
				   LTRIM(RTRIM(ed.MaritalStatus)) AS MapFrom,
					LTRIM(RTRIM(ed.MaritalStatus)) AS Data1,
					COUNT(*) AS Data2,
					3 AS UserPersonId,
					GETDATE() AS InsertDate,
				   ( select z.example from #ExampleEmployeeData  as z where  EmployeeID= MAX(ed.EmployeeID)) AS Example --select *
				FROM
					[Anuska_2024_new].dbo.EmployeeData ed
					WHERE
				  --  md.MappingDataId IS NULL
				   ed.MigrationStatus = 'Migrate'
				GROUP BY
				   LTRIM(RTRIM(ed.MaritalStatus))
				ORDER BY
				   LTRIM(RTRIM(ed.MaritalStatus))

				   drop table #ExampleEmployeeData
  

				PRINT @@ROWCOUNT;


------------------------------------------
                --Employee_BankAmountType

                PRINT 'Employee_BankAmountType';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Employee_BankAmountType';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Employee_BankAmountType'
                                      AND    MappingTypeId = @MappingTypeId );

                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (ed.AmountType)) AS Mapfrom ,
                                     LTRIM (RTRIM (ed.AmountType)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('EmployeeID: ' + CONVERT (VARCHAR (255), er.EmployeeID)
                                              + ' Employee Name: ' + ISNULL (er.Name, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.EmployeeBank ed   
	left join [Anuska_2024_new].dbo.EmployeeData er on er.EmployeeID=ed.EmployeeID
                            WHERE   
                                  er.MigrationStatus = 'Migrate'
                            GROUP BY ed.AmountType ,
                                      LTRIM (RTRIM (ed.AmountType))
                            ORDER BY  LTRIM (RTRIM (ed.AmountType));

                PRINT @@ROWCOUNT;

-------------------------------------------------------------------

                PRINT 'EmployeeTax_FilingStatus';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'EmployeeTax_FilingStatus';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'EmployeeTax_FilingStatus'
                                      AND    MappingTypeId = @MappingTypeId );


               INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (ed.FilingStatus)) AS Mapfrom ,
                                     LTRIM (RTRIM (ed.FilingStatus)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('EmployeeID: ' + CONVERT (VARCHAR (255), er.EmployeeID)
                                              + ' Employee Name: ' + ISNULL (er.Name, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.EmployeeTax ed   
	left join [Anuska_2024_new].dbo.EmployeeData er on er.EmployeeID=ed.EmployeeID
                            WHERE   
                                  er.MigrationStatus = 'Migrate'
                            GROUP BY ed.FilingStatus ,
                                      LTRIM (RTRIM (ed.FilingStatus))
                            ORDER BY  LTRIM (RTRIM (ed.FilingStatus));


                PRINT @@ROWCOUNT;

-----------------------------------------------------------------------------

                PRINT 'Assignment_EndReason';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Assignment_EndReason';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Assignment_EndReason'
                                      AND    MappingTypeId = @MappingTypeId );


                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (a.EndReason)) AS Mapfrom ,
                                     LTRIM (RTRIM (a.EndReason)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('EmployeeID: ' + CONVERT (VARCHAR (255), er.EmployeeID)
                                              + ' Employee Name: ' + ISNULL (er.Name, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.Assignment a   
	left join [Anuska_2024_new].dbo.EmployeeData er on er.EmployeeID=a.EmployeeID
                            WHERE   
                                  a.MigrationStatus = 'Migrate'
                            GROUP BY a.EndReason ,
                                      LTRIM (RTRIM (a.EndReason))
                            ORDER BY  LTRIM (RTRIM (a.EndReason));


                PRINT @@ROWCOUNT;


------------------------------------------------------------------------------

                PRINT 'Employee_BankAccountType';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Employee_BankAccountType';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Employee_BankAccountType'
                                      AND    MappingTypeId = @MappingTypeId );


                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (eb.AccountType)) AS Mapfrom ,
                                     LTRIM (RTRIM (eb.AccountType)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('EmployeeID: ' + CONVERT (VARCHAR (255), er.EmployeeID)
                                              + ' Employee Name: ' + ISNULL (er.Name, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.EmployeeBank eb  
	left join [Anuska_2024_new].dbo.EmployeeData er on er.EmployeeID=eb.EmployeeID
                            WHERE   
                                  er.MigrationStatus = 'Migrate'
                            GROUP BY eb.AccountType ,
                                      LTRIM (RTRIM (eb.AccountType))
                            ORDER BY  LTRIM (RTRIM (eb.AccountType));

                PRINT @@ROWCOUNT;

-------------------------------------------------------------------------


                PRINT 'WcCode';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'WcCode';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'WcCode'
                                      AND    MappingTypeId = @MappingTypeId );


               INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (j.WcCode)) AS Mapfrom ,
                                     LTRIM (RTRIM (j.WcCode)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), er.CustomerID)
                                              + ' Customer Name: ' + ISNULL (er.CustomerName, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.Job j  
	left join [Anuska_2024_new].dbo.CustomerData er on er.CustomerID=j.CustomerID
	
                            WHERE   
                                  er.MigrationStatus = 'Migrate'
                            GROUP BY j.WcCode ,
                                      LTRIM (RTRIM (j.WcCode))
                            ORDER BY  LTRIM (RTRIM (j.WcCode));
                PRINT @@ROWCOUNT;


-----------------------------------------------------------------------------

                PRINT 'Transaction_Paycode';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Transaction_Paycode';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Transaction_Paycode'
                                      AND    MappingTypeId = @MappingTypeId );


                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (j.PayCodeType)) AS Mapfrom ,
                                     LTRIM (RTRIM (j.PayCodeType)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), er.CustomerID)
                                              + ' Customer Name: ' + ISNULL (er.CustomerName, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.Job j  
	left join [Anuska_2024_new].dbo.CustomerData er on er.CustomerID=j.CustomerID
                            WHERE   
                                  er.MigrationStatus = 'Migrate'
                            GROUP BY j.PayCodeType ,
                                      LTRIM (RTRIM (j.PayCodeType))
                            ORDER BY  LTRIM (RTRIM (j.PayCodeType));
                PRINT @@ROWCOUNT;
-----------------------------------------------------------------------------------------


                PRINT 'ContactInformation_CellPhoneProvider';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'ContactInformation_CellPhoneProvider';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'ContactInformation_CellPhoneProvider'
                                      AND    MappingTypeId = @MappingTypeId );


                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (cd.ContactInformation)) AS Mapfrom ,
                                     LTRIM (RTRIM (cd.ContactInformation)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), cd.CustomerID)
                                              + ' Customer Name: ' + ISNULL (cd.CustomerName, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.CustomerData cd  
	
                            WHERE   
                                  cd.MigrationStatus = 'Migrate'
                            GROUP BY cd.ContactInformation ,
                                      LTRIM (RTRIM (cd.ContactInformation))
                            ORDER BY  LTRIM (RTRIM (cd.ContactInformation));
                PRINT @@ROWCOUNT;

-----------------------------------------------------------------------------------------

                PRINT 'Customer_PayCycle';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Customer_PayCycle';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Customer_PayCycle'
                                      AND    MappingTypeId = @MappingTypeId );


                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (cd.PayCycle)) AS Mapfrom ,
                                     LTRIM (RTRIM (cd.PayCycle)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), cd.CustomerID)
                                              + ' Customer Name: ' + ISNULL (cd.CustomerName, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.CustomerData cd  
	
                            WHERE   
                                  cd.MigrationStatus = 'Migrate'
                            GROUP BY cd.PayCycle ,
                                      LTRIM (RTRIM (cd.PayCycle))
                            ORDER BY  LTRIM (RTRIM (cd.PayCycle));

                PRINT @@ROWCOUNT;
---------------------------------------------------------------------------------------

                PRINT 'Customer_PayPeriod';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Customer_PayPeriod';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Customer_PayPeriod'
                                      AND    MappingTypeId = @MappingTypeId );


               INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (cd.PayPeriodEndDate)) AS Mapfrom ,
                                     LTRIM (RTRIM (cd.PayPeriodEndDate)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), cd.CustomerID)
                                              + ' Customer Name: ' + ISNULL (cd.CustomerName, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.CustomerData cd  
	
                            WHERE   
                                  cd.MigrationStatus = 'Migrate'
                            GROUP BY cd.PayPeriodEndDate,
                                      LTRIM (RTRIM (cd.PayPeriodEndDate))
                            ORDER BY  LTRIM (RTRIM (cd.PayPeriodEndDate));
                PRINT @@ROWCOUNT;
------------------------------------------------------------------------------------------------------------

                PRINT 'PaymentTerm';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'PaymentTerm';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'PaymentTerm'
                                      AND    MappingTypeId = @MappingTypeId );


               INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (cd.PaymentTerms)) AS Mapfrom ,
                                     LTRIM (RTRIM (cd.PaymentTerms)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), cd.CustomerID)
                                              + ' Customer Name: ' + ISNULL (cd.CustomerName, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.CustomerData cd  
	
                            WHERE   
                                  cd.MigrationStatus = 'Migrate'
                            GROUP BY cd.PaymentTerms,
                                      LTRIM (RTRIM (cd.PaymentTerms))
                            ORDER BY  LTRIM (RTRIM (cd.PaymentTerms));

							PRINT @@rowcount

-------------------------------------------------------------------------------------------------------

                PRINT 'Customer_InvoiceWeek';
				
 
                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Customer_InvoiceWeek';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Customer_InvoiceWeek'
                                      AND    MappingTypeId = @MappingTypeId );
 
                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (cd.InvoiceCycle)) AS Mapfrom ,
                                     LTRIM (RTRIM (cd.InvoiceCycle)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), cd.CustomerID)
                                              + ' Customer Name: ' + ISNULL (cd.CustomerName, '') , 255)) AS Example
                                 FROM
    [Anuska_2024_new].dbo.CustomerData cd  
	
                            WHERE   
                                  cd.MigrationStatus = 'Migrate'
                            GROUP BY cd.InvoiceCycle,
                                      LTRIM (RTRIM (cd.InvoiceCycle))
                            ORDER BY  LTRIM (RTRIM (cd.InvoiceCycle));
 
                PRINT @@ROWCOUNT;
---------------------------------------------------------------------------------------------------

                PRINT 'Job_Title';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Job_Title';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Job_Title'
                                      AND    MappingTypeId = @MappingTypeId );

                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (jt.Job)) AS Mapfrom ,
                                     LTRIM (RTRIM (jt.Job)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('CustomerID: ' + CONVERT (VARCHAR (255), cd.CustomerID)
                                              + ' Customer Name: ' + ISNULL (cd.CustomerName, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.JobTitle jt 
	left join [Anuska_2024_new].dbo.job j on j.JobID=jt.ID
	left join  [Anuska_2024_new].dbo.CustomerData cd  on cd.customerid= j.CustomerID
	
                            WHERE   
                                  j.MigrationStatus = 'Migrate'
                            GROUP BY jt.Job,
                                      LTRIM (RTRIM (jt.Job))
                            ORDER BY  LTRIM (RTRIM (jt.Job));
                PRINT @@ROWCOUNT;
--------------------------------------------------------------------------------------

                PRINT 'Payment_deduction';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Payment_deduction';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Payment_deduction'
                                      AND    MappingTypeId = @MappingTypeId );

                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (edd.Amount)) AS Mapfrom ,
                                     LTRIM (RTRIM (edd.Amount)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('EmployeeID: ' + CONVERT (VARCHAR (255), ed.EmployeeID)
                                              + ' Employee Name: ' + ISNULL (ed.Name, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.EmployeeDeduction edd
	left join [Anuska_2024_new].dbo.EmployeeData ed on ed.EmployeeID= edd.EmployeeID
	
                            WHERE   
                                  ed.MigrationStatus = 'Migrate'
                            GROUP BY edd.Amount,
                                      LTRIM (RTRIM (edd.Amount))
                            ORDER BY  LTRIM (RTRIM (edd.Amount));

                PRINT @@ROWCOUNT;
--------------------------------------------------------------------------------------------

                PRINT 'Payment_bank';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Payment_bank';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Payment_bank'
                                      AND    MappingTypeId = @MappingTypeId );

                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select
                                     NULL AS Mapfromid ,
                                     LTRIM (RTRIM (edd.BankName)) AS Mapfrom ,
                                     LTRIM (RTRIM (edd.BankName)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('EmployeeID: ' + CONVERT (VARCHAR (255), ed.EmployeeID)
                                              + ' Employee Name: ' + ISNULL (ed.Name, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.EmployeeBank edd
	left join [Anuska_2024_new].dbo.EmployeeData ed on ed.EmployeeID= edd.EmployeeID
	
                            WHERE   
                                  ed.MigrationStatus = 'Migrate'
                            GROUP BY edd.BankName,
                                      LTRIM (RTRIM (edd.BankName))
                            ORDER BY  LTRIM (RTRIM (edd.BankName));
                PRINT @@ROWCOUNT;


             
			  PRINT 'Payment_Tax';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Payment_Tax';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Payment_Tax'
                                      AND    MappingTypeId = @MappingTypeId );
--------============================================================================
--payment tax

  PRINT 'Payment_Tax';

                SELECT @MappingId = NULL;
                SELECT @MappingName = 'Payment_Tax';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Payment_Tax'
                                      AND    MappingTypeId = @MappingTypeId );
                INSERT INTO #Mappingdata ( MappingId ,
                                           Mappingname ,
                                           MapFromId ,
                                           MapFrom ,
                                           Data1 ,
                                           Data2 ,
                                           Data3 ,
                                           UserPersonId ,
                                           InsertDate ,
                                           Example )
                            SELECT   @MappingId ,
                                     @MappingName , --select 
                                     NULL ,
                                     ep.TaxName AS Mapfrom ,
                                     ep.TaxName AS Data1 ,
                                     COUNT (*) AS data2 ,
                                     'EE',
                                     3 AS userpersonid ,
                                     GETDATE () ,
                                     MAX (
                                         'EmployeeID: ' + CONVERT (VARCHAR (MAX), e.EmployeeID) + ' EmployeeName: '
                                         + ISNULL (e.FirstName, '') + ' ' + ISNULL (e.LastName, '')) AS example
                            FROM     [anuska_2024_new].dbo.EmployeeTax ep
                                     INNER JOIN [anuska_2024_new].dbo.EmployeeData e ON e.EmployeeID = ep.EmployeeID
                                     LEFT JOIN dbo.MappingData md ON  md.Data1 = ep.taxname
                                                                  AND md.MappingId =@MappingId
                            WHERE    md.MappingDataId IS NULL
                            AND      e.Migrationstatus = 'Migrate'
                            GROUP BY ep.TaxName ;

            /**********************************Mapping Data Insert:END**********************************/
            /**********************************MappingInsert:Start**********************************/



            END;

            IF ( @MappingviewOnly = 1
             AND @MappingINSERT = 1 )
                BEGIN
                    RAISERROR (
                        'Please pass parament >>1<< for one of them @MappingviewOnly or @MappingINSERT ,%s' , 16, 1);

                END;

            IF ( @MappingviewOnly = 1 )
                BEGIN

                    IF EXISTS ( SELECT TOP 1 *
                                FROM   #Mappingdata
                                WHERE  MappingId IS NULL )
                        BEGIN
                            PRINT 'These Mapping name are missing';

                            SELECT DISTINCT Mappingname
                            FROM   #Mappingdata
                            WHERE  MappingId IS NULL;
                        END;

                    SELECT 'Mapping going to be Inserted List:' AS MappingNotes;

                    SELECT   mt.MappingTypeId ,
                             mt.MappingType ,
                             m.MappingId ,
                             m.Mapping ,
                             --MD.MapFromId ,
                             MD.MapFrom ,
                             MD.Data1 ,
                             SUM (CAST(MD.Data2 AS INT)) AS Data2 ,
                             --MD.Data3 ,
                             --MD.Data4 ,
                             MAX (MD.Example)
                    FROM     #Mappingdata MD
                             INNER JOIN dbo.Mapping AS m ON m.MappingId = MD.MappingId
                             INNER JOIN dbo.MappingType AS mt ON mt.MappingTypeId = m.MappingTypeId
                             LEFT JOIN dbo.MappingData md2 ON  md2.MappingId = MD.MappingId
                                                           AND LTRIM (RTRIM (ISNULL (md2.Data1, ''))) = LTRIM (
                                                                                                            RTRIM (
                                                                                                                ISNULL (
                                                                                                                    MD.Data1 ,
                                                                                                                    '')))
                                                           --AND LTRIM (RTRIM (ISNULL (md2.Data3, ''))) = LTRIM (
                                                           --                                                 RTRIM (
                                                           --                                                     ISNULL (
                                                           --                                                         MD.Data3 ,
                                                           --                                                         '')))
                                                           --AND LTRIM (RTRIM (ISNULL (md2.Data4, ''))) = LTRIM (
                                                           --                                                 RTRIM (
                                                           --                                                     ISNULL (
                                                           --                                                         MD.Data4 ,
                                                           --                                                         '')))
                    WHERE    md2.MappingDataId IS NULL
                    GROUP BY mt.MappingTypeId ,
                             mt.MappingType ,
                             m.MappingId ,
                             m.Mapping ,
                             MD.MapFrom ,
                             MD.Data1 
                             --MD.Data3 ,
                             --MD.Data4;

                    SELECT 'To be Inserted:' + CAST(@@ROWCOUNT AS VARCHAR (100)) AS NewmappingCount;

                END;

            IF ( @MappingINSERT = 1 )
                BEGIN

                    IF OBJECT_ID ('tempdb..#MappingdataInsert') IS NOT NULL
                        BEGIN
                            DROP TABLE tempdb..#MappingdataInsert;
                        END;


						SELECT * FROM #Mappingdata AS m WHERE m.Mappingname='Customer_Requirement'

                    SELECT   mt.MappingTypeId ,
                             mt.MappingType ,
                             m.MappingId ,
                             m.Mapping ,
                             MD.MapFromId ,
                             MD.MapFrom ,
                             MD.Data1 ,
                             SUM (CAST(MD.Data2 AS INT)) AS Data2 ,
                             --MD.Data3 ,
                             --MD.Data4 ,
                             MAX (MD.Example) AS Example
                    INTO     #MappingdataInsert
                    FROM     #Mappingdata MD
                             INNER JOIN dbo.Mapping AS m ON m.MappingId = MD.MappingId
                             INNER JOIN dbo.MappingType AS mt ON mt.MappingTypeId = m.MappingTypeId
                             LEFT JOIN dbo.MappingData md2 ON  md2.MappingId = MD.MappingId
                                                           AND LTRIM (RTRIM (ISNULL (md2.Data1, ''))) = LTRIM (
                                                                                                            RTRIM (
                                                                                                                ISNULL (
                                                                                                                    MD.Data1 ,
                                                                                                                    '')))
                                                           --AND LTRIM (RTRIM (ISNULL (md2.Data3, ''))) = LTRIM (
                                                           --                                                 RTRIM (
                                                           --                                                     ISNULL (
                                                           --                                                         MD.Data3 ,
                                                           --                                                         '')))
                                                           --AND LTRIM (RTRIM (ISNULL (md2.Data4, ''))) = LTRIM (
                                                           --                                                 RTRIM (
                                                           --                                                     ISNULL (
                                                           --                                                         MD.Data4 ,
                                                           --                                                         '')))
                    WHERE    md2.MappingDataId IS NULL
                    GROUP BY mt.MappingTypeId ,
                             mt.MappingType ,
                             m.MappingId ,
                             m.Mapping ,
                             MD.MapFromId ,
                             MD.MapFrom ,
                             MD.Data1 
                             --MD.Data3 ,
                             --MD.Data4;


                   --EXEC utl.BackupTable Mappingdata;

                    INSERT INTO dbo.MappingData ( MappingId ,
                                                  MapFromId ,
                                                  MapFrom ,
                                                  Data1 ,
                                                  Data2 ,
                                                  --Data3 ,
                                                  --Data4 ,
                                                  UserPersonId ,
                                                  InsertDate ,
                                                  Example )
                                SELECT MappingId ,
                                       MapFromId ,
                                       MapFrom ,
                                       Data1 ,
                                       Data2 ,
                                       --Data3 ,
                                       --Data4 ,
                                       @MigrationUser AS UserPersonId ,
                                       GETDATE () AS InsertDate ,
                                       Example
                                FROM   #MappingdataInsert;

                    PRINT 'Inserted:' + CAST(@@ROWCOUNT AS VARCHAR (100));

					--drop table #Mappingdata
					--drop table #MappingdataInsert
                END;


            /**********************************Dropping Temp Table:END**********************************/


            --*/

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN;
            THROW;
        END CATCH;
    END;
GO

