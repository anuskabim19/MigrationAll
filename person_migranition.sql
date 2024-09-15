/*
DROP PROCEDURE dbo.SpAnuska_2024_newToZenopleMigrationTsk;

*/

CREATE OR ALTER PROCEDURE [dbo].[SpAnuska_2024_newToZenopleMigrationTsk]
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    EXEC dbo.EncryptionKeyOpen;
    DECLARE @OldCount INT,
            @NewCOunt INT,
            @defaultotplanid INT,
            @MappingType VARCHAR(50),
            @TableName VARCHAR(50)
    --@UnmappedResourceId INT;

    DECLARE @defaultofficeid INT = (
                                       SELECT o.OfficeId
                                       -- select *
                                       FROM dbo.Office AS o
                                       WHERE o.Office = 'Currie'
                                   );

    DECLARE @ReferenceNote VARCHAR(50) = N'TestMigration_Anuska';
    --DECLARE @ReferenceNotePerson VARCHAR (50) = N'TestMigration_AnuskaPerson';

    SELECT @MappingType =
    (
        SELECT mt.MappingType
        FROM dbo.MappingType AS mt
        WHERE mt.MappingType = 'TestMigration_Anuska'
    );

    DECLARE @MappingTypeId INT = (
                                     SELECT mt.MappingTypeId
                                     FROM dbo.MappingType AS mt
                                     WHERE mt.MappingType = 'TestMigration_Anuska'
                                 );


    DECLARE @DefautAffiliateId INT,
            @DefaultBAnkAccountId INT;

    SET @DefaultBAnkAccountId =
    (
        SELECT MIN(ba.BankAccountId)
        --SELECT r.report,dbo.SfListItemGet(ba.AccountTypeListItemId),dbo.SfListItemGet(ba.BankTypeListItemId),* 
        FROM bankaccount AS ba
            inner JOIN dbo.Report AS R
                ON R.ReportId = ba.ReportId
        WHERE dbo.SfListItemGet(ba.BankTypeListItemId) LIKE '%Expense%'
              AND dbo.SfListItemGet(ba.BankTypeListItemId) <> 'AccountPayableExpense'
    ); -- SELECT * FROM dbo.BankAccount a INNER JOIN dbo.Tenant t ON t.OrganizationId = a.OrganizationId

    DECLARE @ARDefaultBAnkAccountId INT
        =   (
                SELECT MIN(ba.BankAccountId)
                --SELECT r.report,dbo.SfListItemGet(ba.AccountTypeListItemId),dbo.SfListItemGet(ba.BankTypeListItemId),* 
                FROM bankaccount AS ba
                    inner JOIN dbo.Report AS R
                        ON R.ReportId = ba.ReportId
                WHERE dbo.SfListItemGet(ba.BankTypeListItemId) LIKE '%Income%'
            ); -- 

    DECLARE @AgencyDefaultBAnkAccountId INT
        =   (
                SELECT MIN(ba.BankAccountId)
                --SELECT r.report,dbo.SfListItemGet(ba.AccountTypeListItemId),dbo.SfListItemGet(ba.BankTypeListItemId),* 
                FROM bankaccount AS ba
                    inner JOIN dbo.Report AS R
                        ON R.ReportId = ba.ReportId
                WHERE dbo.SfListItemGet(ba.BankTypeListItemId) = 'AccountPayableExpense'
            )

    DECLARE @ConvertedUserId INT;
    SELECT @ConvertedUserId =
    (
        SELECT p.PersonId
        FROM dbo.Person p
            INNER JOIN dbo.OfficeStaff o
                ON o.PersonId = p.PersonId
        WHERE p.Name = 'CONVERTED USER'
    );

    DECLARE @UserPersonId INT;
    SELECT @UserPersonId =
    (
        SELECT p.PersonId
        FROM dbo.Person p
            INNER JOIN dbo.OfficeStaff o
                ON o.PersonId = p.PersonId
        WHERE p.Name = 'CONVERTED USER'
    );

    DECLARE @ZenopleJobPortalId INT = (
                                          SELECT jp.JobPortalId
                                          FROM dbo.JobPortal AS jp
                                          WHERE jp.JobPortal = 'ZenopleJobPortal'
                                      );
    DECLARE @DataSource INT;
    SELECT @DataSource = dbo.SfListItemIdGet('DataSource', 'Migration');

    DECLARE @CustomerWorkflowId INT;
    SELECT @CustomerWorkflowId = dbo.SfWorkflowIdGet('Customer');

    DECLARE @TargetWorkflowId INT;
    SELECT @TargetWorkflowId = dbo.SfWorkflowIdGet('Target');

    DECLARE @LeadWorkflowId INT;
    SELECT @LeadWorkflowId = dbo.SfWorkflowIdGet('Lead');

    DECLARE @NewCustomerWorkflowId INT;
    SELECT @NewCustomerWorkflowId = dbo.SfWorkflowIdGet('NewCustomer');


    DECLARE @AuthorizedEVerifyStatusListItemId INT = dbo.SfListItemIdGet('EVerifyStatus', 'Authorized');
    DECLARE @UnAuthorizedEVerifyStatusListItemId INT = dbo.SfListItemIdGet('EVerifyStatus', 'Unauthorized');

    DECLARE @AdvanceAdjustmentTypeListItemId INT = dbo.SfListItemIdGet('AdjustmentType', 'Advance');
    DECLARE @AmountAdjustmentTypeListItemId INT = dbo.SfListItemIdGet('AdjustmentType', 'Amount');
    DECLARE @HourlyAdjustmentTypeListItemId INT = dbo.SfListItemIdGet('AdjustmentType', 'Hourly');
    DECLARE @LevyAdjustmentTypeListItemId INT = dbo.SfListItemIdGet('AdjustmentType', 'Levy');
    DECLARE @PercentGrossAdjustmentTypeListItemId INT = dbo.SfListItemIdGet('AdjustmentType', 'PercentGross');
    DECLARE @PercentNetAdjustmentTypeListItemId INT = dbo.SfListItemIdGet('AdjustmentType', 'PercentNet');

    DECLARE @AmountBenefitTypeListItemId INT = dbo.SfListItemIdGet('BenefitType', 'Amount');
    DECLARE @PercentGrossBenefitTypeListItemId INT = dbo.SfListItemIdGet('BenefitType', 'PercentGross');
    DECLARE @PercentNetBenefitTypeListItemId INT = dbo.SfListItemIdGet('BenefitType', 'PercentNet');

    DECLARE @EnteredDateListItemId INT = dbo.SfListItemIdGet('DateType', 'EnteredDate');
    DECLARE @InterviewedDateListItemId INT = dbo.SfListItemIdGet('DateType', 'InterviewedDate');
    DECLARE @LastPasswordChangeDateListItemId INT = dbo.SfListItemIdGet('DateType', 'LastPasswordChangeDate');
    DECLARE @I9DateListItemId INT = dbo.SfListItemIdGet('DateType', 'I9');

    DECLARE @LeadWorkflowStageId INT;
    SELECT @LeadWorkflowStageId = dbo.SfWorkflowStageIdGet('Lead', 'Discovery');

    DECLARE @TargetWorkflowStageId INT;
    SELECT @TargetWorkflowStageId = dbo.SfWorkflowStageIdGet('Target', 'Discovery');

    DECLARE @CustomerWorkflowStageId INT;
    SELECT @CustomerWorkflowStageId = dbo.SfWorkflowStageIdGet('Customer', 'Customer');

    DECLARE @NewCustomerWorkflowStageId INT;
    SELECT @NewCustomerWorkflowStageId = dbo.SfWorkflowStageIdGet('NewCustomer', 'Paperwork');

    DECLARE @InterviewedById INT;
    SELECT @InterviewedById = dbo.SfListItemIdGet('UserType', 'InterviewedBy');
    DECLARE @WOTCStatusListItemId INT = dbo.SfListItemIdGet('WOTCStatus', 'NotScreened');

    DECLARE @migratedPerformacnelistotemID INT;
    SELECT @migratedPerformacnelistotemID = dbo.SfListItemIdGet('performance', 'N/A');

    DECLARE @OTMarkUpListItemId INT = dbo.SfListItemIdGet('OTBillMarkup', 'OTPayRate');
    DECLARE @DTMarkUpListItemId INT = dbo.SfListItemIdGet('DTBillMarkup', 'DTPayRate');


    DECLARE @SalesTeamId INT;
    SELECT @SalesTeamId = dbo.SfListItemIdGet('UserType', 'SalesRep');

    DECLARE @AccountManagerId INT;
    SELECT @AccountManagerId = dbo.SfListItemIdGet('UserType', 'AccountManager');

    DECLARE @HoldAtEmployeeOfficeCheckDeliveryListItemId INT
        = dbo.SfListItemIdGet('CheckDelivery', 'HoldAtEmployeeOffice');


    DECLARE @ConvertedSkillID INT = (
                                        SELECT s.SkillId
                                        -- select *
                                        FROM dbo.Skill AS s
                                        WHERE s.Skill = 'Converted'
                                    );

    DECLARE @ConvertedDeductionCodeId INT = (
                                                SELECT tc.TransactionCodeId
                                                FROM dbo.TransactionCode AS tc
                                                    INNER JOIN dbo.Deduction AS d
                                                        ON d.TransactionCodeId = tc.TransactionCodeId
                                                WHERE tc.TransactionCode = 'Converted'
                                            );
    DECLARE @ConvertedPayCodeId INT = (
                                          SELECT tc.TransactionCodeId
                                          FROM dbo.TransactionCode AS tc
                                              INNER JOIN dbo.PayCode AS pc
                                                  ON pc.TransactionCodeId = tc.TransactionCodeId
                                                     AND tc.TransactionCode = 'Converted'
                                      );
    DECLARE @RTPayCodeId INT = (
                                   SELECT tc.TransactionCodeId
                                   FROM dbo.TransactionCode AS tc
                                       INNER JOIN dbo.PayCode AS pc
                                           ON pc.TransactionCodeId = tc.TransactionCodeId
                                              AND tc.TransactionCode = 'RT'
                               );
    DECLARE @OTPayCodeId INT = (
                                   SELECT tc.TransactionCodeId
                                   FROM dbo.TransactionCode AS tc
                                       INNER JOIN dbo.PayCode AS pc
                                           ON pc.TransactionCodeId = tc.TransactionCodeId
                                              AND tc.TransactionCode = 'OT'
                               );
    DECLARE @DTPayCodeId INT = (
                                   SELECT tc.TransactionCodeId
                                   FROM dbo.TransactionCode AS tc
                                       INNER JOIN dbo.PayCode AS pc
                                           ON pc.TransactionCodeId = tc.TransactionCodeId
                                              AND tc.TransactionCode = 'DT'
                               );

    DECLARE @SalaryPayCodeId INT = (
                                       SELECT tc.TransactionCodeId
                                       FROM dbo.TransactionCode AS tc
                                           INNER JOIN dbo.PayCode AS pc
                                               ON pc.TransactionCodeId = tc.TransactionCodeId
                                                  AND tc.TransactionCode = 'Salary'
                                   );

    DECLARE @MessageCommentTypeListItemId INT = dbo.SfListItemIdGet('CommentType', 'Message');

    DECLARE @EmployeeTitle VARCHAR(50) = N'Employee';
    DECLARE @NewhireTitle VARCHAR(50) = N'NewHire';
    DECLARE @MainContactInformationTypeListItemId INT = dbo.SfListItemIdGet('ContactInformationType', 'Main');
    DECLARE @EmailContactInformationTypeListItemId INT = dbo.SfListItemIdGet('ContactInformationType', 'Email');
    DECLARE @BillingAddressTypeListItemId INT = dbo.SfListItemIdGet('AddressType', 'Billing');
    DECLARE @LastPasswordChangeDate INT = dbo.SfListItemIdGet('DateType', 'LastPasswordChangeDate');
    DECLARE @LeftNavigationStyleListIitemID INT = dbo.SfListItemIdGet('NavigationStyle', 'Left');
    DECLARE @LightThemeListitemId INT = dbo.SfListItemIdGet('Theme', 'Light');
    DECLARE @EmployeePortalApplicationId INT = dbo.SfApplicationIdGet('EmployeePortal');
    DECLARE @ApplicantPortalApplicationId INT = dbo.SfApplicationIdGet('ApplicantPortal');

    DECLARE @NewHirePortalApplicationId INT = dbo.SfApplicationIdGet('NewHirePortal');
    DECLARE @ContactPortalApplicationId INT = dbo.SfApplicationIdGet('CustomerPortal');
    DECLARE @ZenopleJobPortal INT = (
                                        SELECT jp.JobPortalId
                                        FROM dbo.JobPortal AS jp
                                        WHERE jp.JobPortal = 'ZenopleJobPortal'
                                    );

    DECLARE @ResidentAddressTypeListItemId INT = dbo.SfListItemIdGet('AddressType', 'Resident');
    DECLARE @EmployeeWorkflowStageId INT = dbo.SfWorkflowStageIdGet('Employee', 'Employee');
    DECLARE @RehireEmployeeWorkflowStageId INT = dbo.SfWorkflowStageIdGet('Employee', 'Rehire');

    DECLARE @NewHireWorkflowStageId INT = dbo.SfWorkflowStageIdGet('NewHire', 'Onboard');
    DECLARE @ApplicantworkWorkflowStageId INT = dbo.SfWorkflowStageIdGet('Applicant', 'Applicant');

    DECLARE @EmailCheckDeliveryListItemId INT = dbo.SfListItemIdGet('CheckDelivery', 'HoldAtEmployeeOffice');

    DECLARE @CultureId INT = dbo.SfCultureIdGet('EN');
    DECLARE @ContactRoleId INT = dbo.SfRoleIdGet('Contact');
    DECLARE @EmployeeRoleId INT = dbo.SfRoleIdGet('Employee');
    DECLARE @ApplicantRoleId INT = dbo.SfRoleIdGet('Applicant');

    DECLARE @NewHireRoleId INT = dbo.SfRoleIdGet('NewHire');

    DECLARE @TempJobCandidateWorkflowId INT = dbo.SfWorkflowIdGet('JobCandidate');

    DECLARE @ClosedWorkInjuryID INT = dbo.SfWorkflowStageIdGet('WorkInjury', 'Closed');
    DECLARE @InProgressdWorkInjuryID INT = dbo.SfWorkflowStageIdGet('WorkInjury', 'InProgress');
    --DECLARE @ActiveStatusListItemId INT = dbo.SfListItemIdGet ('Status', 'active');    
    DECLARE @TerminatedStatusListItemId INT = dbo.SfListItemIdGet('Status', 'Terminated');
    DECLARE @ClosedStatusListItemId INT = dbo.SfListItemIdGet('Status', 'Closed');
    DECLARE @OpenStatusListItemId INT = dbo.SfListItemIdGet('Status', 'Open');
    DECLARE @UnknownSourceOfInjuryListItemId INT = dbo.SfListItemIdGet('SourceOfInjury', 'Unknown');
    DECLARE @UnknownTypeOfInjuryListItemId INT = dbo.SfListItemIdGet('TypeOfInjury', 'Unknown');
    DECLARE @UnknownBodyPartListItemId INT = dbo.SfListItemIdGet('BodyPart', 'Unknown');
    DECLARE @DocumentTypeListItemId INT = dbo.SfListItemIdGet('DocumentType', 'Document');
    DECLARE @HireDateTypeListItemId INT = dbo.SfListItemIdGet('DateType', 'HiredDate');

    DECLARE @EmployeeEmployeeTypeListItemId INT = dbo.SfListItemIdGet('EmployeeType', 'Employee');
    DECLARE @ContractorEmployeeTypeListItemId INT = dbo.SfListItemIdGet('EmployeeType', 'Contractor');


    DECLARE @NewHireEntityListItemId INT = dbo.SfListItemIdGet('Entity', 'NewHire');
    DECLARE @EmployeeEntityListItemId INT = dbo.SfListItemIdGet('Entity', 'Employee');
    DECLARE @ApplicantEntityListItemId INT = dbo.SfListItemIdGet('Entity', 'Applicant');



    DECLARE @EnteredByUserTypeListItemId INT = dbo.SfListItemIdGet('UserType', 'EnteredBy');
    DECLARE @CustomerEntityId INT;
    SELECT @CustomerEntityId = dbo.SfListItemIdGet('Entity', 'Customer');
    DECLARE @NewCustomerEntityId INT;
    SELECT @NewCustomerEntityId = dbo.SfListItemIdGet('Entity', 'NewCustomer');
    DECLARE @TargetEntityId INT;
    SELECT @TargetEntityId = dbo.SfListItemIdGet('Entity', 'Target');
    DECLARE @LeadEntityId INT;
    SELECT @LeadEntityId = dbo.SfListItemIdGet('Entity', 'Lead');



    DECLARE @ActiveStatusListItemId INT,
            @DNAStatusListItemId INT,
            @InActiveStatusListItemId INT;
    SELECT @ActiveStatusListItemId = dbo.SfListItemIdGet('Status', 'Active');
    SELECT @InActiveStatusListItemId = dbo.SfListItemIdGet('Status', 'InActive');
    SELECT @DNAStatusListItemId = dbo.SfListItemIdGet('Status', 'DNA');



    SELECT @defaultotplanid =
    (
        SELECT op.OTPlanId FROM dbo.OTPlan AS op WHERE op.OTPlan = 'over40Plan'
    );


    DECLARE @MainAddressTypeListItemId INT = dbo.SfListItemIdGet('AddressType', 'Main');
    DECLARE @WorksiteAddressTypeListItemId INT = dbo.SfListItemIdGet('AddressType', 'Jobsite');
    DECLARE @Message VARCHAR(50);
    DECLARE @ErrorMessage VARCHAR(MAX);

    DECLARE @PlacedByUserTypeListItemId INT = dbo.SfListItemIdGet('UserType', 'PlacedBy');
    DECLARE @RecruiterByUserTypeListItemId INT = dbo.SfListItemIdGet('UserType', 'Recruiter');



    DECLARE @EmployeeWorkflowId INT = dbo.SfWorkflowIdGet('Employee');
    DECLARE @ApplicantWorkflowId INT = dbo.SfWorkflowIdGet('Applicant');
    DECLARE @NewHireWorkflowId INT = dbo.SfWorkflowIdGet('NewHire');
    DECLARE @PhoneContactInformationTypeListItemId INT = dbo.SfListItemIdGet('ContactInformationType', 'Phone');

	exec EncryptionKeyOpen

    -- Person start --------

    DROP TABLE IF EXISTS #TempPerson;
    SELECT er.*
    INTO #TempPerson
    -- select count(*)
    FROM anuska_2024_new.dbo.EmployeeData AS er
    --  LEFT JOIN dbo.Person AS p ON  p.ReferenceId = CONVERT (VARCHAR (36), er.EmployeeID)
    --AND p.ReferenceNote = @ReferenceNote
    -- WHERE  p.PersonId IS NULL
    where er.Migrationstatus = 'Migrate';

    -- select * from #TempPerson
    SELECT @TableName = 'Person'

    IF NOT EXISTS
    (
        SELECT TOP 1
            1
        FROM dbo.MigrationLog as ml
        where ml.ReferenceNote = @ReferenceNote
              and ml.TableName = @TableName
    )
    begin
        BEGIN TRY
            begin transaction;
            begin


                SELECT @OldCount = COUNT(*),
                       @TableName = 'Person'
                FROM #TempPerson AS tp;

                EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,           -- int
                                           @TableName = @TableName,         -- varchar(50)
                                           @ReferenceNote = @ReferenceNote; -- varchar(100)

                SET IDENTITY_INSERT dbo.Person ON;

                INSERT INTO dbo.Person
                (
                    PersonId,
                    FirstName,
                    MiddleName,
                    LastName,
                    SSN,
                    OrganizationId,
                    Title,
                    UserPersonId,
                    InsertDate,
                    ReferenceId,
                    ReferenceNote,
                    TIN
                )
                SELECT p.EmployeeID,
                       p.FirstName,
                       p.MiddleName,
                       p.LastName,
                       dbo.SfMaskSSN(ISNULL(CONCAT(REPLICATE('0', 9 - LEN(p.SSN)), p.SSN), '000000000')),
                       dbo.SfOrganizationIdGet(@defaultofficeid, 'U'),
                       CASE
                           WHEN p.EmployeeType = 'Employee' THEN
                               'Employee'
                           WHEN p.EmployeeType = 'Applicant' THEN
                               'Applicant'
                           WHEN p.EmployeeType = 'NewHire' THEN
                               'NewHire'
                       END,
                       @UserPersonId,
                       GETDATE(),    -- ISNULL (p.Insertdate, GETDATE ()) ,
                       p.EmployeeID, --referenceid
                       @ReferenceNote,
                       dbo.SfEncrypt(
                                        ISNULL(
                                                  CONCAT(REPLICATE('0', 9 - LEN(ISNULL(p.SSN, 0))), ISNULL(p.SSN, 0)),
                                                  '000000000'
                                              ),
                                        'e'
                                    )
                --select count(*) 
                FROM #TempPerson AS p
                    LEFT JOIN dbo.Person AS p2
                        ON p2.ReferenceId = CONVERT(VARCHAR(50), p.EmployeeID)
                           AND p2.ReferenceNote = @ReferenceNote
                WHERE p2.PersonId IS NULL
                      AND p.EmployeeID > 0
                      AND p.EmployeeID NOT IN (
                                                  SELECT p3.PersonId FROM dbo.Person AS p3
                                              ); --adjusted

                SET IDENTITY_INSERT dbo.Person OFF;

                INSERT INTO dbo.Person
                (
                    FirstName,
                    MiddleName,
                    LastName,
                    SSN,
                    OrganizationId,
                    Title,
                    UserPersonId,
                    InsertDate,
                    ReferenceId,
                    ReferenceNote,
                    TIN
                )
                SELECT p.FirstName,
                       p.MiddleName,
                       p.LastName,
                       dbo.SfMaskSSN(ISNULL(CONCAT(REPLICATE('0', 9 - LEN(p.SSN)), p.SSN), '000000000')),
                       dbo.SfOrganizationIdGet(@defaultofficeid, 'U'),
                       CASE
                           WHEN p.EmployeeType = 'Employee' THEN
                               'Employee'
                           WHEN p.EmployeeType = 'Applicant' THEN
                               'Applicant'
                           WHEN p.EmployeeType = 'NewHire' THEN
                               'NewHire'
                       END,
                       @UserPersonId,
                       GETDATE(), -- ISNULL (p.Insertdate, GETDATE ()) ,
                       p.EmployeeID,
                       @ReferenceNote,
                       dbo.SfEncrypt(
                                        ISNULL(
                                                  CONCAT(REPLICATE('0', 9 - LEN(ISNULL(p.SSN, 0))), ISNULL(p.SSN, 0)),
                                                  '000000000'
                                              ),
                                        'e'
                                    )
                --select * 
                FROM #TempPerson AS p
                    LEFT JOIN dbo.Person AS p2
                        ON p2.ReferenceId = CONVERT(VARCHAR(50), p.EmployeeID)
                           AND p2.ReferenceNote = @ReferenceNote
                WHERE p2.PersonId IS NULL


                SELECT @NewCOunt = COUNT(*)
                FROM dbo.Person AS p
                    INNER JOIN #TempPerson AS tp
                        ON CONVERT(VARCHAR(50), tp.EmployeeID) = p.ReferenceId
                WHERE p.ReferenceNote = @ReferenceNote;

                EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                           @TableName = @TableName,
                                           @ReferenceNote = @ReferenceNote;

                SET @ErrorMessage
                    = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
                IF (@OldCount <> @NewCOunt)
                BEGIN
                    RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                END;



                ELSE IF (@OldCount = @NewCOunt)
                BEGIN
                    RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                END;
            END;
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;

