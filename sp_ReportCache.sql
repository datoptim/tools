--	-------------------------------------------------------
--	sp_ReportCache
--	https://datoptim.com/reportcache/
--	www.datoptim.com (c)
--	Boletin de noticias [es]: http://eepurl.com/giwb6L
--	Contactos y preguntas: pablof@datoptim.com
--	-------------------------------------------------------


CREATE OR ALTER PROC sp_ReportCache 
	@Advanced int = 0,
	@Text nvarchar(30) = NULL,
	@OrderBy nvarchar(30) = NULL

AS
BEGIN

DECLARE 
	@Query nvarchar(max) = NULL,
	@LineFeed NVARCHAR(10)

SELECT @LineFeed = CHAR(13) + CHAR(10)



IF(@Advanced = 0)
BEGIN
	SET @Query = N'
	SELECT
		[deqs].[plan_handle] AS [PlanHandle], ​
		[deqs].[execution_count] AS [ExecCount],​
		[dest].[text] AS [Text], ​
		SUBSTRING(​
			[dest].text, ​
			([deqs].statement_start_offset / 2) + 1,​
			((CASE [deqs].statement_end_offset​
				WHEN -1 then DATALENGTH([dest].text)​
				ELSE [deqs].statement_end_offset​
			END - [deqs].statement_start_offset) / 2) + 1) AS [QueryText], ​
		[deqp].[query_plan] AS [QueryPlan], ​
		[deqs].[creation_time] AS [PlanCreatedAt], ​
		[deqs].[last_execution_time] AS [LastExecutedAt], ​
		[deqs].last_logical_reads, ​
		[deqs].total_elapsed_time, ​
		[deqs].last_elapsed_time, ​
		[deqs].[last_dop] AS [LastDoP],​
		[deqs].[last_rows] AS [Last#Rows],​
		[deqs].[total_grant_kb] AS [TotalGrant],​
		[deqs].[last_used_grant_kb] AS [LastUsedGrant],​
		[deqs].[last_ideal_grant_kb] AS [LastIdealGrant],​
		[deqs].sql_handle as firstfield​
	FROM ​
		sys.dm_exec_query_stats AS [deqs]​
		CROSS APPLY sys.dm_exec_sql_text ([deqs].sql_handle) as [dest]​
		CROSS APPLY sys.dm_exec_query_plan ([deqs].plan_handle) as [deqp]​
	'
END

ELSE
	BEGIN
		SET @Query = N'
		SELECT
			[deqs].[plan_handle] AS [PlanHandle], ​
			[deqs].[execution_count] AS [ExecCount],​
			[dest].[text] AS [Text], ​
			SUBSTRING(​
				[dest].text, ​
				([deqs].statement_start_offset / 2) + 1,​
				((CASE [deqs].statement_end_offset​
					WHEN -1 then DATALENGTH([dest].text)​
					ELSE [deqs].statement_end_offset​
				END - [deqs].statement_start_offset) / 2) + 1) AS [QueryText], ​
			[deqp].[query_plan] AS [QueryPlan], ​
			[deqs].[creation_time] AS [PlanCreatedAt], ​
			[deqs].[last_execution_time] AS [LastExecutedAt], ​
			[deqs].last_logical_reads, ​
			[deqs].total_elapsed_time, ​
			[deqs].last_elapsed_time, ​
			[deqs].[last_dop] AS [LastDoP],​
			[deqs].last_reserved_threads,-- ​
			[deqs].[last_rows] AS [Last#Rows],​
			[deqs].[total_rows] AS [Total#Rows],--​
			[deqs].[min_rows] AS [Min#Rows],--​
			[deqs].[max_rows] AS [Max#Rows],--​
			[deqs].[total_grant_kb] AS [TotalGrant],​
			[deqs].[last_used_grant_kb] AS [LastUsedGrant],​
			[deqs].[last_ideal_grant_kb] AS [LastIdealGrant],​
			[deqs].statement_start_offset,--
			[deqs].sql_handle as firstfield​
		FROM ​
			sys.dm_exec_query_stats AS [deqs]​
			CROSS APPLY sys.dm_exec_sql_text ([deqs].sql_handle) as [dest]​
			CROSS APPLY sys.dm_exec_query_plan ([deqs].plan_handle) as [deqp]​
		'
	END


IF(@Text is not null)
	SET @Query = @Query + @LineFeed + N'WHERE text like ''%' + @Text + '%''' + @LineFeed
	



SET @Query = CASE @OrderBy
	WHEN 'reads' THEN @Query + @LineFeed + N'ORDER BY last_logical_reads DESC'
	WHEN 'duration' THEN @Query + @LineFeed + N'ORDER BY last_elapsed_time DESC'
	WHEN 'memory' THEN @Query + @LineFeed + N'ORDER BY last_used_grant_kb DESC'
	ELSE @Query + @LineFeed + N'ORDER BY last_execution_time DESC'
END

EXEC (@Query)


END
