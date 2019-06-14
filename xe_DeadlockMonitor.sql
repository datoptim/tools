--	-------------------------------------------------------
--	DeadlockMonitor
--	https://datoptim.com/monitor-deadlock/
--	www.datoptim.com (c)
--	Boletin de noticias [es]: http://eepurl.com/giwb6L
--	Contactos y preguntas: pablof@datoptim.com
--	-------------------------------------------------------


CREATE EVENT SESSION [DeadlockMonitor] ON SERVER 
ADD EVENT sqlserver.lock_deadlock(
    ACTION(sqlos.task_time)),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(sqlos.task_time))
ADD TARGET package0.event_file(SET filename=N'DeadlockReg',
	max_file_size=(10240))
WITH (MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF)
GO