END;


---===========================================================



-- organization start --------

--DROP TABLE IF EXISTS #tempcustomer;
SELECT cr.*
INTO #TempCustomer --select count(*)
FROM anuska_2024_new.dbo.CustomerData AS cr
WHERE cr.Migrationstatus = 'Migrate';

-- select * from #TempPerson
SELECT @TableName = 'Organization'

IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
        begin

            --1.Organization



            SELECT @OldCount = COUNT(*),
                   @TableName = 'Organization'
            --select count(*)
            FROM #TempCustomer AS tc;


            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                       @TableName = @TableName,
                                       @ReferenceNote = @ReferenceNote;

            SET IDENTITY_INSERT dbo.Organization ON;

            INSERT INTO dbo.Organization
            (
                OrganizationId,
                OfficeId,
                Organization,
                Department,
                ParentOrganizationId,
                RootOrganizationId,
                UserPersonId,
                InsertDate,
                ReferenceId,
                ReferenceNote
            )
            SELECT cr.CustomerID,
                   o.OfficeId,
                   LTRIM(RTRIM(cr.CustomerName)),
                   ISNULL(cr.Department, 'Primary'),
                   cr.ParentcustomerID,
                   cr.Rootcustomerid,
                   @UserPersonId,
                   getdate(),     --cr.DateEntered ,
                   CONVERT(VARCHAR(50), cr.customerId),
                   @ReferenceNote --select *
            FROM #TempCustomer AS cr
                INNER JOIN dbo.Office AS o
                    ON o.OfficeId = @defaultofficeid
                LEFT JOIN dbo.Organization AS o2
                    ON o2.ReferenceId = CONVERT(VARCHAR(50), cr.customerId)
                       AND o2.ReferenceNote = @ReferenceNote
            WHERE o2.OrganizationId IS NULL
                  AND cr.CustomerID > 0
                  AND cr.CustomerID NOT IN (
                                               SELECT o3.OrganizationId FROM dbo.Organization AS o3
                                           ); --adjusted
            SET IDENTITY_INSERT dbo.Organization OFF;

            INSERT INTO dbo.Organization
            (
                OfficeId,
                Organization,
                Department,
                ParentOrganizationId,
                RootOrganizationId,
                UserPersonId,
                InsertDate,
                ReferenceId,
                ReferenceNote
            )
            SELECT o.OfficeId,
                   LTRIM(RTRIM(cr.CustomerName)),
                   ISNULL(cr.Department, 'Primary'),
                   ParentOrganizationId,
                   RootOrganizationId,
                   @UserPersonId,
                   getdate(),
                   CONVERT(VARCHAR(50), cr.customerid),
                   @ReferenceNote
            FROM #TempCustomer AS cr
                INNER JOIN dbo.Office AS o
                    ON o.OfficeId = @defaultofficeid
                LEFT JOIN dbo.Organization AS o2
                    ON o2.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
                       AND o2.ReferenceNote = @ReferenceNote
            WHERE o2.OrganizationId IS NULL;


			  -- update parent ID and Root customerguid's

                            UPDATE c
                            SET    c.ParentOrganizationId = c2.OrganizationId
                            --SELECT * 
                            FROM   #TempCustomer tc
                                   INNER JOIN dbo.Organization c ON  c.ReferenceId = CONVERT (
                                                                                         VARCHAR (50), tc.CustomerID)
                                                                 AND c.ReferenceNote = 'testmigration_anuska'
                                   INNER JOIN dbo.Organization c2 ON  CONVERT (VARCHAR (50), tc.ParentcustomerID) = c2.ReferenceId
                                                                  AND c2.ReferenceNote = 'testmigration_anuska'
                            WHERE  tc.Migrationstatus = 'Migrate';

                            UPDATE c
                            SET    c.RootOrganizationId = c2.OrganizationId
                            --SELECT * 
                            FROM   #TempCustomer tc
                                   INNER JOIN dbo.Organization c ON  c.ReferenceId = CONVERT (
                                                                                         VARCHAR (50), tc.CustomerID)
                                                                 AND c.ReferenceNote = 'testmigration_anuska'
                                   INNER JOIN dbo.Organization c2 ON  CONVERT (VARCHAR (50), tc.RootCustomerID) = c2.ReferenceId
                                                                  AND c2.ReferenceNote = 'testmigration_anuska'
                            WHERE  tc.Migrationstatus = 'Migrate';

                            UPDATE o
                            SET    o.RootOrganizationId = o.OrganizationId
                            --SELECT * 
                            FROM   dbo.Organization o
                            WHERE  o.ReferenceNote = 'testmigration_anuska'
                            AND    o.RootOrganizationId IS NULL;



            SELECT @NewCOunt = COUNT(*)
            FROM dbo.Organization AS o
                INNER JOIN #TempCustomer AS tc
                    ON CONVERT(VARCHAR(50), tc.CustomerID) = o.ReferenceId
            WHERE o.ReferenceNote = @ReferenceNote;

            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                       @TableName = @TableName,
                                       @ReferenceNote = @ReferenceNote;


            SET @ErrorMessage
                = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
            IF (@OldCount <> @NewCOunt)
            BEGIN
                RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
            END;



            ELSE IF (@OldCount = @NewCOunt)
            BEGIN
                RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
            END;


        END;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;


---------------------===================================================================================


--9.Contact Info  

SELECT @TableName = 'ContactInformation'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;


        SELECT @OldCount = COUNT(*),
               @TableName = 'ContactInformation' --select count(*)
        FROM #TempCustomer AS cr

            --INNER JOIN dbo.Organization AS o ON o.ReferenceId = CONVERT (
            --                                                        VARCHAR (50) ,
            --                                                        cr.CustomerID)
            LEFT JOIN dbo.ContactInformation AS ci
                ON ci.ContactInformationId = cr.CustomerID
                   AND ci.ReferenceNote = 'TestMigration_Anuska'
        WHERE ci.ContactInformationId IS NULL
        --AND    ci.ReferenceNote = @ReferenceNote
        --AND    ISNULL (cm.ContactMethodValue, '') <> '';

        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        INSERT INTO dbo.ContactInformation
        (
            ContactInformationTypeListItemId,
            StatusListItemId,
            Value,
            UserPersonId,
            InsertDate,
            ReferenceId,
            ReferenceNote
        )
        SELECT @PhoneContactInformationTypeListItemId,
               @ActiveStatusListItemId,
               cr.contactinformation,
               @UserPersonId,
               getdate(),
               CONVERT(VARCHAR(50), cr.customerid),
               @ReferenceNote
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Organization AS o
                ON o.ReferenceId = CONVERT(VARCHAR(50), cr.CustomerID)
            LEFT JOIN dbo.ContactInformation AS ci
                ON ci.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
                   AND ci.ReferenceNote = @ReferenceNote
        WHERE ci.ContactInformationId IS NULL
              AND o.ReferenceNote = @ReferenceNote
        --  AND    ISNULL (cm.ContactMethodValue, '') <> '';

        SELECT @NewCOunt = COUNT(*)
        FROM dbo.ContactInformation C
            INNER JOIN anuska_2024_new.dbo.CustomerData AS cr
                ON CONVERT(VARCHAR(50), cr.customerid) = C.ReferenceId
                   AND C.ReferenceNote = @ReferenceNote

            --INNER JOIN #TempCustomer AS cr ON cr.CustomerGUID = c.FKGUID
            INNER JOIN dbo.Organization AS o
                ON o.ReferenceId = CONVERT(VARCHAR(50), cr.CustomerID)
                   AND o.ReferenceNote = @ReferenceNote
        WHERE cr.Migrationstatus = 'Migrate';

        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;



---------------------------------------=======================================================================================


--5.CustomerAddress
SELECT @TableName = 'Address-Organization:ALL'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

        SELECT @OldCount = COUNT(*),
               @TableName = 'Address-Organization:ALL'
        FROM #TempCustomer AS cr
        -- anuska_2024_new.dbo.CustomerData AS cr


        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;



        INSERT INTO dbo.Address
        (
            AddressTypeListItemId,
            StatusListItemId,
            Address1,
            Address2,
            City,
            StateId,
            ZipCode,
            AddressNote,
            UserPersonId,
            ReferenceId,
            ReferenceNote
        )
        SELECT DISTINCT
            @WorksiteAddressTypeListItemId,
            @ActiveStatusListItemId,
            cr.Address1,
            cr.Address2,
            cr.City,
            s.stateid,
            cr.Zip,
            Null,
            @UserPersonId,
            CONVERT(VARCHAR(50), cr.CustomerID),
            @ReferenceNote --select count(*)
        FROM #TempCustomer AS cr
            INNER JOIN dbo.State AS s
                ON s.StateCode = cr.State
            LEFT JOIN dbo.Address AS a2
                ON a2.ReferenceId = CONVERT(VARCHAR(50), cr.CustomerID)
                   AND a2.ReferenceNote = @ReferenceNote
        WHERE a2.AddressId IS NULL;

        --Adjusted date:1/29/2024 start
        SELECT @NewCOunt = COUNT(*)
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Address AS a
                ON a.ReferenceId = CONVERT(VARCHAR(50), cr.CustomerID)
                   AND a.ReferenceNote = @ReferenceNote;
        --Adjusted date:1/29/2024 END


        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;

----------------==============================================================================

--12. Organization service profile

