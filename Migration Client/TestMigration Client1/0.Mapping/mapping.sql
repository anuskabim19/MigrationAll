

select *from Mapping m
inner join MappingType mt on mt.MappingTypeId=m.MappingTypeId
where mt.MappingType= 'TestMigration_Anuska' 
and Mapping= 'Employee_EEOMaritalStatus'

 select *from MappingData md
 inner join Mapping m on m.MappingId=md.MappingId
 inner join MappingType mt on mt.MappingTypeId=m.MappingTypeId
 where mt.MappingType= 'TestMigration_Anuska' 
and Mapping= 'Employee_EEOMaritalStatus'

EXEC dbo.SpMigrationMappingIns @MappingType = 'TestMigration_Anuska';

exec sp_helptext SpMigrationMappingIns

select *from mapping order by 1 desc

declare @MappingName nvarchar(max);
declare @MappingId nvarchar(max);
declare @MappingTypeId nvarchar(max);

SELECT @MappingName = 'Employee_AddressType';
                SELECT @MappingId = ( SELECT MappingId
                                      FROM   dbo.Mapping
                                      WHERE  Mapping = 'Employee_AddressType'
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
                                     LTRIM (RTRIM (ed.FullAddress)) AS Mapfrom ,
                                     LTRIM (RTRIM (ed.FullAddress)) AS Data1 ,
                                     COUNT (*) AS Data2 ,
                                     3 AS UserPersonId ,
                                     GETDATE () AS InsertDate,
									 MAX ( LEFT('EmployeeID: ' + CONVERT (VARCHAR (255), ed.EmployeeID)
                                              + ' Employee Name: ' + ISNULL (ed.Name, '') , 255)) AS Example
									
                                 FROM
    [Anuska_2024_new].dbo.EmployeeData ed    
                            WHERE   
                                  ed.MigrationStatus = 'Migrate'
                            GROUP BY ed.FullAddress ,
                                      LTRIM (RTRIM (ed.FullAddress))
                            ORDER BY  LTRIM (RTRIM (ed.FullAddress));

							drop table #ExampleEmployeeData
							drop table #Mappingdata

