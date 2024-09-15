--idea no1
SELECT pci.PersonId,
       ci.ContactInformationId,
       ci.Value,
    ROW_NUMBER() OVER (PARTITION BY pci.PersonId, ci.Value ORDER BY pci.PersonId) AS RowNum
INTO   #tempduplicatecontact  -- SELECT pci.PersonId,ci.Value
FROM   dbo.PersonContactInformation AS pci
       INNER JOIN dbo.ContactInformation AS ci ON ci.ContactInformationId = pci.ContactInformationId
       INNER JOIN dbo.Person AS P ON P.PersonId = pci.PersonId
       INNER JOIN ListItem li ON li.ListItemId = ci.ContactInformationTypeListItemId
       INNER JOIN dbo.ListItemCategory AS lic ON lic.ListItemCategoryId = li.ListItemCategoryId
       INNER JOIN dbo.ListItemCategoryProperty AS licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
       INNER JOIN dbo.ListItemProperty AS lip ON  lip.ListItemCategoryPropertyId = licp.ListItemCategoryPropertyId
                                              AND lip.ListItemId = li.ListItemId
WHERE  li.ListItem LIKE '%%'
AND    licp.Property LIKE '%Group%'
AND    lip.Value = 'Phone'
AND    lic.Category LIKE '%contactinformation%'

DELETE  pci -- select *
FROM dbo.PersonContactInformation AS pci
INNER JOIN #tempduplicatecontact AS t ON pci.ContactInformationId = t.ContactInformationId
where t.rownum>1

 DROP TABLE #tempduplicatecontact

SELECT * FROM #tempduplicatecontact AS t
 
 
  DELETE FROM td
FROM #tempduplicatecontact AS td
INNER JOIN (
    SELECT pci.PersonId,
           ci.Value
    FROM dbo.PersonContactInformation AS pci
    INNER JOIN dbo.ContactInformation AS ci ON ci.ContactInformationId = pci.ContactInformationId
    INNER JOIN dbo.Person AS P ON P.PersonId = pci.PersonId
    INNER JOIN ListItem li ON li.ListItemId = ci.ContactInformationTypeListItemId
    INNER JOIN dbo.ListItemCategory AS lic ON lic.ListItemCategoryId = li.ListItemCategoryId
    INNER JOIN dbo.ListItemCategoryProperty AS licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
    INNER JOIN dbo.ListItemProperty AS lip ON lip.ListItemCategoryPropertyId = licp.ListItemCategoryPropertyId AND lip.ListItemId = li.ListItemId
    WHERE li.ListItem LIKE '%%'
      AND licp.Property LIKE '%Group%'
      AND lip.Value = 'Phone'
      AND lic.Category LIKE '%contactinformation%'
    GROUP BY pci.PersonId, ci.Value
    HAVING COUNT(*) > 1
) AS dv ON td.PersonId = dv.PersonId
---------------------------------------------------------
--idea no2
DELETE  pci 
FROM dbo.PersonContactInformation AS pci
INNER JOIN #tempduplicatecontact AS t ON pci.PersonId = t.PersonId
AND pci.ContactInformationId=t.contactinformationid



SELECT pci.PersonId,
       ci.ContactInformationId,
       ci.Value,
    ROW_NUMBER() OVER (PARTITION BY pci.PersonId, ci.Value ORDER BY pci.PersonId) AS RowNum

FROM   dbo.PersonContactInformation AS pci
       INNER JOIN dbo.ContactInformation AS ci ON ci.ContactInformationId = pci.ContactInformationId
       INNER JOIN dbo.Person AS P ON P.PersonId = pci.PersonId
       INNER JOIN ListItem li ON li.ListItemId = ci.ContactInformationTypeListItemId
       INNER JOIN dbo.ListItemCategory AS lic ON lic.ListItemCategoryId = li.ListItemCategoryId
       INNER JOIN dbo.ListItemCategoryProperty AS licp ON licp.ListItemCategoryId = lic.ListItemCategoryId
       INNER JOIN dbo.ListItemProperty AS lip ON  lip.ListItemCategoryPropertyId = licp.ListItemCategoryPropertyId
                                              AND lip.ListItemId = li.ListItemId
WHERE  li.ListItem LIKE '%%'
AND    licp.Property LIKE '%Group%'
AND    lip.Value = 'Phone'
AND    lic.Category LIKE '%contactinformation%'