SELECT @TableName = 'OrganizationServiceProfile'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

        SELECT @OldCount = COUNT(*),
               @TableName = 'OrganizationServiceProfile'
        FROM dbo.Organization AS o
            INNER JOIN #TempCustomer AS cr
                ON o.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
        WHERE o.ReferenceNote = @ReferenceNote;

        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        DECLARE @WeeklyPayPeriodListItemId INT = dbo.SfListItemIdGet('PayPeriod', 'Weekly');
        DECLARE @WeeklyTransactionTemplateListItemId INT = dbo.SfListItemIdGet('TransactionTemplate', 'Weekly');
        DECLARE @DueOnReceiptPaymentTermListItemId INT = dbo.SfListItemIdGet('PaymentTerm', 'DueOnReceipt');
        DECLARE @WeeklyInvoiceCycleListItemId INT = dbo.SfListItemIdGet('InvoiceCycle', 'Weekly');
        DECLARE @WeeklyPayCycleListItemId INT = dbo.SfListItemIdGet('PayCycle', 'Weekly');
        DECLARE @NoneCheckDeliveryListItemId INT = dbo.SfListItemIdGet('CheckDelivery', 'None');
        DECLARE @SundayPayPeriodEndDayListItemId INT = dbo.SfListItemIdGet('PayPeriodEndDay', 'Sunday');
        DECLARE @EmployerServiceTypeListItemId INT = dbo.SfListItemIdGet('ServiceType', 'Employer');
        DECLARE @NoneInvoiceDeliveryListItemId INT = dbo.SfListItemIdGet('InvoiceDelivery', 'None');
        DECLARE @PrintInvoiceDeliveryListItemId INT = dbo.SfListItemIdGet('InvoiceDelivery', 'Print');
        DECLARE @EmailInvoiceDeliveryListItemId INT = dbo.SfListItemIdGet('InvoiceDelivery', 'Email');

        DECLARE @ReportId INT = (
                                    SELECT pr.ReportId -- select * 
                                    FROM dbo.Report AS r
                                        INNER JOIN dbo.PaginatedReport AS pr
                                            ON pr.ReportId = r.ReportId
                                    WHERE r.Report = 'Invoice'
                                );

        INSERT INTO dbo.OrganizationServiceProfile
        (
            OrganizationId,
            CreditLimit,
            PaymentTermListItemId,
            InvoiceCycleListItemId,
            InvoiceWeek,
            PayCycleListItemId,
            PayWeek,
            CheckDeliveryListItemId,
            PayPeriodListItemId,
            OTPlanId,
            PayPeriodEndDayListItemId,
            TransactionTemplateListItemId,
            ServiceTypeListItemId,
            MilageRate,
            InvoiceToOrganizationId,
            InvoiceSeparateByListItem,
            MaxInvoiceAmount,
            UserPersonId,
            InsertDate,
            ReferenceId,
            ReferenceNote,
            EmailInvoiceTo,
            InvoiceGroupByListItem,
            InvoiceDisplayListItem,
            InvoiceDeliveryListItemId,
            IsAttachTimeCard,
            ReportId,
            [TransactionWeekListItemId],
            [WorksiteSourceListItemId]
        )
        SELECT o.OrganizationId,
               0 AS CreditLimit,
               md1.MapToId,
               @WeeklyInvoiceCycleListItemId,
               1,
               md2.MapToId,
               1,
               @NoneCheckDeliveryListItemId,
               @WeeklyPayPeriodListItemId,
               @defaultotplanid,
               @SundayPayPeriodEndDayListItemId,
               @WeeklyTransactionTemplateListItemId,
               @EmployerServiceTypeListItemId,
               0.00,
               o.OrganizationId,
               NULL,
               0,
               @UserPersonId,
               getdate(),
               cr.customerid,
               @ReferenceNote,
               NULL,
               NULL,
               NULL,
               @PrintInvoiceDeliveryListItemId,
               1,
               @ReportId,
               [dbo].[SfListItemIdGet]('TransactionWeek', 'PreviousWeek') AS [TransactionWeekListItemId],
               ('[' + CONVERT([NVARCHAR](1000), [dbo].[SfListItemIdGet]('Worksitesource', 'Worksite'))) + ']' AS [WorksiteSourceListItemId]
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Organization AS o
                ON o.ReferenceId = CONVERT(VARCHAR(50), cr.CustomerID)
            left JOIN dbo.OrganizationServiceProfile AS osp
                ON osp.ReferenceId = o.ReferenceId
            INNER JOIN dbo.MappingData md1
                ON md1.Data1 = CONVERT(VARCHAR(255), cr.PaymentTerms)
            inner join mappingdata md2
                on md2.Data1 = cr.PayCycle
            INNER JOIN dbo.Mapping m1
                ON md1.MappingId = m1.MappingId
                   AND m1.Mapping = 'PaymentTerm'
                   AND m1.MappingTypeId = @MappingTypeId
            INNER JOIN dbo.Mapping m2
                ON md2.MappingId = m2.MappingId
                   AND m2.Mapping = 'Customer_PayCycle'
                   AND m2.MappingTypeId = @MappingTypeId
        WHERE osp.OrganizationId IS NULL
              AND o.ReferenceNote = @ReferenceNote;


        SELECT @NewCOunt = COUNT(*)
        FROM #TempCustomer AS cr
            INNER JOIN dbo.OrganizationServiceProfile AS a
                ON a.ReferenceId = CONVERT(VARCHAR(50), cr.CustomerID)
                   AND a.ReferenceNote = @ReferenceNote;
        --Adjusted date:1/29/2024 END


        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;

-----------------===================================================================================================


--7.OrganizationAddress ALL 
SELECT @TableName = 'OrganizationAddress'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

        SELECT @OldCount = COUNT(*),
               @TableName = 'OrganizationAddress'
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Address AS a2
                ON a2.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
                   AND a2.ReferenceNote = @ReferenceNote;

        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        INSERT INTO dbo.OrganizationAddress
        (
            OrganizationId,
            AddressId,
            TransactionCodeId,
            UserPersonId
        )
        SELECT o.OrganizationId,
               a2.AddressId,
               Null,
               @UserPersonId
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Address AS a2
                ON a2.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
                   AND a2.ReferenceNote = @ReferenceNote
            INNER JOIN dbo.Organization AS o
                ON o.ReferenceId = CONVERT(VARCHAR(50), cr.CustomerID)
                   AND o.ReferenceNote = @ReferenceNote
            LEFT JOIN dbo.OrganizationAddress AS oa
                ON oa.OrganizationId = o.OrganizationId
        where o.ReferenceNote = @ReferenceNote
              and oa.OrganizationAddressId IS NULL;

        SELECT @NewCOunt = COUNT(*)
        FROM dbo.Address AS o
            INNER JOIN dbo.OrganizationAddress AS oa
                ON oa.AddressId = o.AddressId
        WHERE o.ReferenceNote = @ReferenceNote;


        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;


        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;

-----------------------====================================

-- 10 OrganizationContactInfo


SELECT @TableName = 'OrganizationContactInformation'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;


        SELECT @OldCount = COUNT(*),
               @TableName = 'OrganizationContactInformation'
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Organization AS o
                ON CONVERT(VARCHAR(50), cr.CustomerID) = o.ReferenceId
                   AND o.ReferenceNote = @ReferenceNote
            INNER JOIN dbo.ContactInformation AS ci
                ON ci.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
                   AND ci.ReferenceNote = @ReferenceNote
            LEFT JOIN dbo.OrganizationContactInformation AS oci
                ON oci.ContactInformationId = ci.ContactInformationId
                   AND oci.OrganizationId = o.OrganizationId
        WHERE oci.OrganizationContactInformationId IS NULL;

        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;


        INSERT INTO dbo.OrganizationContactInformation
        (
            OrganizationId,
            ContactInformationId,
            UserPersonId,
            InsertDate
        )
        SELECT o.OrganizationId,
               c.ContactInformationId,
               @UserPersonId,
               GETDATE()
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Organization AS o
                ON CONVERT(VARCHAR(50), cr.CustomerID) = o.ReferenceId
                   AND o.ReferenceNote = 'TestMigration_Anuska'
            INNER JOIN dbo.ContactInformation AS c
                ON c.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
                   AND c.ReferenceNote = 'TestMigration_Anuska'
            LEFT JOIN dbo.OrganizationContactInformation AS oci
                ON oci.ContactInformationId = c.ContactInformationId
                   AND oci.OrganizationId = o.OrganizationId
        WHERE oci.ContactInformationId IS NULL;

        SELECT @NewCOunt = COUNT(*)
        FROM dbo.ContactInformation C
            INNER JOIN dbo.OrganizationContactInformation AS oci
                ON oci.ContactInformationId = C.ContactInformationId
            INNER JOIN dbo.Organization AS o
                ON o.OrganizationId = oci.OrganizationId
                   AND o.ReferenceNote = @ReferenceNote
        WHERE C.ReferenceNote = @ReferenceNote;

        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;



-------------------========================================================


--4.Organization Current



SELECT @TableName = 'OrganizationCurrent'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;


        SELECT @OldCount = COUNT(*),
               @TableName = 'OrganizationCurrent'
        FROM #TempCustomer AS cr
            INNER JOIN dbo.Organization AS o
                ON o.ReferenceId = CONVERT(VARCHAR(50), cr.customerid)
        WHERE o.ReferenceNote = @ReferenceNote;

        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;



        INSERT INTO dbo.OrganizationCurrent
        (
            OrganizationId,
            EntityListItemId,
            UserPersonId
        )
        SELECT o.OrganizationId,
               @CustomerEntityId,
               @UserPersonId
        FROM dbo.Organization AS o
            INNER JOIN #TempCustomer AS cr
                ON o.ReferenceId = cr.customerid
            LEFT JOIN dbo.OrganizationCurrent AS oc
                ON oc.OrganizationId = o.OrganizationId
        WHERE oc.OrganizationId IS NULL
              -- AND    o.ReferenceNote = @ReferenceNote
              AND cr.Migrationstatus = 'Migrate';








        ----update address and conrtactid of customer::

        --				 cr
        --LEFT JOIN dbo.Organization AS o ON  o.ReferenceId = CONVERT (VARCHAR (50), cr.CustomerGUID)
        --WHERE  o.OrganizationId IS NULL

        --  WHERE cr.Migrationstatus = 'Migrate';

        UPDATE pc
        SET pc.AddressId = a.AddressId
        FROM dbo.OrganizationCurrent AS pc
            INNER JOIN dbo.OrganizationAddress AS pa
                ON pa.OrganizationId = pc.OrganizationId
            INNER JOIN dbo.Address AS a
                ON a.AddressId = pa.AddressId
            INNER JOIN dbo.ListItem AS li
                ON li.ListItemId = a.AddressTypeListItemId
            INNER JOIN dbo.Organization AS p
                ON p.OrganizationId = pa.OrganizationId
            INNER JOIN #TempCustomer AS cr
                ON CONVERT(VARCHAR(50), cr.customerid) = p.ReferenceId
                   AND p.ReferenceNote = 'TestMigration_Anuska'
        --WHERE  li.ListItem IN ( 'Main' )
        --AND    p.ReferenceNote = 'TestMigration_Anuska'
        --AND    pc.AddressId IS NULL;

        -- ContactInformationId Update  
        UPDATE pc
        SET pc.PhoneContactInformationId = ci.ContactInformationId
        FROM dbo.OrganizationCurrent AS pc
            INNER JOIN dbo.OrganizationContactInformation AS pci
                ON pci.OrganizationId = pc.OrganizationId
            INNER JOIN dbo.ContactInformation AS ci
                ON ci.ContactInformationId = pci.ContactInformationId
            INNER JOIN dbo.ListItem AS li
                ON li.ListItemId = ci.ContactInformationTypeListItemId
            INNER JOIN dbo.Organization AS p
                ON p.OrganizationId = pc.OrganizationId
            INNER JOIN #TempCustomer AS cr
                ON CONVERT(VARCHAR(50), cr.customerid) = p.ReferenceId
                   AND p.ReferenceNote = 'TestMigration_Anuska'



        --									  -- personid Update  
        --                     UPDATE pc
        --                     SET    pc.PersonId = p.personid
        --                     FROM   dbo.OrganizationCurrent AS pc
        --inner join person p on p.personid=pc.personid
        -- AND p.ReferenceNote = 'TestMigration_Anuska'


        -- select *From person p where  p.ReferenceNote = 'TestMigration_Anuska'
        ----inner join #TempPerson tp on tp.personid=p.personid
        ----LEFT JOIN dbo.Person AS p2 ON  p2.ReferenceId = CONVERT (
        ----                                                                                            VARCHAR (50) ,
        ----                                                                                            p.EmployeeID)
        --                                                                  -- AND p2.ReferenceNote = 'TestMigration_Anuska'

        --                            INNER JOIN #TempCustomer AS cr ON  CONVERT (VARCHAR (50), cr.customerid) = p.ReferenceId
        --                                                           AND p.ReferenceNote = 'TestMigration_Anuska'


        --             DROP TABLE IF EXISTS #TempPerson;
        --     SELECT er.*
        --    INTO   #TempPerson
        --    -- select count(*)
        --    FROM   anuska_2024_new.dbo.EmployeeData AS er
        --         --  LEFT JOIN dbo.Person AS p ON  p.ReferenceId = CONVERT (VARCHAR (36), er.EmployeeID)
        --                                     --AND p.ReferenceNote = @ReferenceNote
        --   -- WHERE  p.PersonId IS NULL
        --    where    er.Migrationstatus = 'Migrate';

        --update pc
        --set pc.personid=p.personid --select *
        --from dbo.organizationcurrent as pc
        --inner join person p  on p.personid=pc.personid
        --               where  p.ReferenceNote ='TestMigration_Anuska' and p.PersonId is null
        --   INNER JOIN
        --   select * from
        --   #TempPerson AS tp  where  tp.ReferenceNote = 'TestMigration_Anuska'


        --   select *from Person where ReferenceNote='TestMigration_Anuska'

        SELECT @NewCOunt = COUNT(*)
        FROM dbo.OrganizationCurrent AS c
            INNER JOIN dbo.Organization AS o
                ON o.OrganizationId = c.OrganizationId
            INNER JOIN #TempCustomer AS cr
                ON cr.customerid = o.ReferenceId
        WHERE o.ReferenceNote = @ReferenceNote;




        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;


        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;


--------------===============================================================
---person ::address

SELECT @TableName = 'Address:Person'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
        SELECT @OldCount = COUNT(*),
               @TableName = 'Address:Person' -- select count(*)
        -- select distinct er.state
        FROM #TempPerson tp
            INNER JOIN dbo.State AS s
                ON s.StateCode = tp.State;


        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        INSERT INTO dbo.Address
        (
            AddressTypeListItemId,
            StatusListItemId,
            Address1,
            Address2,
            City,
            StateId,
            ZipCode,
            UserPersonId,
            InsertDate,
            ReferenceId,
            ReferenceNote
        )
        SELECT @ResidentAddressTypeListItemId,
               @ActiveStatusListItemId,
               er.address1,
               er.Adress2,
               er.city,
               s.StateId,
               er.zip,
               @UserPersonId,
               getdate(),
               CONVERT(VARCHAR(50), er.employeeid),
               @ReferenceNote
        -- select count(*)
        FROM #TempPerson er
            INNER JOIN dbo.State AS s
                ON s.StateCode = er.State
            LEFT JOIN dbo.Address AS a
                ON a.ReferenceId = CONVERT(VARCHAR(50), er.employeeid)
                   AND a.ReferenceNote = @ReferenceNote
        WHERE a.AddressId IS NULL;

        SELECT @NewCOunt = COUNT(*)
        FROM #TempPerson AS er
            INNER JOIN dbo.Address AS a
                ON a.ReferenceId = CONVERT(VARCHAR(50), er.employeeid)
                   AND a.ReferenceNote = @ReferenceNote;

        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,           -- int
                                   @TableName = @TableName,         -- varchar(50)
                                   @ReferenceNote = @ReferenceNote; -- varchar(100)

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;


-----------------------====================================================================================s



--3.PersonAddress
SELECT @TableName = 'PersonAddress'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

        SELECT @OldCount = COUNT(*),
               @TableName = 'PersonAddress'
        -- select count(*)
        FROM #TempPerson tp
            INNER JOIN dbo.State AS s
                ON s.StateCode = tp.State;

        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,           -- int
                                   @TableName = @TableName,         -- varchar(50)
                                   @ReferenceNote = @ReferenceNote; -- varchar(100)

        INSERT INTO dbo.PersonAddress
        (
            PersonId,
            AddressId,
            UserPersonId,
            InsertDate
        )
        SELECT p.PersonId,
               a.AddressId,
               @UserPersonId,
               getdate()
        FROM dbo.Person AS p
            INNER JOIN #TempPerson AS tp
                ON CONVERT(VARCHAR(50), tp.EmployeeID) = p.ReferenceId
                   AND p.ReferenceNote = @ReferenceNote
            INNER JOIN dbo.Address AS a
                ON a.ReferenceId = CONVERT(VARCHAR(50), tp.employeeid)
                   AND a.ReferenceNote = @ReferenceNote
            LEFT JOIN dbo.PersonAddress AS pa
                ON pa.PersonId = p.PersonId
                   AND pa.AddressId = a.AddressId
        WHERE pa.PersonAddressId IS NULL;



        SELECT @NewCOunt = COUNT(*)
        FROM #TempPerson AS er
            INNER JOIN dbo.Address AS a
                ON a.ReferenceId = CONVERT(VARCHAR(50), er.employeeid)
                   AND a.ReferenceNote = @ReferenceNote
            INNER JOIN dbo.PersonAddress AS pa
                ON pa.AddressId = a.AddressId
                   AND a.ReferenceNote = @ReferenceNote;



        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,           -- int
                                   @TableName = @TableName,         -- varchar(50)
                                   @ReferenceNote = @ReferenceNote; -- varchar(100)

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;


