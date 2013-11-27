
BEGIN TRAN

-- updates t_svc tables with any edits (also updates non-edited values)
%%SVC_UPDATE_STATEMENTS%%

--
-- deletes the requested children (if any) from t_svc tables
--
CREATE TABLE #children (id_source_sess BINARY(16))
%%INSERT_CHILDREN_TO_DELETE%%

DECLARE deleteCursor CURSOR FOR
SELECT
  svclog.nm_table_name
FROM #children children
INNER JOIN t_session s ON s.id_source_sess = children.id_source_sess
INNER JOIN t_session_set ss ON ss.id_ss = s.id_ss
INNER JOIN t_enum_data enum ON enum.id_enum_data = ss.id_svc
INNER JOIN t_service_def_log svclog ON svclog.nm_service_def = enum.nm_enum_data

-- executes the delete statements
DECLARE @tableName varchar(4096)
OPEN deleteCursor
FETCH NEXT FROM deleteCursor INTO @tableName
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('delete from ' + @tableName + ' where id_source_sess in (select id_source_sess from #children)')
    FETCH NEXT FROM deleteCursor INTO @tableName
END
CLOSE deleteCursor
DEALLOCATE deleteCursor

COMMIT TRAN

			