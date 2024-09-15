select *from Mapping m
inner join MappingType mt on mt.MappingTypeId=m.MappingTypeId
where mt.MappingType= 'TestMigration_Anuska' 
and Mapping like '%value%'


-------------------------for Employee_EEOMaritalStatus

select employeeid,LEFT('EmployeeID: ' + CONVERT(VARCHAR(255), ed.EmployeeID) 
             + ' Employee Name: ' + ISNULL(ed.Name, ''), 255) as example
			 into #ExampleEmployeeData
    from [Anuska_2024_new].dbo.EmployeeData ed


declare @MappingName nvarchar(max);
declare @MappingId nvarchar(max);
declare @MappingTypeId nvarchar(max);

SELECT @MappingName = 'Employee_EEOMaritalStatus';
SELECT @MappingId = ( 
    SELECT MappingId
    FROM dbo.Mapping
    WHERE Mapping = 'Employee_EEOMaritalStatus'
    AND MappingTypeId = @MappingTypeId 
);

create table #Mappingdata(
         MappingId int,
    Mappingname varchar(500),
    MapFromId int,
    MapFrom varchar(max),
    Data1 varchar(max),
    Data2 varchar(max),
    UserPersonId varchar(max),
    InsertDate DATETIME,
    Example varchar(max)
)


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
	--WHERE
 --   md.MappingDataId IS NULL
    where ed.MigrationStatus = 'Migrate'
GROUP BY
   LTRIM(RTRIM(ed.MaritalStatus))
ORDER BY
   LTRIM(RTRIM(ed.MaritalStatus))

   drop table #ExampleEmployeeData
   drop table #Mappingdata



--------------------------------------------------------------------------------------

--for Employee_BankAmountType

declare @MappingName nvarchar(max);
declare @MappingId nvarchar(max);
declare @MappingTypeId nvarchar(max);

SELECT @MappingName = 'Employee_BankAmountType';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Employee_BankAmountType'
                                      AND    MappingTypeId = @MappingTypeId );

			create table #Mappingdata(
					 MappingId int,
				Mappingname varchar(500),
				MapFromId int,
				MapFrom varchar(max),
				Data1 varchar(max),
				Data2 varchar(max),
				UserPersonId varchar(max),
				InsertDate DATETIME,
				Example varchar(max)
			)
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

						
							drop table #Mappingdata



-----------------------------------------------------------------------------------
--for EmployeeTax_FilingStatus

declare @MappingName nvarchar(max);
declare @MappingId nvarchar(max);
declare @MappingTypeId nvarchar(max);

SELECT @MappingName = 'EmployeeTax_FilingStatus';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'EmployeeTax_FilingStatus'
                                      AND    MappingTypeId = @MappingTypeId );

			create table #Mappingdata(
					 MappingId int,
				Mappingname varchar(500),
				MapFromId int,
				MapFrom varchar(max),
				Data1 varchar(max),
				Data2 varchar(max),
				UserPersonId varchar(max),
				InsertDate DATETIME,
				Example varchar(max)
			)
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

						
							drop table #Mappingdata


---------------------------------------------------------------------------

--for Assignment_EndReason

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

						
							drop table #Mappingdata


-----------------------------------------------------------------------------
--Employee_BankAccountType AccountType

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

						
							drop table #Mappingdata


-------------------------------------------------------------------------------------------------
-- for WcCode

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

						
							drop table #Mappingdata

----------------------------------------------------------------------------------------------------
--Transaction_Paycode


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

						
							drop table #Mappingdata

-------------------------------------------------------------------------------------------------------------------
--for ContactInformation_CellPhoneProvider

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

						
							drop table #Mappingdata


----------------------------------------------------------------------------------------------
-- for Customer_PayCycle

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

						
							drop table #Mappingdata

-------------------------------------------------------------------------------------------------
--Customer_PayPeriod

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

						
							drop table #Mappingdata

----------------------------------------------------------------------------------------------------------
-- for PaymentTerm

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

						
							drop table #Mappingdata

------------------------------------------------------------------------------------------------------
--for Customer_InvoiceWeek

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

						
							drop table #Mappingdata

---------------------------------------------------------------------------------------

--for Job_Title
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

						
							drop table #Mappingdata

--------------------------------------------------------------------------------------------------------
--fro Payment_deduction

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

						
							drop table #Mappingdata

-----------------------------------------------------------------------------------

--Payment_bank

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
                                     LTRIM (RTRIM (edd.AmountValue)) AS Mapfrom ,
                                     LTRIM (RTRIM (edd.AmountValue)) AS Data1 ,
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
                            GROUP BY edd.AmountValue,
                                      LTRIM (RTRIM (edd.AmountValue))
                            ORDER BY  LTRIM (RTRIM (edd.AmountValue));

						
							drop table #Mappingdata

-------------------------------------------------------------------------

--Payment_bank
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

						
							drop table #Mappingdata
						