------------------==================================================================

--4. ContactInformation

/*

                       DROP TABLE IF EXISTS #TempPerson;
         SELECT er.*
        INTO   #TempPerson
        -- select count(*)
        FROM   anuska_2024_new.dbo.EmployeeData AS er
             --  LEFT JOIN dbo.Person AS p ON  p.ReferenceId = CONVERT (VARCHAR (36), er.EmployeeID)
                                         --AND p.ReferenceNote = @ReferenceNote
       -- WHERE  p.PersonId IS NULL
        where    er.Migrationstatus = 'Migrate';
					  
	*/
SELECT @TableName = 'ContactInformation-Person'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

        SELECT @OldCount = COUNT(*),
               @TableName = 'ContactInformation-Person' --select count(*)
        FROM #TempPerson AS er
            CROSS APPLY
        (
            SELECT 'Email' AS ValueType,
                   Email AS Value
            UNION ALL
            SELECT 'Phone' AS ValueType,
                   Phone AS Value
        ) AS combined
        --LEFT JOIN dbo.ContactInformation AS ci ON  ci.ReferenceId = CONVERT (  VARCHAR (50) , er.employeeid)
        --                                                                        AND ci.ReferenceNote = 'TestMigration_Anuska'--@ReferenceNote
        -- WHERE  ci.ContactInformationId IS NULL
        --   AND    ISNULL (cm.ContactMethodValue, '') <> '';

        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,           -- int
                                   @TableName = @TableName,         -- varchar(50)
                                   @ReferenceNote = @ReferenceNote; -- varchar(100)

        INSERT INTO dbo.ContactInformation
        (
            ContactInformationTypeListItemId,
            StatusListItemId,
            Value,
            UserPersonId,
            InsertDate,
            ReferenceId,
            ReferenceNote
        )
        SELECT CASE
                   WHEN combined.ValueType = 'Email' THEN
                       @EmailContactInformationTypeListItemId
                   WHEN combined.ValueType = 'Phone' THEN
                       @PhoneContactInformationTypeListItemId
               END AS ContactInformationTypeListItemId,
               @ActiveStatusListItemId,
               combined.Value,
               @UserPersonId,
               getdate(),
               CONVERT(VARCHAR(50), er.employeeid),
               @ReferenceNote + '_person'
        FROM #TempPerson AS er
            CROSS APPLY
        (
            SELECT 'Email' AS ValueType,
                   Email AS Value
            UNION ALL
            SELECT 'Phone' AS ValueType,
                   Phone AS Value
        ) AS combined

        --LEFT JOIN dbo.ContactInformation AS ci ON  ci.ReferenceId = CONVERT (VARCHAR (50) , er.employeeid)
        -- AND ci.ReferenceNote =  @ReferenceNote
        WHERE combined.Value IS NOT NULL
        --  AND    ISNULL (cm.ContactMethodValue, '') <> '';

        SELECT @NewCOunt = COUNT(*)
        -- select count(*)
        FROM #TempPerson AS er
            CROSS APPLY
        (
            SELECT 'Email' AS ValueType,
                   Email AS Value
            UNION ALL
            SELECT 'Phone' AS ValueType,
                   Phone AS Value
        ) AS combined
        --left JOIN dbo.ContactInformation AS ci ON  ci.ReferenceId = CONVERT (  VARCHAR (50) , er.employeeid)
        --                                                                        AND ci.ReferenceNote ='TestMigration_Anuska'
        where combined.Value is not null --@ReferenceNote--



        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,           -- int
                                   @TableName = @TableName,         -- varchar(50)
                                   @ReferenceNote = @ReferenceNote; -- varchar(100)

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;



-----------------=======================================================================

--5. PersonContactInformation

/*
    SELECT er.*
        INTO   #TempPerson
        -- select *
        FROM   anuska_2024_new.dbo.EmployeeData AS er
             --  LEFT JOIN dbo.Person AS p ON  p.ReferenceId = CONVERT (VARCHAR (36), er.EmployeeID)
                                         --AND p.ReferenceNote = @ReferenceNote
       -- WHERE  p.PersonId IS NULL
        where    er.Migrationstatus = 'Migrate';

		*/
SELECT @TableName = 'PersonContactInformation'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
        SELECT @OldCount = COUNT(*),
               @TableName = 'PersonContactInformation' --select *
        FROM #TempPerson AS tp
            CROSS APPLY
        (
            SELECT 'Email' AS ValueType,
                   Email AS Value
            UNION ALL
            SELECT 'Phone' AS ValueType,
                   Phone AS Value
        ) AS combined
        where combined.Value is not null
        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,           -- int
                                   @TableName = @TableName,         -- varchar(50)
                                   @ReferenceNote = @ReferenceNote; -- varchar(100)

        INSERT INTO dbo.PersonContactInformation
        (
            PersonId,
            ContactInformationId,
            UserPersonId,
            InsertDate
        )
        SELECT p.PersonId,
               ci.ContactInformationId,
               @UserPersonId,
               getdate()
        FROM dbo.Person AS p
            INNER JOIN #TempPerson AS tp
                ON p.ReferenceId = CONVERT(VARCHAR(50), tp.EmployeeID)
                   AND p.ReferenceNote = @ReferenceNote
            INNER JOIN dbo.ContactInformation AS ci
                ON ci.ReferenceId = CONVERT(VARCHAR(50), tp.EmployeeID)
                   AND ci.ReferenceNote = @ReferenceNote + '_Person'
            LEFT JOIN dbo.PersonContactInformation AS pci
                ON pci.PersonId = p.PersonId
                   AND pci.ContactInformationId = ci.ContactInformationId
        WHERE pci.PersonContactInformationId IS NULL
              AND ci.ReferenceNote = @ReferenceNote + '_Person'


        SELECT @NewCOunt = COUNT(*) --select *
        FROM #TempPerson AS tp
            CROSS APPLY
        (
            SELECT 'Email' AS ValueType,
                   Email AS Value
            UNION ALL
            SELECT 'Phone' AS ValueType,
                   Phone AS Value
        ) AS combined
        where combined.Value is not null


        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,           -- int
                                   @TableName = @TableName,         -- varchar(50)
                                   @ReferenceNote = @ReferenceNote; -- varchar(100)

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;

-------------==================================================================================



-- Job Start


DROP TABLE IF EXISTS #tempjob;

SELECT DISTINCT
    jb.*
INTO #TempJOB
-- select *
FROM [anuska_2024_new].dbo.JobTitle AS jb
where jb.Migrationstatus = 'Migrate'





---------Job Migration Start------------------  

--1.Job  
SELECT @TableName = 'Job'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

        --DROP TABLE IF EXISTS #tempjob;
		/*
                   SELECT DISTINCT jb.*
                   INTO   #TempJOB
                   -- select *
                   FROM    [anuska_2024_new].dbo.JobTitle AS jb

                   where    jb.Migrationstatus = 'Migrate'
				   */

        SELECT @OldCount = COUNT(*),
               @TableName = 'Job' --select *
        FROM #TempJOB AS jb
            inner join [Anuska_2024_new].dbo.job j
                on j.JobID = jb.ID
            INNER JOIN dbo.Organization AS o2
                ON o2.ReferenceId = CONVERT(VARCHAR(50), j.CustomerID)
                   AND o2.ReferenceNote = @ReferenceNote
        -- WHERE  j.JobId IS NULL;


        EXEC dbo.SpMigrationLogIns @OldCount = @OldCount,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        DECLARE @TempJobWorkflowId INT,
                @JobCandidateWorkflowId INT;
        SELECT @JobCandidateWorkflowId = dbo.SfWorkflowIdGet('JobCandidate');
        SELECT @TempJobWorkflowId = dbo.SfWorkflowIdGet('TempJob');
        DECLARE @TempJobOpenWorkflowStageId INT = dbo.SfWorkflowStageIdGet('TempJob', 'Open');
        DECLARE @TempJobInProgressWorkflowStageId INT = dbo.SfWorkflowStageIdGet('TempJob', 'InProgress');
        DECLARE @TempJobFilledWorkflowStageId INT = dbo.SfWorkflowStageIdGet('TempJob', 'Filled');
        DECLARE @USDCurrencyListItemId INT = dbo.SfListItemIdGet('Currency', 'USD');
        DECLARE @TempJobApplicationId INT = (
                                                SELECT a.ApplicationId
                                                FROM dbo.Application AS a
                                                WHERE a.Application = 'TJM'
                                            );

        --CREATE NONCLUSTERED INDEX XReferenceIdJob ON dbo.Job ( ReferenceId );



        SET IDENTITY_INSERT dbo.Job ON;

        INSERT INTO dbo.Job
        (
            JobId,
            SkillId,
            OfficeId,
            OrganizationId,
            OrganizationAddressId,
            JobTitle,
            Description,
            PortalDescription,
            StatusListItemId,
            CurrencyListItemId,
            Required,
            OriginalRequired,
            StartDate,
            EndDate,
            IsAutoUpdateStage,
            TimeToFill,
            WorkflowStageId,
            WorkflowId,
            ReferenceId,
            ReferenceNote,
            Sunday,
            Monday,
            Tuesday,
            Wednesday,
            Thursday,
            Friday,
            Saturday,
            ShiftId,
            PayPeriodListItemId,
            DateFilled,
            UserPersonId,
            InsertDate,
            ApplicationId
        )
        SELECT jb.id,
               @ConvertedSkillID,
               @defaultofficeid,
               o2.OrganizationId,
               oa.OrganizationAddressId,
               jb.job,
               'Demo Title',
               'PortalDescription',
               200006,
               @USDCurrencyListItemId,
               1,
               Null,
               j.StartDate,
               j.EndDate,
               1,
			   0,
               200031, 
               @JobCandidateWorkflowId,
               jb.ID,
               @ReferenceNote,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               null,
               null,                 --from mapto
               null,
               @UserPersonId,
               getdate(),
               @TempJobApplicationId --select *
        FROM #TempJOB AS jb
            inner join [Anuska_2024_new].dbo.job j
                on j.JobID = jb.ID
            INNER JOIN dbo.Organization AS o2
                ON o2.ReferenceId = CONVERT(VARCHAR(50), j.CustomerID)
                   AND o2.ReferenceNote = @ReferenceNote
            inner join OrganizationAddress oa
                on oa.OrganizationId = o2.OrganizationId
            inner join Address a
                on a.addressid = oa.addressid
                   and a.ReferenceNote = @ReferenceNote
            LEFT JOIN dbo.OrganizationServiceProfile AS osp
                ON osp.OrganizationId = o2.OrganizationId
            LEFT JOIN dbo.Job AS j2
                ON j2.ReferenceId = CONVERT(VARCHAR(50), jb.id)
                   AND j2.ReferenceNote =@ReferenceNote + '-Job'
        WHERE 
               jb.ID > 0
              AND jb.ID NOT IN (
                                   SELECT JobId FROM dbo.Job
                               );


        SET IDENTITY_INSERT dbo.Job OFF;

        INSERT INTO dbo.Job
        (
            SkillId,
            OfficeId,
            OrganizationId,
            OrganizationAddressId,
            JobTitle,
            Description,
            PortalDescription,
            StatusListItemId,
            CurrencyListItemId,
            Required,
            OriginalRequired,
            StartDate,
            EndDate,
            IsAutoUpdateStage,
            TimeToFill,
            WorkflowStageId,
            WorkflowId,
            ReferenceId,
            ReferenceNote,
            Sunday,
            Monday,
            Tuesday,
            Wednesday,
            Thursday,
            Friday,
            Saturday,
            ShiftId,
            PayPeriodListItemId,
            DateFilled,
            UserPersonId,
            InsertDate,
            ApplicationId
        )
        SELECT @ConvertedSkillID,
               @defaultofficeid,
               o2.OrganizationId,
               oa.OrganizationAddressId,
               jb.job,
               'Demo Title',
               'PortalDescription',
               200006,
               @USDCurrencyListItemId,
               1,
               Null,
               j.StartDate,
               j.EndDate,
			   1,
               0,            
               200031,
               @JobCandidateWorkflowId,
               jb.ID,
               @ReferenceNote,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               null,
               null, --from mapto
               null,
               @UserPersonId,
               getdate(),
               @TempJobApplicationId
        FROM #TempJOB AS jb
            inner join [Anuska_2024_new].dbo.job j
                on j.JobID = jb.ID
            INNER JOIN dbo.Organization AS o2
                ON o2.ReferenceId = CONVERT(VARCHAR(50), j.CustomerID)
                   AND o2.ReferenceNote = @ReferenceNote
            inner join OrganizationAddress oa
                on oa.OrganizationId = o2.OrganizationId
            inner join Address a
                on a.addressid = oa.addressid
                   and a.ReferenceNote = @ReferenceNote
            LEFT JOIN dbo.OrganizationServiceProfile AS osp
                ON osp.OrganizationId = o2.OrganizationId
            LEFT JOIN dbo.Job AS j2
                ON j2.ReferenceId = CONVERT(VARCHAR(50), jb.id)
                   AND j2.ReferenceNote = @ReferenceNote + '-Job'
       -- WHERE j.JobId IS NULL



        SELECT @NewCOunt = COUNT(*) -- select *
        FROM #TempJOB jb
            inner join [Anuska_2024_new].dbo.job j
                on j.JobID = jb.ID
            INNER JOIN dbo.Organization AS o2
                ON o2.ReferenceId = CONVERT(VARCHAR(50), j.CustomerID)
                   AND o2.ReferenceNote = @ReferenceNote
        --inner join job j2 on j2.JobId=jb.ID
        --  where  j2.ReferenceNote =  'TestMigration_Anuska-Job'--@ReferenceNote+'-Job';




        EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt,
                                   @TableName = @TableName,
                                   @ReferenceNote = @ReferenceNote;

        SET @ErrorMessage = CONCAT('Old Count : ', @OldCount, ' New Count : ', @NewCOunt, ' For Table : ', @TableName);
        IF (@OldCount <> @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
        END;



        ELSE IF (@OldCount = @NewCOunt)
        BEGIN
            RAISERROR('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);

        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;

---------------===================================================================


  -- Assignment start

            --DROP TABLE #TempAssignment;

          
            -----------Assignment Migration start------------------------------  
         select distinct ar.*
		 into #TempAssignment from [Anuska_2024_new].dbo.Assignment as ar

                        --1.Assignment  
SELECT @TableName = 'Assignment'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'Assignment'
                            FROM   #TempAssignment AS ar;


                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;


                            DECLARE @DefaultAssignmentTypeListItemId INT = dbo.SfListItemIdGet (
                                                                               'AssignmentType' , 'Regular');
                            SET IDENTITY_INSERT dbo.Assignment ON;

                            INSERT INTO dbo.Assignment ( AssignmentId ,
                                                         JobId ,
                                                         PersonId ,
                                                         OfficeId ,
                                                         StatusListItemId ,
                                                         StartDate ,
                                                         EndDate ,
                                                         AssignmentTypeListItemId ,
                                                         EmployeeTypeListItemId ,
                                                         ShiftId ,
                                                         EndReasonListItemId ,
                                                         PerformanceListItemId ,
                                                         MarkUpId ,
                                                         UserPersonId ,
                                                         InsertDate ,
                                                         ReferenceId ,
                                                         ReferenceNote ,
                                                         WorkFlowStageId )
                                        SELECT  ar.assignmentid ,
														j.JobId ,
														p.PersonId ,
														@defaultofficeid,
														@ActiveStatusListItemId,
														ar.StartDate ,
														ar.EndDate ,
														@DefaultAssignmentTypeListItemId,
														@EmployeeEmployeeTypeListItemId,
														NULL ,
														md1.MapToId AS EndReasonListItemId ,
														null ,
														NULL ,
														@UserPersonId,
														getdate() ,
														ar.assignmentid,
														@ReferenceNote,
														dbo.SfWorkflowStageIdGet ('Assignment', 'Assignment')
                                        FROM   #TempAssignment ar
							INNER JOIN dbo.Job AS j ON  j.ReferenceId = CONVERT (
																		VARCHAR (50) ,
																		ar.assignmentid)
												AND j.ReferenceNote = @ReferenceNote
							INNER JOIN dbo.Person AS p ON  p.ReferenceId = CONVERT (
																			VARCHAR (50) ,
																			ar.AssignmentId)
													AND p.ReferenceNote =  @ReferenceNote
							LEFT JOIN dbo.Employee ee ON ee.PersonId = p.PersonId
							left join MappingData md1 on md1.data1=ar.endreason
							inner join mapping m on md1.MappingId=m.MappingId and m.Mapping='Assignment_EndReason'
							and m.MappingTypeId=@mappingtypeid
                                                                        
							LEFT JOIN dbo.Assignment AS a2 ON  a2.ReferenceId = CAST (ar.AssignmentId AS VARCHAR (50))
														AND a2.ReferenceNote =@ReferenceNote
																	WHERE  a2.AssignmentId IS NULL
																	  AND   ar.assignmentid NOT IN ( SELECT a2.AssignmentId
                                                                            FROM   dbo.Assignment AS a2 );


                            SET IDENTITY_INSERT dbo.Assignment OFF;

                            INSERT INTO dbo.Assignment ( 
                                                         JobId ,
                                                         PersonId ,
                                                         OfficeId ,
                                                         StatusListItemId ,
                                                         StartDate ,
                                                         EndDate ,
                                                         AssignmentTypeListItemId ,
                                                         EmployeeTypeListItemId ,
                                                         ShiftId ,
                                                         EndReasonListItemId ,
                                                         PerformanceListItemId ,
                                                         MarkUpId ,
                                                         UserPersonId ,
                                                         InsertDate ,
                                                         ReferenceId ,
                                                         ReferenceNote ,
                                                         WorkFlowStageId )
                                        SELECT  
														j.JobId ,
														p.PersonId ,
														@defaultofficeid,
														@ActiveStatusListItemId,
														ar.StartDate ,
														ar.EndDate ,
														@DefaultAssignmentTypeListItemId,
														@EmployeeEmployeeTypeListItemId,
														NULL ,
														md1.MapToId AS EndReasonListItemId ,
														null ,
														NULL ,
														@UserPersonId,
														getdate() ,
														ar.assignmentid,
														@ReferenceNote,
														dbo.SfWorkflowStageIdGet ('Assignment', 'Assignment')
                                        FROM   #TempAssignment ar
							INNER JOIN dbo.Job AS j ON  j.ReferenceId = CONVERT (
																		VARCHAR (50) ,
																		ar.assignmentid)
												AND j.ReferenceNote = @ReferenceNote
							INNER JOIN dbo.Person AS p ON  p.ReferenceId = CONVERT (
																			VARCHAR (50) ,
																			ar.AssignmentId)
													AND p.ReferenceNote =  @ReferenceNote
							LEFT JOIN dbo.Employee ee ON ee.PersonId = p.PersonId
							left join MappingData md1 on md1.data1=ar.endreason
							inner join mapping m on md1.MappingId=m.MappingId and m.Mapping='Assignment_EndReason'
							and m.MappingTypeId=@mappingtypeid
                                                                        
							LEFT JOIN dbo.Assignment AS a2 ON  a2.ReferenceId = CAST (ar.AssignmentId AS VARCHAR (50))
														AND a2.ReferenceNote =@ReferenceNote
																	WHERE  a2.AssignmentId IS NULL
															


										
                            SELECT @NewCOunt = COUNT (*)--select *
                            FROM   dbo.Job AS j
                                   INNER JOIN dbo.Assignment AS jr ON jr.JobId = j.JobId
                                   INNER JOIN #TempAssignment AS ar ON CONVERT (VARCHAR (50), ar.assignmentid) = jr.ReferenceId
                            WHERE  jr.ReferenceNote = @ReferenceNote;


                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);;
									end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;


-----------------=================================================================
--6.JobRate  


/*
                         SELECT DISTINCT
    jb.*
INTO #TempJOB
-- select *
FROM [anuska_2024_new].dbo.JobTitle AS jb
where jb.Migrationstatus = 'Migrate'

		 */

                        --1.Assignment  
SELECT @TableName = 'JobRate'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'JobRate' --select *
                            FROM   dbo.Job AS j
                                   INNER JOIN #TempJOB AS jb ON  j.ReferenceId = CONVERT (
                                                                                     VARCHAR (50), jb.id)
                                                             AND j.ReferenceNote = @ReferenceNote
                                



                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;



                            INSERT INTO dbo.JobRate ( JobId ,
                                                      TransactionCodeId ,
                                                      PayRate ,
                                                      BillRate ,
                                                      UserPersonId ,
                                                      InsertDate )

                                        SELECT   DISTINCT j.JobId ,
                                                          md.MapToId ,
                                                          j1.payrate ,
                                                          j1.billrate,
                                                          @UserPersonId ,
                                                          getdate()
                                        FROM     dbo.Job AS j
                                                 INNER JOIN #TempJOB AS jb ON  j.ReferenceId = CONVERT (
                                                                                                   VARCHAR (50) ,
                                                                                                   jb.ID)
                                                                           AND j.ReferenceNote = @ReferenceNote
												inner join [Anuska_2024_new].dbo.Job j1 on j1.JobID=jb.ID
                                                 INNER JOIN dbo.MappingData md ON md.Data1 =j1.paycodetype
                                                 INNER JOIN dbo.Mapping m ON  m.MappingId = md.MappingId
                                                                          AND m.MappingTypeId = @MappingTypeId
                                                                          AND m.Mapping = 'Transaction_Paycode'
                                                                         and MappingTypeId=@MappingTypeId
                                        
										   LEFT JOIN dbo.JobRate AS jr ON  jr.JobId = j.JobId
                                                                             AND jr.TransactionCodeId = md.MapToId
                                        WHERE    jr.JobRateId IS NULL
									 AND   jr.JobRateId NOT IN ( SELECT jr.JobRateId
                                                                            FROM   dbo.JobRate AS jr );



                            SELECT @NewCOunt = @OldCount;
                            --COUNT (*)
                            --                     FROM   dbo.Job AS j
                            --                            INNER JOIN dbo.JobRate AS jr ON jr.JobId = j.JobId
                            --                            INNER JOIN #TempJOB AS tj ON j.ReferenceId = CONVERT (
                            --                                                                             VARCHAR (50), tj.StaffingOrderGUID)
                            --                     WHERE  j.ReferenceNote = @ReferenceNote;



							SELECT @NewCOunt = COUNT (*)--select *
                            FROM   dbo.Job AS j
							INNER JOIN #TempJOB AS jb ON CONVERT (VARCHAR (50),jb.ID) = j.ReferenceId
                            WHERE  j.ReferenceNote = 'TestMigration_Anuska'-- @ReferenceNote;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                               end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;


