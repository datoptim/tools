--	-------------------------------------------------------
--	sp_ReportUserDbTables
--	www.datoptim.com (c)
--	Boletin de noticias [es]: http://eepurl.com/giwb6L
--	Contactos y preguntas: pablof@datoptim.com
--	-------------------------------------------------------



CREATE PROCEDURE [dbo].[sp_ReportUserDbTables]
AS
BEGIN 

	WITH rep AS(
	SELECT
		[SchemaName] = s.Name, 
		[ObjectName] = t.NAME,
		t.create_date AS [CreateDate], 
		t.modify_date AS [ModifyDate],
		p.rows AS RowCounts,
		SUM(a.total_pages) * 8 AS TotalSpaceKB, 
		SUM(a.used_pages) * 8 AS UsedSpaceKB, 
		(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
	FROM 
		sys.tables t
	INNER JOIN      
		sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
		sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN 
		sys.schemas s ON t.schema_id = s.schema_id
	WHERE 
		t.is_ms_shipped = 0
		AND i.OBJECT_ID > 255 
	GROUP BY 
		s.Name, t.NAME, t.create_date, t.modify_date, p.Rows
	)

	SELECT 	[REPORT] = 'DATABASE TABLES',
		[ServerName] = @@SERVERNAME,
		[DatabaseName] = DB_NAME(),
		*
	FROM rep
END
