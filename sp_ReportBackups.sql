--	-------------------------------------------------------
--	sp_ReportBackups
--	https://datoptim.com/genera-reporte-de-backups-en-sql-server/
--	www.datoptim.com (c)
--	Boletin de noticias [es]: http://eepurl.com/giwb6L
--	Contactos y preguntas: pablof@datoptim.com
--	-------------------------------------------------------


CREATE OR ALTER PROC sp_ReportBackups
	@Days smallint = 0,
	@OrderBy nvarchar(10) = NULL

AS
BEGIN

	DECLARE 
		@Query nvarchar(max) = NULL,
		@LineFeed NVARCHAR(10)
	

	SELECT @LineFeed = CHAR(13) + CHAR(10)


		SET @Query = N'
		SELECT 
			''BACKUPS'' AS [REPORT],
			@@SERVERNAME AS [ServerName],
			[bs].[database_name] AS [DatabaseName],
			[bs].[backup_start_date] AS [BkpStartDate],
			[bs].[backup_finish_date] AS [BkpFinishDate],
			[bs].[expiration_date] AS [BkpExpirationDate],
			CASE [bs].[type]
				WHEN ''D'' THEN ''Full''
				WHEN ''I'' THEN ''Differential''
				WHEN ''L'' THEN ''Log''
				WHEN ''F'' THEN ''File/Filegroup''
				WHEN ''G'' THEN ''Differential File''
				WHEN ''P'' THEN ''Partial''
				WHEN ''Q'' THEN ''Differential Partial''
			END AS [BkpType],
			[bs].[backup_size] AS [BkpSize],
			[bmf].[logical_device_name] AS [LogicalDevName],
			[bmf].[physical_device_name] AS [PhysicalDevName],
			[bs].[name] AS [BackupsetName],
			[bs].[description] AS [Description]
		FROM msdb.dbo.backupmediafamily AS [bmf]
		INNER JOIN msdb.dbo.backupset AS [bs]
			ON [bmf].[media_set_id] = [bs].[media_set_id]
		'

	IF(@Days != 0)
		SET @Query = @Query + @LineFeed + N'WHERE (CONVERT(datetime, [bs].[backup_start_date], 102) >= GETDATE() - ' + CONVERT(nvarchar(5), @Days) + ')' + @LineFeed


	SET @Query = CASE @OrderBy
		WHEN 'size' THEN @Query + @LineFeed + N'ORDER BY [bs].[backup_size] DESC'
		WHEN 'dbname' THEN @Query + @LineFeed + N'ORDER BY [bs].[database_name]'
		WHEN 'date' THEN @Query + @LineFeed + N'ORDER BY [bs].[backup_start_date] DESC'
		ELSE @Query + @LineFeed + N'ORDER BY [bs].[database_name], [bs].[backup_finish_date]'
	END

	EXEC(@Query)

END