------------------================================================================

 --3.AssignmentRate  
                        SELECT @TableName = 'AssignmentRate'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

		SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'AssignmentRate' --select *
                            FROM   dbo.Assignment AS ag
                                   INNER JOIN #TempAssignment AS ta ON  ag.ReferenceId = CONVERT (
                                                                                     VARCHAR (50), ta.AssignmentId)
                                                             AND ag.ReferenceNote = @ReferenceNote
           



                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;



                            INSERT INTO dbo.AssignmentRate ( AssignmentId ,
                                                             TransactionCodeId ,
                                                             PayRate ,
                                                             BillRate ,
                                                             UserPersonId ,
                                                             InsertDate )
                                        SELECT   a.AssignmentId ,
                                                 md.MapToId ,
                                                   ta.payrate,
												   ta.billrate,
                                                 @UserPersonId ,
                                                getdate()
                                        FROM     dbo.Assignment AS a
										inner join #TempAssignment ta on a.ReferenceId=ta.AssignmentId AND a.ReferenceNote = @ReferenceNote
                                        INNER JOIN dbo.MappingData md ON md.Data1 = ta.PayCode
                                                 INNER JOIN dbo.Mapping m ON  m.MappingId = md.MappingId
                                                                          AND m.MappingTypeId = @MappingTypeId
                                                                          AND m.Mapping = 'Transaction_Paycode'
                                                                         
                                                 LEFT JOIN dbo.AssignmentRate AS ar2 ON  ar2.AssignmentId = a.AssignmentId
                                                                                     AND ar2.TransactionCodeId = md.MapToId
                                        WHERE    ar2.AssignmentRateId IS NULL
										and a.ReferenceNote=@ReferenceNote

                                       




                            --since we need TO atleast ADD one RT transactionitem WITH 0 pay IF there AREn't  any transaction item from migration


                            --SELECT @OldCount = @OldCount + COUNT (1)
                            --FROM   dbo.Assignment AS a
                            --       LEFT JOIN dbo.AssignmentRate AS ar ON ar.AssignmentId = a.AssignmentId
                            --WHERE  ar.AssignmentId IS NULL
                            --AND    a.ReferenceNote = @ReferenceNote;


                            --INSERT INTO dbo.AssignmentRate ( AssignmentId ,
                            --                                 TransactionCodeId ,
                            --                                 PayRate ,
                            --                                 BillRate ,
                            --                                 UserPersonId ,
                            --                                 InsertDate )
                            --            SELECT a.AssignmentId ,
                            --                   @RTPayCodeId ,
                            --                   0 ,
                            --                   0 ,
                            --                   a.UserPersonId ,
                            --                   a.InsertDate
                            --            FROM   dbo.Assignment AS a
                            --                   LEFT JOIN dbo.AssignmentRate AS ar ON ar.AssignmentId = a.AssignmentId
                            --            WHERE  ar.AssignmentId IS NULL
                            --            AND    a.ReferenceNote = @ReferenceNote;

                            SELECT @NewCOunt = COUNT (*) --select *
                            FROM   dbo.Assignment AS jr
                                   left JOIN dbo.AssignmentRate n ON n.AssignmentId = jr.AssignmentId
                                   INNER JOIN #TempAssignment AS ta ON jr.ReferenceId = CONVERT (
                                                                                            VARCHAR (50) ,
                                                                                            ta.AssignmentId)
                            WHERE  jr.ReferenceNote = 'TestMigration_Anuska'--@ReferenceNote;


                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;


------------------==================================================================

--Bank Start
--1) Bank

select distinct tb.*
into #TempBank from [anuska_2024_new].dbo.EmployeeBank tb


 SELECT @TableName = 'Bank'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

		SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'Bank' --select *
                            FROM  #tempBank tb 
           



                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            INSERT INTO dbo.Bank ( Bank ,
                                                   RoutingNumber ,
                                                   ACHRoutingNumber ,
                                                   UserPersonId ,
												   InsertDate)

                           SELECT  distinct	
						   MAX (ISNULL (tb.BankName, 'N/A')),
						   
                            ISNULL (
                                REPLICATE ('0', 9 - LEN (tb.RoutingNumber))
                                + CONVERT (VARCHAR (30), tb.RoutingNumber) ,
                                '000000000') ,
                            ISNULL (
                                REPLICATE ('0', 9 - LEN (tb.RoutingNumber))
                                + CONVERT (VARCHAR (30), tb.RoutingNumber) ,
                                '000000000') ,
                            3 ,--@UserPersonId,
							getdate()
                    FROM    #tempbank tb 
                     LEFT JOIN dbo.Bank AS b ON b.RoutingNumber = ISNULL (
                                                                                REPLICATE (
                                                                                    '0' ,
                                                                                    9
                                                                                    - LEN (
                                                                                        tb.RoutingNumber))
                                                                                + CONVERT (
                                                                                    VARCHAR (30) ,
                                                                                    tb.RoutingNumber) ,
                                                                                '000000000')
                     -- left join #TempBank tb2 on tb2.EmployeeID=b.BankId
                                        WHERE   b.BankId IS NULL
										and tb.routingnumber  not in(select b.RoutingNumber from bank b)
										--and tb.RoutingNumber not in (select tb.RoutingNumber from 
										--#TempBank tb)
                                     AND      ISNULL (tb.RoutingNumber, '') <> ''


                                        GROUP BY ISNULL (
                                                     REPLICATE ('0', 9 - LEN (tb.RoutingNumber))
                                                     + CONVERT (VARCHAR (30), tb.RoutingNumber) ,
                                                     '000000000');


													 --no referencenote in bnk
                            SELECT @NewCOunt = COUNT (*) --select*
                            FROM   #tempbank tb 
                          


                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;


END;
---------------====================
-- bank node
/*
select distinct b.*
into #TempBankNode from Bank b
where
*/

--SELECT @TableName = 'BankNode'
--IF NOT EXISTS
--(
--    SELECT TOP 1
--        1
--    FROM dbo.MigrationLog as ml
--    where ml.ReferenceNote = @ReferenceNote
--          and ml.TableName = @TableName
--)
--begin
--    BEGIN TRY
--        begin transaction;

--		SELECT @OldCount = COUNT (*) ,
--                                   @TableName = 'BankNode' --select *
--                            FROM   dbo.Bank AS b
--							CROSS APPLY dbo.Office AS o
--                            LEFT JOIN dbo.BankNode AS bn ON  bn.BankId = b.BankId
--                                           AND o.NodeId = bn.NodeId                   
--                            WHERE  bn.BankNodeId IS NULL
--							and o.office='currie';

--INSERT INTO dbo.BankNode ( BankId ,
--                            NodeId ,
--                            UserPersonId ,
--                            InsertDate )

--                            SELECT b.BankId ,
--                                    o.NodeId ,
--                                  @UserPersonId ,
--                                    b.InsertDate
--                            FROM   dbo.Bank AS b
--                                    CROSS APPLY dbo.Office AS o
--                                    LEFT JOIN dbo.BankNode AS bn ON  bn.BankId = b.BankId
--                                                                AND o.NodeId = bn.NodeId
--                            WHERE  bn.BankNodeId IS NULL and o.office='currie';

-- SELECT @NewCOunt = @OldCount
-- --COUNT (*) --select*
-- --from bank b
-- --cross apply office o
-- --inner JOIN dbo.BankNode AS bn ON  bn.BankId = b.BankId
 
-- --where o.office ='currie' and bn.BankNodeId is null
                   
                        


--                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
--                                                       @TableName = @TableName ,
--                                                       @ReferenceNote = @ReferenceNote;

--                            SET @ErrorMessage = CONCAT (
--                                                    'Old Count : ' ,
--                                                    @OldCount ,
--                                                    ' New Count : ' ,
--                                                    @NewCOunt ,
--                                                    ' For Table : ' ,
--                                                    @TableName);
--                            IF ( @OldCount <> @NewCOunt )
--                                BEGIN
--                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
--                                END;



--                            ELSE IF ( @OldCount = @NewCOunt )
--                                BEGIN
--                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
--                                 end;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH;


--END;

------------------------------------------------------------
--routingnumber

 SELECT @TableName = 'routingnumber'


                INSERT INTO dbo.RoutingNumber ( RoutingNumber )
                            SELECT b.RoutingNumber
                            FROM   dbo.Bank AS b
                                    LEFT JOIN dbo.RoutingNumber AS rn ON rn.RoutingNumber = b.RoutingNumber
                            WHERE  rn.RoutingNumber IS NULL;


----------------=======================================
--person bank account


-- SELECT  distinct er.*
--    INTO #TempPerson
--    -- select count(*)
--    FROM anuska_2024_new.dbo.EmployeeData AS er
--    --  LEFT JOIN dbo.Person AS p ON  p.ReferenceId = CONVERT (VARCHAR (36), er.EmployeeID)
--    --AND p.ReferenceNote = @ReferenceNote
--    -- WHERE  p.PersonId IS NULL
--    where er.Migrationstatus = 'Migrate';

	 
--select distinct tb.*
--into #TempBank from [anuska_2024_new].dbo.EmployeeBank tb


 SELECT @TableName = 'PersonBankAccount'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
                     SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonBankAccount' -- select *
                            FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                               inner join #tempbank tb on tb.bankid=tp.employeeid
                                               INNER JOIN dbo.Bank AS b ON b.RoutingNumber = ISNULL (
                                                                                                 REPLICATE (
                                                                                                     '0' ,
                                                                                                     9
                                                                                                     - LEN (
                                                                                                           tb.RoutingNumber))
                                                                                                 + CONVERT (
                                                                                                       VARCHAR (30) ,
                                                                                                       tb.RoutingNumber) ,
                                                                                                 '000000000')
                                               INNER JOIN dbo.MappingData md
                                                          INNER JOIN dbo.Mapping mt ON mt.MappingId = md.MappingId ON  md.Data1 =tb.AccountType
                                                                                                                   AND mt.Mapping = 'Employee_BankAccountType'
                                                                                                                   AND mt.MappingTypeId =@MappingTypeId
                                                                                                                 
                                               INNER JOIN dbo.MappingData md1
                                                          INNER JOIN dbo.Mapping mt1 ON mt1.MappingId = md1.MappingId ON  md1.Data1 = tb.AmountType
                                                                                                                      AND mt1.Mapping = 'Employee_BankAmountType'
                                                                                                                      
                                               LEFT JOIN dbo.PersonBankAccount AS pba ON  pba.ReferenceId = CONVERT (
                                                                                                                VARCHAR (50) ,
                                                                                                                tb.employeeid)
                                                                                      AND pba.ReferenceNote =@ReferenceNote
                                        WHERE  pba.PersonBankAccountId IS NULL;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            INSERT INTO dbo.PersonBankAccount ( BankId ,
                                                                PersonId ,
                                                                AccountNumber ,
                                                                AccountTypeListItemId ,
                                                                StatusListItemId ,
                                                                Sequence ,
                                                                AmountTypeListItemId ,
                                                                Value ,
                                                                PrenoteDate ,
                                                                PrenoteApproveDate ,
                                                                Bank ,
                                                                Note ,
                                                                ActivationDate ,
                                                                UserPersonId ,
                                                                InsertDate ,
                                                                ReferenceId ,
                                                                ReferenceNote )
                                        SELECT b.BankId ,
                                               p.PersonId ,
                                               dbo.SfEncrypt (tb.AccountNumber, 'e') ,
                                               md.MapToId AS AccountTypeListItemId ,
                                               CASE 
														WHEN tb.Status = 'active' THEN '200006'
														ELSE '200007'
													END AS StatusListItemId,
                                               tb.Sequence ,
                                               md1.MapToId AS AmountTypeListItemId ,
                                               ISNULL (tb .AmountValue, 0) ,
                                              null ,
                                               null ,
                                               tb.bankname ,
                                               NULL ,
                                              null ,
                                               1 ,
                                               getdate(),
                                               tb.BankId,
                                              'testmigration_anuska'-- @ReferenceNote select *
                                         FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = 'testmigration_anuska'-- @ReferenceNote
                                               inner join #tempbank tb on tb.bankid=tp.employeeid
                                               INNER JOIN dbo.Bank AS b ON b.RoutingNumber = ISNULL (
                                                                                                 REPLICATE (
                                                                                                     '0' ,
                                                                                                     9
                                                                                                     - LEN (
                                                                                                           tb.RoutingNumber))
                                                                                                 + CONVERT (
                                                                                                       VARCHAR (30) ,
                                                                                                       tb.RoutingNumber) ,
                                                                                                 '000000000')
                                               INNER JOIN dbo.MappingData md
                                                          INNER JOIN dbo.Mapping mt ON mt.MappingId = md.MappingId ON  md.Data1 =tb.AccountType
                                                                                                                   AND mt.Mapping = 'Employee_BankAccountType'
																												   AND mt.MappingTypeId =200034
                                                                                                                  --@MappingTypeId
                                                                                                                 
                                               INNER JOIN dbo.MappingData md1
                                                          INNER JOIN dbo.Mapping mt1 ON mt1.MappingId = md1.MappingId ON  md1.Data1 = tb.AmountType
                                                                                                                      AND mt1.Mapping = 'Employee_BankAmountType'
																													   AND mt.MappingTypeId =200034
                                                                                                                      
                                               LEFT JOIN dbo.PersonBankAccount AS pba ON  pba.ReferenceId = CONVERT (
                                                                                                                VARCHAR (50) ,
                                                                                                                tb.BankId)
                                                                                      AND pba.ReferenceNote = 'testmigration_anuska'--@ReferenceNote
                                        WHERE  pba.PersonBankAccountId IS NULL;


                            SELECT @NewCOunt = COUNT (*) -- select *

                            FROM   dbo.Person AS p
                                   INNER JOIN #TempPerson AS tp ON CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                   INNER JOIN dbo.PersonBankAccount AS pba ON pba.PersonId = p.PersonId
                                   INNER JOIN dbo.Bank AS b ON b.BankId = pba.BankId
                            WHERE  pba.ReferenceNote = 'TestMigration_Anuska';

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)


                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;
	---------------------------==============================
	drop table if exists #tempemployeetax
	select * 
