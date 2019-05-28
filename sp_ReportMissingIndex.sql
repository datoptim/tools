--	-------------------------------------------------------
--	sp_ReportMissingIndex
--	www.datoptim.com (c)
--	Boletin de noticias [es]: http://eepurl.com/giwb6L
--	Contactos y preguntas: pablof@datoptim.com
--	-------------------------------------------------------


CREATE PROCEDURE sp_ReportMissingIndex
AS
BEGIN
	SELECT 
		'MISSING INDEXES' AS [REPORT],
		@@SERVERNAME AS [ServerName],
		[dbs].name AS [DatabaseName],
		[sch].name AS [SchemaName],
		[obj].name AS [ObjectName],
		[ddmid].statement AS [FullName],
		[CostSavings] = ROUND(
					[ddmigs].[avg_total_user_cost] * 
					[ddmigs].[avg_user_impact] * 
					([ddmigs].[user_seeks] + [ddmigs].[user_scans]
					), 0) / 100 ,
		[ddmigs].[avg_total_user_cost] AS [AVG_TOTAL_USER_COST],
		[ddmigs].[avg_user_impact] AS [AVG_USER_IMPACT],
		[ddmid].[equality_columns] AS [Equality],
		[ddmid].[inequality_columns] AS [Inequality],
		[ddmid].[included_columns] AS [Included],
		[ddmigs].[user_seeks] AS [UserSeeks],
		[ddmigs].[last_user_seek] AS [LastUserSeek],
		[ddmigs].[user_scans] AS [UserScans],
		[ddmigs].[last_user_scan] AS [LastUserScan]
	FROM [sys].[dm_db_missing_index_groups] AS [ddmig]
	INNER JOIN [sys].[dm_db_missing_index_group_stats] AS [ddmigs]
		ON [ddmig].[index_group_handle] = [ddmigs].[group_handle]
	INNER JOIN [sys].[dm_db_missing_index_details] AS [ddmid]
		ON [ddmid].[index_handle] = [ddmig].[index_handle]
	INNER JOIN [sys].[objects] AS [obj]
		ON [obj].object_id = [ddmid].object_id
	INNER JOIN [sys].[schemas] AS [sch] 
		ON [sch].schema_id = [obj].schema_id
	INNER JOIN [sys].[databases] [dbs]
		ON [dbs].database_id = [ddmid].database_id
	ORDER BY [CostSavings] DESC

END
