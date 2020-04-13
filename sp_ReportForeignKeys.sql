--	-------------------------------------------------------
--	sp_ReportForeignKeys
--	https://datoptim.com/relaciones-entre-tablas-de-sql-server/
--	www.datoptim.com (c)
--	Boletin de noticias [es]: http://eepurl.com/giwb6L
--	Contactos y preguntas: pablof@datoptim.com
--	-------------------------------------------------------

CREATE OR ALTER PROC sp_ReportForeignKeys
AS
BEGIN

	SELECT
		'FOREIGNKEYS' AS [REPORT],
		@@SERVERNAME AS [ServerName],
		DB_NAME() AS [DatabaseName],
		[fk].[name] AS [ForeignKeyName],
		SCHEMA_NAME([fk].schema_id) AS [TableSchema],
		OBJECT_NAME([fk].[parent_object_id]) AS [Table],
		COL_NAME([fkc].[parent_object_id], [fkc].[parent_column_id]) AS [ConstraintColumn],
		[fk].[is_disabled] AS [IsDisabled],
		OBJECT_SCHEMA_NAME ([fk].[referenced_object_id]) AS [ReferencedTableSchema],
		OBJECT_NAME ([fk].[referenced_object_id]) AS [ReferencedTable],
		COL_NAME([fkc].[referenced_object_id], [fkc].[referenced_column_id]) AS [ReferencedColumn],
		[fk].[delete_referential_action_desc] AS [DeleteAction],
		[fk].[update_referential_action_desc] AS [UpdateAction],
		[fk].[create_date] AS [CreateDate],
		[fk].[modify_date] AS [ModifyDate],
		CASE [fk].[is_system_named]
			WHEN 1 THEN 'System' 
			WHEN 0 THEN 'User'
		END AS [Named]
	FROM [sys].[foreign_keys] AS [fk]
	INNER JOIN [sys].[foreign_key_columns] AS [fkc]
	   ON [fk].[object_id] = [fkc].[constraint_object_id]
	ORDER BY 
		SCHEMA_NAME([fk].[schema_id]),
		OBJECT_NAME([fk].[parent_object_id]) 

END