into #tempemployeetax 
from [anuska_2024_new].dbo.employeetax et




 SELECT @TableName = 'PersonTax'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)

begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonTax'
                            FROM  
										#tempemployeetax et 
										inner join person p on p.personid =et.employeeid
										inner join anuska_2024_new.dbo.EmployeeData as ed on ed.employeeid=p.personid
										INNER JOIN dbo.MappingData md
                                        INNER JOIN dbo.Mapping mt ON mt.MappingId = md.MappingId ON  md.Data1 =et.taxname
                                                                                                AND mt.Mapping = 'Payment_Tax'
																								AND mt.MappingTypeId =@mappingtypeid--200034
                                          
										LEFT JOIN dbo.PersonTax AS pt ON  pt.persontaxid = et.employeeid
                                                  AND pt.ReferenceNote =@ReferenceNote --'testmigration_anuska'  --
																			
                                        WHERE  pt.PersonTaxId IS NULL;




                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                  
                            INSERT INTO dbo.PersonTax ( PersonId ,
                                                        TransactionCodeId ,
                                                        StatusListItemId ,
                                                        IsExempt ,
                                                        HasNonResidentCertificate ,
                                                        Rate ,
                                                        AdditionalWH ,
                                                        MTD ,
                                                        QTD ,
                                                        YTD ,
                                                        LTD ,
                                                        UserPersonId ,
                                                        InsertDate ,
                                                        ReferenceId ,
                                                        ReferenceNote )

                                        SELECT DISTINCT p.PersonID ,
                                                        md.maptoid ,
                                                        dbo.SfListItemIdGet ('Status', 'Active') ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        @UserPersonId ,
                                                        GETDATE () ,
                                                       et.employeeid,
													   @referencenote
                                      FROM  
										#tempemployeetax et 
										inner join person p on p.personid =et.employeeid
										inner join anuska_2024_new.dbo.EmployeeData as ed on ed.employeeid=p.personid
										INNER JOIN dbo.MappingData md
                                        INNER JOIN dbo.Mapping mt ON mt.MappingId = md.MappingId ON  md.Data1 =et.taxname
                                                                                                                   AND mt.Mapping = 'Payment_Tax'
																												   AND mt.MappingTypeId =@MappingTypeId--200034
                                          
										LEFT JOIN dbo.PersonTax AS pt ON  pt.persontaxid = et.employeeid
                                                  AND pt.ReferenceNote =@ReferenceNote --'testmigration_anuska' 
																			
                                        WHERE  pt.PersonTaxId IS NULL;
										

-- additional withholding
                --UPDATE pt
                --SET    pt.AdditionalWH = pert.AdditionalWithholding
                ----SELECT pt.AdditionalWH ,pert.AdditionalWithholding, *
                --FROM   dbo.Person AS p
                --        INNER JOIN dbo.PersonTax AS pt ON pt.PersonId = p.PersonId
                --        INNER JOIN [anuska_2024_new].dbo.Employeedata AS tp ON  CONVERT (VARCHAR (50) ,
                --                                                                            tp.EmployeeID) = p.ReferenceId
                --                                                                    AND p.ReferenceNote = 'testmigration_anuska'
                --        INNER JOIN [anuska_2024_new].dbo.EmployeeTax AS petr ON  CONVERT (VARCHAR (50) ,petr.EmployeeID) = pt.ReferenceId
                --                                                                        AND pt.ReferenceNote = 'testmigration_anuska'
                --                                                                        AND tp.Migrationstatus = 'Migrate'
                                                                                        
                        

								   SELECT @NewCOunt = @OldCount;
                        
                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;

						

                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                             end;
							

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;
	
------------================================================================

 SELECT @TableName = 'PersonAdjustment'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonAdjustment'
                           FROM   dbo.Person AS p
										inner join #tempperson as tp on tp.employeeid=p.personid 
                                         inner join [anuska_2024_new].dbo.employeededuction ed on ed.employeeid=tp.employeeid
										INNER JOIN dbo.MappingData md
                                        INNER JOIN dbo.Mapping mt ON mt.MappingId = md.MappingId ON  md.Data1 =ed.DeductionType

                                                                                                                   AND mt.Mapping = 'Payment_deduction'
																												   AND mt.MappingTypeId =@MappingTypeId
                                            LEFT JOIN dbo.PersonAdjustment AS pa ON  pa.ReferenceId = CONVERT (
                                                                                                 VARCHAR (50) ,
                                                                                                 ed.EmployeeDeductionID)
                                                                        AND pa.ReferenceNote = @ReferenceNote

                                        WHERE  pa.PersonAdjustmentId IS NULL
                                        AND    tp.Migrationstatus = 'Migrate';




                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            INSERT INTO dbo.PersonAdjustment ( PersonId ,
                                                               TransactionCodeId ,
                                                               AgencyOrganizationId ,
                                                               OrganizationId ,
                                                               StartDate ,
                                                               EndDate ,
                                                               AdjustmentTypeListItemId ,
                                                               Adjustment ,
                                                               StatusListItemId ,
                                                               PayPeriodLimit ,
                                                               ImplementAllOrNothing ,
                                                               MonthlyLimit ,
                                                               YearlyLimit ,
                                                               LifeTimeLimit ,
                                                               PayPeriodTotal ,
                                                               MonthlyTotal ,
                                                               LifeTimeTotal ,
                                                               YearlyTotal ,
                                                               MaxDIPercent ,
                                                               Sequence ,
                                                               Reference ,
                                                               FlagDuringPayroll ,
                                                               UserPersonId ,
                                                               InsertDate ,
                                                               Note ,
                                                               ReferenceId ,
                                                               ReferenceNote )

                                        SELECT DISTINCT p.PersonId ,
                                                        md.maptoid,
                                                        NULL ,
                                                       200001,-- o.organizationid ,
                                                       ed.startdate,
													   ed.enddate,
                                                       200810,
                                                        ed.amount ,
														dbo.SfListItemIdGet ('Status', 'Active') ,
                                                        0 ,
                                                        0 ,
                                                       0 ,
                                                       0 ,
                                                        0,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
														0,
                                                       1 ,
                                                       0,
                                                        0 ,
                                                      @UserPersonId ,
                                                      getdate() ,
                                                       'personadjustment_migarte' ,
                                                        ed.employeeid,
                                                        @ReferenceNote
                                        FROM   dbo.Person AS p
										inner join #tempperson as tp on tp.employeeid=p.personid 
                                         inner join [anuska_2024_new].dbo.employeededuction ed on ed.employeeid=tp.employeeid
										INNER JOIN dbo.MappingData md
                                        INNER JOIN dbo.Mapping mt ON mt.MappingId = md.MappingId ON  md.Data1 =ed.DeductionType
                                                           AND mt.Mapping = 'Payment_deduction' AND mt.MappingTypeId =@MappingTypeId
                                            LEFT JOIN dbo.PersonAdjustment AS pa ON  pa.ReferenceId = CONVERT (
                                                                                                 VARCHAR (50) ,
                                                                                                 ed.EmployeeDeductionID)
                                                                        AND pa.ReferenceNote = @ReferenceNote

                                        WHERE  pa.PersonAdjustmentId IS NULL
                                        AND    tp.Migrationstatus = 'Migrate';



                            SELECT @NewCOunt = @OldCount;
                            --COUNT (*)
                            --                     FROM   dbo.Person AS p
                            --                            INNER JOIN #TempPerson AS tp ON CONVERT (VARCHAR (50), tp.EmployeeGUID) = p.ReferenceId
                            --                            INNER JOIN dbo.PersonAdjustment AS pa ON pa.PersonId = p.PersonId
                            --                     WHERE  pa.ReferenceNote = @ReferenceNote
                            --                     AND    tp.Migrationstatus = 'Migrate';

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                               end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;


-----------------==================================
--personnode


	 SELECT @TableName = 'PersonNode'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;


                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonNode'
                            FROM   dbo.Person AS p
                                 
                                   LEFT JOIN dbo.PersonNode pn ON  pn.PersonId = p.PersonId
                                                              
                            WHERE  pn.PersonNodeId IS NULL
                            AND    p.ReferenceNote = @ReferenceNote;

                            -- insert for migration log    
                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            INSERT INTO dbo.PersonNode ( PersonId ,
                                                         NodeId ,
                                                         UserPersonId ,
                                                         InsertDate )
                                        SELECT DISTINCT p.PersonId ,
                                                        200001 ,
                                                        @UserPersonId ,
                                                       getdate()
                                        FROM   dbo.Person AS p
                                               LEFT JOIN dbo.PersonNode pn ON  pn.PersonId = p.PersonId
                                                                          
                                        WHERE  pn.PersonNodeId IS NULL
                                        AND    p.ReferenceNote = @ReferenceNote ;

                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.PersonNode AS pn
                                   INNER JOIN dbo.Person AS p ON p.PersonId = pn.PersonId
                            WHERE  p.ReferenceNote = @ReferenceNote ;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                           end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;
------==========================================================

  --7.PersonCurrent
                         SELECT @TableName = 'PersonCurrent'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonCurrent'
                            FROM   dbo.Person AS p
                                   INNER JOIN #TempPerson AS tp ON p.ReferenceId = CONVERT (VARCHAR (50), tp.EmployeeID)
                            WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)
                           

                           

                            INSERT INTO dbo.PersonCurrent ( PersonId ,
                                                            OfficeId ,
                                                            EntityListItemId ,
                                                            UserPersonId ,
                                                            InsertDate ,
                                                            EVerifyStatusListItemId ,
                                                            WOTCStatusListItemId )
                                        SELECT p.PersonId ,
                                               200001 ,
											  CASE WHEN er.EmployeeType = 'Employee' THEN @EmployeeEntityListItemId
                                                    WHEN er.EmployeeType = 'Applicant' THEN @ApplicantEntityListItemId
                                                    WHEN er.EmployeeType = 'NewHire' THEN @NewHireEntityListItemId
                                               END ,
                                               @UserPersonId ,
                                               getdate() ,
                                               @AuthorizedEVerifyStatusListItemId,
                                               @WOTCStatusListItemId
                                        FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS er ON  CONVERT (VARCHAR (50), er.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
											   LEFT JOIN dbo.PersonCurrent AS pc ON pc.PersonId = p.PersonId
										 WHERE  pc.PersonId IS NULL;


										 
										  UPDATE pc
                            SET    pc.AddressId = a.AddressId
                            FROM   dbo.PersonCurrent AS pc
                                   INNER JOIN dbo.PersonAddress AS pa ON pa.PersonId = pc.PersonId
                                   INNER JOIN dbo.Address AS a ON a.AddressId = pa.AddressId
                                   INNER JOIN dbo.ListItem AS li ON li.ListItemId = a.AddressTypeListItemId
                                   INNER JOIN dbo.Person AS p ON p.PersonId = pa.PersonId
                                   INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                AND p.ReferenceNote = 'testmigration_anuska'
                            WHERE  li.ListItem IN ( 'Resident' )
                            AND    p.ReferenceNote = 'testmigration_anuska'
                            AND    pc.AddressId IS NULL;

							 -- ContactInformationId Update  

					UPDATE pc
SET    pc.PhoneContactInformationId = ci.ContactInformationId
--select pc.PhoneContactInformationId , ci.ContactInformationId,cm.* --select count(1)
FROM   dbo.PersonCurrent AS pc
       INNER JOIN dbo.PersonContactInformation AS pci ON pci.PersonId = pc.PersonId
       INNER JOIN dbo.ContactInformation AS ci ON ci.ContactInformationId = pci.ContactInformationId
       INNER JOIN dbo.ListItem AS li ON li.ListItemId = ci.ContactInformationTypeListItemId
       INNER JOIN dbo.Person AS p ON p.PersonId = pc.PersonId
       INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                    AND p.ReferenceNote = 'testmigration_anuska'
       
WHERE  li.ListItem IN ( 'Phone', 'HomePhone' )
AND    p.ReferenceNote = 'testmigration_anuska'
AND    pc.PhoneContactInformationId IS NULL;


 UPDATE pc
SET    pc.EmailContactInformationId = ci.ContactInformationId
FROM   dbo.PersonCurrent AS pc
        INNER JOIN dbo.PersonContactInformation AS pci ON pci.PersonId = pc.PersonId
        INNER JOIN dbo.ContactInformation AS ci ON ci.ContactInformationId = pci.ContactInformationId
        INNER JOIN dbo.ListItem AS li ON li.ListItemId = ci.ContactInformationTypeListItemId
        INNER JOIN dbo.Person AS p ON p.PersonId = pc.PersonId
        INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                    AND p.ReferenceNote = 'testmigration_anuska'
WHERE  li.ListItem IN ( 'Email' )
AND    p.ReferenceNote = 'testmigration_anuska'
AND    pc.EmailContactInformationId IS NULL;

update pc
set pc.assignmentid=ag.assignmentid  -- select *
from dbo.PersonCurrent pc
inner join  [Anuska_2024_new].dbo.Assignment ag on ag.EmployeeID=pc.PersonId
 INNER JOIN dbo.Person AS p ON p.PersonId = pc.PersonId
  --INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
  --                                  AND p.ReferenceNote = 'testmigration_anuska'
where pc.AssignmentId is null;

										SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.PersonCurrent AS pc
                                   INNER JOIN dbo.Person AS p ON p.PersonId = pc.PersonId
                            WHERE  p.ReferenceNote = @ReferenceNote ;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);

 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;

