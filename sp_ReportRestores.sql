--	-------------------------------------------------------
--	sp_ReportRestores
--	https://datoptim.com/genera-reporte-de-restores-en-sql-server/
--	www.datoptim.com (c)
--	Boletin de noticias [es]: http://eepurl.com/giwb6L
--	Contactos y preguntas: pablof@datoptim.com
--	-------------------------------------------------------





CREATE OR ALTER PROC sp_ReportRestores
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
			''RESTORES'' AS [REPORT],
			@@SERVERNAME AS [ServerName],
			[bs].[database_name] AS [SourceDatabaseName], 
			[bmf].[physical_device_name] AS [SourceFileForRestore],
			[bs].[backup_start_date] AS [BkpStartDate], 
			[bs].[backup_finish_date] AS [BkpFinishDate],
			[rh].[destination_database_name] AS [DestinationDatabaseName],
			[rh].[restore_date] AS [RestoreDate]
			FROM msdb..restorehistory AS [rh]
			INNER JOIN msdb..backupset AS [bs]
				ON [rh].[backup_set_id] = [bs].[backup_set_id]
			INNER JOIN msdb..backupmediafamily AS [bmf] 
				ON [bs].[media_set_id] = [bmf].[media_set_id] 
		'

	IF(@Days != 0)
		SET @Query = @Query + @LineFeed + N'WHERE (CONVERT(datetime, [rh].[restore_date], 102) >= GETDATE() - ' + CONVERT(nvarchar(5), @Days) + ')' + @LineFeed


	SET @Query = CASE @OrderBy
		WHEN 'dbname' THEN @Query + @LineFeed + N'ORDER BY [bs].[destination_database_name]'
		WHEN 'date' THEN @Query + @LineFeed + N'ORDER BY [rh].[restore_date] DESC'
		ELSE @Query + @LineFeed + N'ORDER BY [bs].[database_name], [bs].[backup_finish_date]'
	END

	EXEC(@Query)

END
