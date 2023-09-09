SELECT
    Content.query('/Invoice/Company/text()') As Company,
    Content.query('/Invoice/ID/text()') As ID
FROM (
    SELECT 
        CAST(CAST([ATF_Value] AS varbinary(MAX)) AS XML) AS Content
    FROM 
        [BPS_Content_Att].[dbo].[WFAttachmentFiles]
    WHERE
        ATF_WFDID = {WFD_ID}
) As Result(Content)

SELECT
    Content.query('/Invoice/Positions/Position/Name/text()') As Company,
    Content.query('/Invoice/Positions/Position//text()') As ID
FROM (
    SELECT 
        CAST(CAST([ATF_Value] AS varbinary(MAX)) AS XML) AS Content
    FROM 
        [BPS_Content_Att].[dbo].[WFAttachmentFiles]
    WHERE
        ATF_WFDID = {WFD_ID}
) As Result(Content)


SELECT
    Company.value('(Company/text())[1]', 'VARCHAR(MAX)') AS Company,
    Company.value('(ID/text())[1]', 'VARCHAR(MAX)') AS ID,
    Position.value('(Name/text())[1]', 'VARCHAR(MAX)') AS PositionName,
    Position.value('(Quantity/text())[1]', 'INT') AS Quantity,
    Position.value('(Price/text())[1]', 'DECIMAL(10, 2)') AS Price
FROM (
    SELECT
        CAST(CAST([ATF_Value] AS VARBINARY(MAX)) AS XML) AS Content
    FROM 
        [BPS_Content_Att].[dbo].[WFAttachmentFiles]
    WHERE
        ATF_WFDID = {WFD_ID}
) AS Result(Content)
CROSS APPLY Content.nodes('/Invoice') AS T(Company)
CROSS APPLY Company.nodes('Positions/Position') AS P(Position);


SELECT
    Position.value('(Name/text())[1]', 'VARCHAR(MAX)') AS PositionName,
    Position.value('(Quantity/text())[1]', 'INT') AS Quantity,
    Position.value('(Price/text())[1]', 'DECIMAL(10, 2)') AS Price
FROM (
    SELECT
        CAST(CAST([ATF_Value] AS VARBINARY(MAX)) AS XML) AS Content
    FROM 
        [BPS_Content_Att].[dbo].[WFAttachmentFiles]
    WHERE
        ATF_WFDID = {WFD_ID}
) AS Result(Content)
CROSS APPLY Content.nodes('/Invoice/Positions/Position') AS P(Position);



SELECT
    -- Query executes XQuery on the Content, which in this case will be our XML
    Content.query('/Invoice/Company/text()') As Company,
    Content.query('/Invoice/ID/text()') As ID
FROM (
    SELECT 
        --Here we first cast Image to varbinary - it's needed because direct cast from Image to XML is not possible.
        --After it's just varbinary, we are able to cast it directly to XML, it's not really encoded/encrypted.
        CAST(CAST([ATF_Value] AS varbinary(MAX)) AS XML) AS Content
    FROM 
        [BPS_Content_Att].[dbo].[WFAttachmentFiles]
    WHERE
        ATF_WFDID = {WFD_ID}
) As Result(Content) -- Regular named output column



SELECT
    Position.value('(Name/text())[1]', 'VARCHAR(MAX)') AS PositionName,
    Position.value('(Quantity/text())[1]', 'INT') AS Quantity,
    Position.value('(Price/text())[1]', 'DECIMAL(10, 2)') AS Price
FROM (
    SELECT
        --Here we first cast Image to varbinary - it's needed because direct cast from Image to XML is not possible.
        --After it's just varbinary, we are able to cast it directly to XML, it's not really encoded/encrypted.
        CAST(CAST([ATF_Value] AS VARBINARY(MAX)) AS XML) AS Content
    FROM 
        [BPS_Content_Att].[dbo].[WFAttachmentFiles]
    WHERE
        ATF_WFDID = {WFD_ID}
) AS Result(Content)
CROSS APPLY Content.nodes('/Invoice/Positions/Position') AS P(Position);
-- This is a little bit tricky to explain, but i'll try.
-- Our SELECT returns 1 row with the XML content, and we wan't to have more rows than one
-- Content.nodes returns multiple rows, but we have to join them, that's where CROSS APPLY comes in.
-- You could also look up at this SO question -> https://stackoverflow.com/questions/23498284/why-is-cross-apply-needed-when-using-xpath-queries



-- This way is easier to understand, but WEBCON doesn't like DECLARE statements, so i prefer CROSS APPLY.
DECLARE @Content AS XML = (
    SELECT
        CAST(CAST([ATF_Value] AS VARBINARY(MAX)) AS XML) AS Content
    FROM 
        [BPS_Content_Att].[dbo].[WFAttachmentFiles]
    WHERE
        ATF_WFDID = {WFD_ID}
)

SELECT
    Position.value('(Name/text())[1]', 'VARCHAR(MAX)') AS PositionName,
    Position.value('(Quantity/text())[1]', 'INT') AS Quantity,
    Position.value('(Price/text())[1]', 'DECIMAL(10, 2)') AS Price
FROM @Content.nodes('/Invoice/Positions/Position') AS P(Position);