----=============================================================================

--EMployee user
                            
					 SELECT @TableName = 'User'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'User'
                            FROM  dbo.Person AS p
                                               INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                               LEFT JOIN dbo.[User] AS u ON u.PersonId = p.PersonId
                                        WHERE  u.PersonId IS NULL
                                        AND    p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)
                           

					
							INSERT INTO dbo.[User] ( PersonId ,
                                                     UserName ,
                                                     Password ,
                                                     RoleId ,
                                                     CultureId ,
                                                     StatusListItemId ,
                                                     NavigationStyleListItemId ,
                                                     ThemeListItemId ,
                                                     IsNavigationPin ,
                                                     UserPersonId ,
                                                     InsertDate )
                                        SELECT p.PersonId ,
                                               ISNULL (p.Name, p.PersonId) AS UserName ,
                                               dbo.SfEncrypt ('password', 'e') ,
                                               CASE WHEN tp.EmployeeType = 'Employee' THEN @EmployeeRoleId
                                                    WHEN tp.EmployeeType = 'Applicant' THEN @ApplicantRoleId
                                                    WHEN tp.EmployeeType = 'NewHire' THEN @NewHireRoleId
                                               END ,
                                               @CultureId ,
                                               @ActiveStatusListItemId ,
                                               @LeftNavigationStyleListIitemID ,
                                               @LightThemeListitemId ,
                                               1 ,
                                               @UserPersonId ,
                                               getdate()
                                        FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                               LEFT JOIN dbo.[User] AS u ON u.PersonId = p.PersonId
                                        WHERE  u.PersonId IS NULL
                                        AND    p.ReferenceNote = @ReferenceNote;


                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.Person p
                                   INNER JOIN #TempPerson AS tp ON CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                   INNER JOIN dbo.[User] AS pt ON pt.PersonId = p.PersonId
                            WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                            end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;

-----------==========================================================================================

 --10.PersonRole
                        SELECT @TableName = 'PersonRole'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonRole'
                            FROM   dbo.Person AS p
                                   INNER JOIN #TempPerson AS tp ON CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                            WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            INSERT INTO dbo.PersonRole ( PersonId ,
                                                         RoleId ,
                                                         UserPersonId ,
                                                         ApplicationId )
                                        SELECT p.PersonId ,
                                               CASE WHEN tp.EmployeeType = 'Employee' THEN @EmployeeRoleId
                                                    WHEN tp.EmployeeType = 'Applicant' THEN @ApplicantRoleId
                                                    WHEN tp.EmployeeType = 'NewHire' THEN @NewHireRoleId
                                               END ,
                                               @UserPersonId ,
                                               CASE WHEN tp.EmployeeType = 'Employee' THEN @EmployeePortalApplicationId
                                                    WHEN tp.EmployeeType = 'Applicant' THEN
                                                        @ApplicantPortalApplicationId
                                                    WHEN tp.EmployeeType = 'NewHire' THEN @NewHirePortalApplicationId
                                               END
                                        FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                               LEFT JOIN dbo.PersonRole AS pr ON pr.PersonId = p.PersonId
                                        WHERE  pr.PersonRoleId IS NULL
                                        AND    p.ReferenceNote = @ReferenceNote;

                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.Person p
                                   INNER JOIN #TempPerson AS tp ON CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                   INNER JOIN dbo.PersonRole pt ON pt.PersonId = p.PersonId
                            WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)
                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                               end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;

-----=============================================================

 --11.PersonWorkflowStage--Employee
                        SELECT @TableName = 'PersonWorkflowStage:Employee'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonWorkflowStage:Employee'
                            FROM   dbo.Person AS p
                                   INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                AND tp.EmployeeType = 'Employee'
                                   CROSS APPLY dbo.Workflow AS w
                                   INNER JOIN dbo.WorkflowStage AS ws ON w.WorkflowId = ws.WorkflowId
                                   LEFT JOIN dbo.PersonWorkflowStage AS pws ON  p.PersonId = pws.PersonId
                                                                            AND pws.WorkflowStageId = ws.WorkflowStageId
                            WHERE  w.Workflow = 'Employee'
                            AND    pws.PersonWorkflowStageId IS NULL
                            AND    p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            INSERT INTO dbo.PersonWorkflowStage ( PersonId ,
                                                                  WorkflowStageId ,
                                                                  UserPersonId )
                                        SELECT p.PersonId ,
                                               ws.WorkflowStageId ,
                                               @UserPersonId
                                        FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                            AND tp.EmployeeType = 'Employee'
                                               CROSS APPLY dbo.Workflow AS w
                                               INNER JOIN dbo.WorkflowStage AS ws ON w.WorkflowId = ws.WorkflowId
                                               LEFT JOIN dbo.PersonWorkflowStage AS pws ON  p.PersonId = pws.PersonId
                                                                                        AND pws.WorkflowStageId = ws.WorkflowStageId --@EmployeeWorkflowStageId
                                        WHERE  w.Workflow = 'Employee'
                                        AND    pws.PersonWorkflowStageId IS NULL
                                        AND    p.ReferenceNote = @ReferenceNote;


                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.Person p
                                   INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                AND tp.EmployeeType = 'Employee'
                                   INNER JOIN dbo.PersonWorkflowStage AS put ON put.PersonId = p.PersonId
                            WHERE  p.ReferenceNote = @ReferenceNote;


                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                             end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;


---------------------------==============================
--person datetype

SELECT @TableName = 'person datetype'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'person datetype'
                            FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS er ON  CONVERT (VARCHAR (50), er.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                               LEFT JOIN dbo.PersonDateType AS pdt ON  pdt.PersonId = p.PersonId
                                                                                   AND pdt.DateTypeListItemId = @LastPasswordChangeDateListItemId
                                        WHERE  pdt.PersonDateTypeId IS NULL;


                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                                 INSERT INTO dbo.PersonDateType ( PersonId ,
                                                             DateTypeListItemId ,
                                                             Date ,
                                                             UserPersonId )
                                        SELECT p.PersonId ,
                                               @LastPasswordChangeDateListItemId ,
                                               GETDATE () ,
                                               @UserPersonId
                                        FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS er ON  CONVERT (VARCHAR (50), er.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                               LEFT JOIN dbo.PersonDateType AS pdt ON  pdt.PersonId = p.PersonId
                                                                                   AND pdt.DateTypeListItemId = @LastPasswordChangeDateListItemId
                                        WHERE  pdt.PersonDateTypeId IS NULL;





                            SELECT @NewCOunt = @OldCount;
                            --COUNT (*)
                            --                     FROM   dbo.Person AS p
                            --                            INNER JOIN #TempPerson AS tp ON CONVERT (VARCHAR (50), tp.EmployeeGUID) = p.ReferenceId
                            --                            INNER JOIN dbo.PersonDateType AS pdt ON pdt.PersonId = p.PersonId
                            --                     WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)
                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                              end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;

----------------===========================================================================

  --11 PersonApplication   
  

                        SELECT @TableName = 'PersonApplication'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonApplication'
                            FROM   dbo.Person AS p
                                   INNER JOIN #TempPerson AS tc ON CONVERT (VARCHAR (36), tc.EmployeeID) = p.ReferenceId
                            WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            INSERT INTO dbo.PersonApplication ( PersonId ,
                                                                ApplicationId ,
                                                                WorkflowId ,
                                                                UserPersonId ,
                                                                InsertDate )
                                        SELECT p.PersonId ,
                                               CASE WHEN tc.EmployeeType = 'Employee' THEN @EmployeePortalApplicationId
                                                    WHEN tc.EmployeeType = 'Applicant' THEN
                                                        @ApplicantPortalApplicationId
                                                    WHEN tc.EmployeeType = 'NewHire' THEN @NewHirePortalApplicationId
                                               END AS ApplicationId ,
                                               CASE WHEN tc.EmployeeType = 'Employee' THEN @EmployeeWorkflowId
                                                    WHEN tc.EmployeeType = 'Applicant' THEN @ApplicantWorkflowId
                                                    WHEN tc.EmployeeType = 'NewHire' THEN @NewHireWorkflowId
                                               END AS WorkflowId ,
                                               @UserPersonId ,
                                               p.InsertDate
                                        FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS tc ON  CONVERT (VARCHAR (50), tc.EmployeeID) = p.ReferenceId
                                                                            AND tc.Migrationstatus = 'Migrate'
                                               LEFT JOIN dbo.PersonApplication AS pr ON pr.PersonId = p.PersonId
                                        WHERE  pr.PersonApplicationId IS NULL
                                        AND    p.ReferenceNote = @ReferenceNote;


                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.PersonApplication AS pr
                                   INNER JOIN dbo.Person AS p ON p.PersonId = pr.PersonId
                                   INNER JOIN #TempPerson AS tc ON tc.EmployeeID = p.ReferenceId
                            WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;


                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;

----==========================================================================================================
--PersonTaxParameter

 SELECT @TableName = 'PersonTaxParameter'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'PersonTaxParameter'
                            FROM   #TempPerson AS er 
									inner join person p on p.referenceid=er.employeeid
									and p.referencenote=@referencenote
								INNER JOIN dbo.PersonTax AS pt ON pt.PersonId = p.referenceid  and pt.referencenote=@referencenote

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;
                                    INSERT INTO dbo.PersonTaxParameter ( PersonTaxId ,
                                                                 TaxParameterId ,
                                                                 Value ,
                                                                 UserPersonId )
                                        SELECT DISTINCT pt.PersonTaxId ,
                                                        tpv.TaxParameterId ,
                                                        tpv.Value ,
                                                        @UserPersonId --select *
                                        FROM      #TempPerson AS er 
												  inner join person p on p.referenceid=er.employeeid
												  and p.referencenote=@referencenote
											  INNER JOIN dbo.PersonTax AS pt ON pt.PersonId = p.referenceid  and pt.referencenote=@referencenote
                                               INNER JOIN #tempEmployeeTax AS petr ON  CONVERT (
                                                                                       VARCHAR (50), petr.employeeId) = pt.ReferenceId
                                                                               AND pt.ReferenceNote = @referencenote
                                                                                AND er.Migrationstatus = 'Migrate'

                                              INNER JOIN dbo.MappingData md
                                        left JOIN dbo.Mapping mt ON mt.MappingId = md.MappingId ON  md.Data1 =petr.filingstatus
                                                           AND mt.Mapping = 'EmployeeTax_FilingStatus' AND mt.MappingTypeId =@MappingTypeId
														   AND ISNULL (md.MapTo, '') <> 'DoNotMigrate'

             
                                               INNER JOIN dbo.TaxParameterValue AS tpv ON tpv.TaxParameterValueId = ISNULL (
                                                                                                                        md.MapToId ,
                                                                                                                        '')
                                               LEFT JOIN dbo.PersonTaxParameter AS ptp ON  ptp.PersonTaxId = pt.PersonTaxId
                                                                                       AND ptp.TaxParameterId = tpv.TaxParameterId
                                        WHERE  ptp.PersonTaxParameterId IS NULL;

                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.persontaxparameter AS pr
                                   inner join  dbo.PersonTax AS pt on pt.persontaxid=pr.persontaxid
                            WHERE  pt.ReferenceNote = @ReferenceNote;
                         

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;


                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;



-----------=================================================
 -- 2020_W4


 SELECT @TableName = '2020_W4'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = '2020_W4'
                            FROM   dbo.Person AS p
                                   INNER JOIN #TempPerson AS tc ON CONVERT (VARCHAR (36), tc.EmployeeID) = p.ReferenceId
                            WHERE  p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;
                            INSERT INTO dbo.PersonTaxParameter ( PersonTaxId ,
                                                                 TaxParameterId ,
                                                                 Value ,
                                                                 UserPersonId )
                                        SELECT DISTINCT pt.PersonTaxId ,
                                                        tpm.TaxParameterId ,
                                                        CASE WHEN petr.EmployeeID IS NOT NULL THEN 'TRUE'
                                                             ELSE 'FALSE'
                                                        END ,
                                                        @UserPersonId
                                        FROM   dbo.Person AS p
                                               INNER JOIN dbo.PersonTax AS pt ON pt.PersonId = p.PersonId
                                               INNER JOIN #TempPerson AS tp ON  CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                               INNER JOIN #tempEmployeeTax AS petr ON  CONVERT (
                                                                                       VARCHAR (50), petr.EmployeeID) = pt.ReferenceId
                                                                               AND pt.ReferenceNote = @ReferenceNote
                                                                               AND tp.Migrationstatus = 'Migrate'
                                                                            
                                              
                                               INNER JOIN dbo.TransactionCode tc ON  tc.TransactionCodeId = pt.TransactionCodeId
                                                                                 AND tc.Description = 'Federal Income Tax'
                                               INNER JOIN dbo.TaxParameter tpm ON tpm.TransactionCodeId = tc.TransactionCodeId
                                               LEFT JOIN dbo.PersonTaxParameter AS ptp ON  ptp.PersonTaxId = pt.PersonTaxId
                                                                                       AND ptp.TaxParameterId = tpm.TaxParameterId
                                        WHERE  tpm.Parameter = '2020_W4'
                                        AND    ptp.PersonTaxParameterId IS NULL;

										    SELECT @NewCOunt = @OldCount;


                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;



--------------========================================================

 --15.OrganizationWCCode
                        

						 SELECT @TableName = 'OrganizationWCCode'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;

                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'OrganizationWCCode'
                            FROM   dbo.Organization AS tc
                                               INNER JOIN #TempCustomer AS tc2 ON  tc.ReferenceId = CONVERT (
                                                                                                        VARCHAR (50) ,
                                                                                                        tc2.CustomerID)
                                                                               AND tc.ReferenceNote = @ReferenceNote
                                                inner join [anuska_2024_new].dbo.job j on j.customerid=tc2.customerid   
                                               INNER JOIN dbo.MappingData AS md
                                                          INNER JOIN dbo.Mapping AS m ON  m.MappingId = md.MappingId
                                                                                      AND m.Mapping = 'WcCode'
                                                                                      AND m.MappingTypeId = @MappingTypeId ON md.Data1 = j.WcCode
                                               LEFT JOIN dbo.OrganizationWCCode AS owc ON  owc.OrganizationId = tc.OrganizationId
                                                                                       AND owc.WCCodeId = ISNULL (
                                                                                                              md.MapToId ,
                                                                                                              '')
                                        WHERE  owc.OrganizationWCCodeId IS NULL;

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            INSERT INTO dbo.OrganizationWCCode ( OrganizationId ,
                                                                 WCCodeId ,
                                                                 StatusListItemId ,
                                                                 UserPersonId ,
                                                                 InsertDate )
                                        SELECT DISTINCT tc.OrganizationId ,
                                                        md.MapToId ,
                                                         @ActiveStatusListItemId
                                                           ,
                                                        @UserPersonId ,
                                                       getdate()
                                        FROM   dbo.Organization AS tc
                                               INNER JOIN #TempCustomer AS tc2 ON  tc.ReferenceId = CONVERT (
                                                                                                        VARCHAR (50) ,
                                                                                                        tc2.CustomerID)
                                                                               AND tc.ReferenceNote = @ReferenceNote
                                                inner join [anuska_2024_new].dbo.job j on j.customerid=tc2.customerid   
                                               INNER JOIN dbo.MappingData AS md
                                                          INNER JOIN dbo.Mapping AS m ON  m.MappingId = md.MappingId
                                                                                      AND m.Mapping = 'WcCode'
                                                                                      AND m.MappingTypeId = @MappingTypeId ON md.Data1 = j.WcCode
                                               LEFT JOIN dbo.OrganizationWCCode AS owc ON  owc.OrganizationId = tc.OrganizationId
                                                                                       AND owc.WCCodeId = ISNULL (
                                                                                                              md.MapToId ,
                                                                                                              '')
                                        WHERE  owc.OrganizationWCCodeId IS NULL;


                            SELECT @NewCOunt = @OldCount;
                            --COUNT (*)
                            --                     FROM   dbo.Organization AS tc
                            --                            INNER JOIN #TempCustomer AS tc2 ON tc.ReferenceId = CONVERT (
                            --                                                                                    VARCHAR (50), tc2.CustomerGUID)
                            --                            INNER JOIN dbo.OrganizationWCCode AS owc ON owc.OrganizationId = tc.OrganizationId
                            --                     WHERE  tc.ReferenceNote = @ReferenceNote;



                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;


                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;

