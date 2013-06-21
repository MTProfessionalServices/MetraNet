IF object_id('TR_%%NM_NAME%%_ID_SCHED') IS NULL
BEGIN
	DECLARE @Sql nvarchar(2048)
	SET @Sql = 'CREATE TRIGGER TR_%%NM_NAME%%_ID_SCHED ON %%NM_NAME%% ' +
'AFTER INSERT, UPDATE ' +
'AS ' +
'BEGIN ' +
'	DECLARE @n_counter int ' +
'	SELECT @n_counter = COUNT(1) ' +
'	FROM   inserted i ' +
'	WHERE  NOT EXISTS (SELECT 1 FROM t_rsched r WHERE i.id_sched = r.id_sched) ' +
'	   AND NOT EXISTS (SELECT 1 FROM t_rsched_pub rp WHERE i.id_sched = rp.id_sched) ' +

'	IF @n_counter > 0 ' +
'		RAISERROR(''Parent key not found for record in %%NM_NAME%% table'', 16, 1) ' +
'END'
	EXECUTE (@Sql)
END