--------------==================================================================================

  --2.Customer    
                        
						SELECT @TableName = 'Customer'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;


                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'Customer'
                            FROM   #TempCustomer AS tc
                                   INNER JOIN dbo.Organization AS o ON  o.ReferenceId = CONVERT (
                                                                                            VARCHAR (50), tc.CustomerID)
                                                                    AND o.ReferenceNote = @ReferenceNote
                                   LEFT JOIN dbo.Customer AS c ON c.OrganizationId = o.OrganizationId
                            WHERE  c.OrganizationId IS NULL
                            AND    tc.Migrationstatus = 'Migrate'
                            AND    tc.CustomerType = 'Customer';


                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            INSERT INTO dbo.Customer ( OrganizationId ,
                                                       WorkflowStageId ,
                                                       StatusListItemId ,
                                                       UserPersonId ,
                                                       InsertDate )
                                        SELECT o.OrganizationId ,
                                               @CustomerWorkflowStageId ,
                                               @ActiveStatusListItemId ,
                                               @UserPersonId ,
                                               getdate()
                                        FROM   dbo.Organization AS o
                                               INNER JOIN #TempCustomer AS cr ON  CONVERT (VARCHAR (50), cr.CustomerID) = o.ReferenceId
                                                                              AND o.ReferenceNote = @ReferenceNote
                                               LEFT JOIN dbo.Customer AS c2 ON c2.OrganizationId = o.OrganizationId
                                        WHERE  c2.OrganizationId IS NULL
                                        AND    cr.Migrationstatus = 'Migrate'
                                        AND    cr.CustomerType = 'Customer';

                            

                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.Customer AS c
                                   INNER JOIN dbo.Organization AS o ON o.OrganizationId = c.OrganizationId
                                   INNER JOIN #TempCustomer AS tc ON  CONVERT (VARCHAR (50), tc.CustomerID) = o.ReferenceId
                                                                  AND tc.CustomerType = 'Customer'
                            WHERE  o.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;


                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;


--------------------=============================================================
 --6.Employee
                        

						SELECT @TableName = 'Employee'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;


                            SELECT @OldCount = COUNT (*) ,
                                   @TableName = 'Employee'
                            FROM   dbo.Person p
                                   INNER JOIN #TempPerson AS tp ON CONVERT (VARCHAR (50), tp.EmployeeID) = p.ReferenceId
                            WHERE  p.ReferenceNote = @ReferenceNote
                            AND    tp.EmployeeType = 'Employee';

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)


                            INSERT INTO dbo.Employee ( PersonId ,
                                                       WorkflowStageId ,
                                                       StatusListItemId ,
                                                       DIPercent ,
                                                       EmployeeTypeListItemId ,
                                                       CheckDeliveryListItemId ,
                                                       UserPersonId ,
                                                       InsertDate )

                                        SELECT p.PersonId ,
                                               @EmployeeWorkflowStageId ,
                                                @ActiveStatusListItemId ,
                                               0 ,
                                               @EmployeeEmployeeTypeListItemId ,
                                               @HoldAtEmployeeOfficeCheckDeliveryListItemId,
                                               @UserPersonId ,
                                               getdate()
                                        FROM   dbo.Person AS p
                                               INNER JOIN #TempPerson AS er ON  CONVERT (VARCHAR (50), er.EmployeeID) = p.ReferenceId
                                                                            AND p.ReferenceNote = @ReferenceNote
                                             
                                               LEFT JOIN dbo.Employee AS e ON e.PersonId = p.PersonId
                                        WHERE  e.PersonId IS NULL
                                        AND    er.EmployeeType = 'Employee';


                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.Person AS p
                                   INNER JOIN dbo.Employee AS e ON e.PersonId = p.PersonId
                                   INNER JOIN #TempPerson AS tp ON  p.ReferenceId = CONVERT (VARCHAR (50), tp.EmployeeID)
                                                                AND p.ReferenceNote = @ReferenceNote;

                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,          -- int
                                                       @TableName = @TableName ,        -- varchar(50)
                                                       @ReferenceNote = @ReferenceNote; -- varchar(100)

                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                 end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;

-------============================================================================================================

--3.organization node

                        

						SELECT @TableName = 'OrganizationNode'
IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM dbo.MigrationLog as ml
    where ml.ReferenceNote = @ReferenceNote
          and ml.TableName = @TableName
)
begin
    BEGIN TRY
        begin transaction;
                            SELECT @OldCount =count(*),
                                   @TableName = 'OrganizationNode'  --select *
                            FROM  [Anuska_2024_new].dbo.CustomerData AS cr
                                               INNER JOIN #TempCustomer AS tc ON cr.CustomerID = tc.CustomerID
                                               INNER JOIN dbo.Organization ooa ON  ooa.ReferenceId = CONVERT (
                                                                                                         VARCHAR (36) ,
                                                                                                         tc.CustomerID)
                                                                               AND ooa.ReferenceNote = 'testmigration_anuska'
                                               LEFT JOIN dbo.OrganizationNode Onn ON  Onn.OrganizationId = ooa.OrganizationId

                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;

                            INSERT INTO dbo.OrganizationNode ( OrganizationId ,
                                                               NodeId ,
                                                               UserPersonId ,
                                                               InsertDate )
                                        SELECT DISTINCT ooa.OrganizationId ,
                                                       200001 ,
                                                        @UserPersonId ,
                                                        ooa.InsertDate
                                        FROM   [Anuska_2024_new].dbo.CustomerData AS cr
                                               INNER JOIN #TempCustomer AS tc ON cr.CustomerID = tc.CustomerID
                                               INNER JOIN dbo.Organization ooa ON  ooa.ReferenceId = CONVERT (
                                                                                                         VARCHAR (36) ,
                                                                                                         tc.CustomerID)
                                                                               AND ooa.ReferenceNote = @ReferenceNote
                                               LEFT JOIN dbo.OrganizationNode Onn ON  Onn.OrganizationId = ooa.OrganizationId
                                                                                  
                                        WHERE  Onn.OrganizationNodeId IS NULL;

                            SELECT @NewCOunt = COUNT (*)
                            FROM   dbo.Organization AS o
                                   INNER JOIN #TempCustomer AS tc ON CONVERT (VARCHAR (50), tc.CustomerID) = o.ReferenceId
                                   INNER JOIN dbo.OrganizationNode AS ono ON ono.OrganizationId = o.OrganizationId
                            WHERE  o.ReferenceNote = @ReferenceNote;


                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
                                                       @TableName = @TableName ,
                                                       @ReferenceNote = @ReferenceNote;


                            SET @ErrorMessage = CONCAT (
                                                    'Old Count : ' ,
                                                    @OldCount ,
                                                    ' New Count : ' ,
                                                    @NewCOunt ,
                                                    ' For Table : ' ,
                                                    @TableName);
                            IF ( @OldCount <> @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
                                END;



                            ELSE IF ( @OldCount = @NewCOunt )
                                BEGIN
                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
                                end;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
	end;


----------------------==================================================================================
 --5.payment  

--                        SELECT @TableName = 'Payment'
--IF NOT EXISTS
--(
--    SELECT TOP 1
--        1
--    FROM dbo.MigrationLog as ml
--    where ml.ReferenceNote = @ReferenceNote
--          and ml.TableName = @TableName
--)
--begin
--    BEGIN TRY
--        begin transaction;

--                            SELECT @OldCount = COUNT (*) ,
--                                   @TableName = 'Payment'
--                            FROM   dbo.Organization AS p
--                                   INNER JOIN dbo.Agency aa ON aa.OrganizationId = p.OrganizationId
--                                   INNER JOIN [A-France-0124].[Davis_Avionte].dbo.PaymentCheck AS pc ON  p.ReferenceId = CONVERT (
--                                                                                                                             VARCHAR (50) ,
--                                                                                                                             pc.PayeeGUID)
--                                                                                                     AND p.ReferenceNote = @ReferenceNote
--                                                                                                                           + '-Agency'
--                                   INNER JOIN #tempAgencyPayment AS tpb ON tpb.PaymentCheckGUID = pc.PaymentCheckGUID
--                                   LEFT JOIN dbo.Payment AS p2 ON  p2.ReferenceId = CONVERT (
--                                                                                        VARCHAR (50), pc.PaymentCheckGUID)
--                                                               AND p2.ReferenceNote = @ReferenceNote + '-Agency'
--                            WHERE  p2.PaymentId IS NULL
--                            AND    tpb.MigrationStatus = 'Migrate';


--                            SELECT @RegularCheckStatusListItemId = dbo.SfListItemIdGet ('CheckStatus', 'Regular');



--                            EXEC dbo.SpMigrationLogIns @OldCount = @OldCount ,
--                                                       @TableName = @TableName ,
--                                                       @ReferenceNote = @ReferenceNote;

--                            INSERT INTO dbo.Payment ( CheckNumber ,
--                                                      PersonId ,
--                                                      OrganizationId ,
--                                                      OfficeId ,
--                                                      BackOfficeId ,
--                                                      PaymentBatchId ,
--                                                      Tax ,
--                                                      Benefit ,
--                                                      PaymentGross ,
--                                                      TransactionGross ,
--                                                      PaymentDeduction ,
--                                                      TransactionDeduction ,
--                                                      PaymentReimbursement ,
--                                                      TransactionReimbursement ,
--                                                      Net ,
--                                                      IsW2 ,
--                                                      MTDGross ,
--                                                      QTDGross ,
--                                                      YTDGross ,
--                                                      IsLiveCheck ,
--                                                      CheckStatusListItemId ,
--                                                      EmployeeTypeListItemId ,
--                                                      UserPersonId ,
--                                                      InsertDate ,
--                                                      ReferenceId ,
--                                                      ReferenceNote ,
--                                                      CorrectionPaymentId ,
--                                                      ClearDate )
--                                        SELECT pc.CheckNumber ,
--                                               NULL AS PersonId ,
--                                               p.OrganizationId ,
--                                               o.OfficeId ,
--                                               ISNULL (o.BackOfficeId, o.OfficeId) ,
--                                               pb2.PaymentBatchId ,
--                                               pc.TotalTaxes ,
--                                               pc.TotalBenefits AS Benefits ,
--                                               0 AS PaymentGross ,
--                                               pc.AgencyPayAmount AS TransactionGross ,
--                                               pc.TotalDeductions AS PaymentDeduction ,
--                                               0 ,
--                                               0 ,
--                                               0 ,
--                                               pc.NetAmount ,
--                                               pc.IsW2 ,
--                                               0 ,
--                                               0 ,
--                                               pc.YTDGross ,
--                                               CASE WHEN pc.IsDirectDeposit = 0 THEN 1
--                                                    ELSE 0
--                                               END ,
--                                               ISNULL (cmd.MapToId, @RegularCheckStatusListItemId) AS CheckStatusListItemId ,
--                                               @ContractorEmployeeTypeListItemId AS EmployeeTypeListItemId ,
--                                               @UserPersonId ,
--                                               pb2.InsertDate ,
--                                               CONVERT (VARCHAR (50), pc.PaymentCheckGUID) ,
--                                               @ReferenceNote + '-Agency' ,
--                                               NULL ,
--                                               pc.DateCleared
--                                        FROM   dbo.Organization AS p
--                                               INNER JOIN dbo.Agency aa ON aa.OrganizationId = p.OrganizationId
--                                               INNER JOIN [A-France-0124].[Davis_Avionte].dbo.PaymentCheck AS pc ON  p.ReferenceId = CONVERT (
--                                                                                                                                         VARCHAR (50) ,
--                                                                                                                                         pc.PayeeGUID)
--                                                                                                                 AND p.ReferenceNote = @ReferenceNote
--                                                                                                                                       + '-Agency'
--                                               INNER JOIN #tempAgencyPayment AS tpb ON tpb.PaymentCheckGUID = pc.PaymentCheckGUID
--                                               LEFT JOIN dbo.MappingData AS md
--                                                         INNER JOIN dbo.Mapping AS m ON  m.MappingId = md.MappingId
--                                                                                     AND m.Mapping = 'Office'
--                                                                                     AND m.MappingTypeId = @MappingTypeId ON  md.Data1 = CONVERT (
--                                                                                                                                             VARCHAR (50) ,
--                                                                                                                                             pc.StaffingSupplierSiteGUID)
--                                                                                                                          AND ISNULL (
--                                                                                                                                  md.MapTo ,
--                                                                                                                                  '') <> 'DoNotMigrate'
--                                               INNER JOIN dbo.Office AS o ON o.OfficeId = ISNULL (md.MapToId, p.OfficeId)
--                                               LEFT JOIN dbo.MappingData AS cmd
--                                                         INNER JOIN dbo.Mapping AS cm ON  cm.MappingId = cmd.MappingId
--                                                                                      AND cm.Mapping = 'Payment_CheckStatus'
--                                                                                      AND cm.MappingTypeId = @MappingTypeId ON  cmd.Data1 = CONVERT (
--                                                                                                                                                VARCHAR (255) ,
--                                                                                                                                                pc.CheckStatusConfigSystemChoiceID)
--                                                                                                                            AND ISNULL (
--                                                                                                                                    cmd.MapTo ,
--                                                                                                                                    '') <> 'DoNotMigrate'
--                                               INNER JOIN dbo.PaymentBatch AS pb2 ON  CONVERT (
--                                                                                          VARCHAR (50) ,
--                                                                                          pc.PaymentBatchGUID) = pb2.ReferenceId
--                                                                                  AND pb2.ReferenceNote = @ReferenceNote
--                                                                                                          + '-Agency'
--                                               LEFT JOIN dbo.Payment AS p2 ON  p2.ReferenceId = CONVERT (
--                                                                                                    VARCHAR (50) ,
--                                                                                                    pc.PaymentCheckGUID)
--                                                                           AND p2.ReferenceNote = @ReferenceNote
--                                                                                                  + '-Agency'
--                                        WHERE  p2.PaymentId IS NULL
--                                        AND    tpb.MigrationStatus = 'Migrate';


--										 SELECT @NewCOunt = COUNT (*)
--                            FROM   dbo.Organization AS o
--                                   INNER JOIN #TempCustomer AS tc ON CONVERT (VARCHAR (50), tc.CustomerGUID) = o.ReferenceId
--                                   INNER JOIN dbo.OrganizationNode AS ono ON ono.OrganizationId = o.OrganizationId
--                            WHERE  o.ReferenceNote = @ReferenceNote;


--                            EXEC dbo.SpMigrationLogUpd @NewCount = @NewCOunt ,
--                                                       @TableName = @TableName ,
--                                                       @ReferenceNote = @ReferenceNote;


--                            SET @ErrorMessage = CONCAT (
--                                                    'Old Count : ' ,
--                                                    @OldCount ,
--                                                    ' New Count : ' ,
--                                                    @NewCOunt ,
--                                                    ' For Table : ' ,
--                                                    @TableName);
--                            IF ( @OldCount <> @NewCOunt )
--                                BEGIN
--                                    RAISERROR ('Data Insertion Failed ,%s', 16, 1, @ErrorMessage);
--                                END;



--                            ELSE IF ( @OldCount = @NewCOunt )
--                                BEGIN
--                                    RAISERROR ('Data Insertion Successful ,%s', 0, 1, @ErrorMessage);
-- end;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH;
--	end;


	/*

EXEC [dbo].[SpAnuska_2024_newToZenopleMigrationTsk]
*/

/*

 --EXEC dbo.SpPersonCatalogIns @Json = N'{"personIdList":"0"}';
select * from INFORMATION_SCHEMA.COLUMNS 
where COLUMN_NAME like '%ContactInformationId%'

select * 
from migrationlog as ml where ReferenceNote like'%testmigration_anuska%' order by insertdate desc

delete from migrationlog 
where MigrationLogId=1683 

where personid=1000340957
delete from personbankaccount
where personbankaccountid between 39824 and 39843

select *from personcurrent  order by insertdate desc
*/



--DECLARE @p NVARCHAR (MAX);
--SET @p = N'{"personid":2}';
--EXEC dbo.SpSessionContextTsk @Json = @p;
--EXEC dbo.SpZenopleMigrationDataFixTsk @referenceNote =
--N'TestMigration_Anuska' 
--,@relatesToPerson=1  -- bit --done

--select * from person p where p.ReferenceNote = 'TestMigration_Anuska'

--select *from persontaxparameter order by insertdate desc