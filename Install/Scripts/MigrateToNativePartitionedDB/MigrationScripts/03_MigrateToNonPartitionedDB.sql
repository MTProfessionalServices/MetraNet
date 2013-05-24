BEGIN TRY 

IF NOT EXISTS (SELECT 1 FROM t_usage_server WHERE b_partitioning_enabled = 'Y')
BEGIN 
	PRINT('Database ' + DB_NAME() + ' already mirgated to non partitioned DB')
	
	--Remove column from t_prod_view	
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
			 WHERE TABLE_NAME='t_prod_view' AND COLUMN_NAME = 'b_migrated')
	BEGIN
		DECLARE @constraint_name NVARCHAR(128)
		
		SELECT @constraint_name = c_obj.name
		FROM sysobjects c_obj
		JOIN syscomments com ON c_obj.id = com.id
		JOIN sysobjects t_obj ON c_obj.parent_obj = t_obj.id 
		JOIN sysconstraints con ON c_obj.id = con.constid
		JOIN syscolumns col ON t_obj.id = col.id
		AND con.colid = col.colid
		WHERE
		c_obj.uid = user_id()
		and c_obj.xtype = 'D'
		and t_obj.name='t_prod_view' and col.name='b_migrated'
		
		EXEC('ALTER TABLE t_prod_view DROP CONSTRAINT ' + @constraint_name)
		
		ALTER TABLE t_prod_view 
		DROP COLUMN b_migrated
	END
	RETURN
END

IF OBJECT_ID('migrate_PVtoNonPartitioned') IS NULL 
	OR OBJECT_ID('migrate_ClonePrimaryKeyAndIndexesPVTable') IS NULL
	OR OBJECT_ID('migrate_TruncateTablesDropView') IS NULL
	OR OBJECT_ID('migrate_DropUnnecessaryStructure') IS NULL
BEGIN
	PRINT('Stored procedures for migration didn''t created')
	RETURN
END

DECLARE @table_name VARCHAR(128),
		@id_prod_view INT,		
		@tables_cur CURSOR			

SET @tables_cur = CURSOR FOR
					SELECT id_prod_view, nm_table_name FROM t_prod_view 
					WHERE b_migrated = 0
								
OPEN @tables_cur
FETCH @tables_cur INTO @id_prod_view, @table_name

WHILE (@@fetch_status >= 0) 
BEGIN	
	EXEC dbo.migrate_PVtoNonPartitioned @table_name = @table_name	
	
	EXEC dbo.migrate_ClonePrimaryKeyAndIndexesPVTable @table_name = @table_name	
	
	EXEC dbo.migrate_TruncateTablesDropView @table_name = @table_name
	
	UPDATE t_prod_view
	SET			
		b_migrated = 1
	WHERE id_prod_view = @id_prod_view	
	
FETCH @tables_cur INTO @id_prod_view, @table_name
END
DEALLOCATE @tables_cur

IF (SELECT COUNT(*) FROM t_prod_view WHERE b_migrated = 0) = 0
BEGIN
	EXEC dbo.migrate_DropUnnecessaryStructure	
END
ELSE
BEGIN
	PRINT('Migration not finish fully. Next tables didn''t migrated: ')
	SELECT nm_table_name FROM t_prod_view WHERE b_migrated = 0
	RETURN
END

IF OBJECT_ID('migrate_PVtoNonPartitioned') IS NOT NULL
	DROP PROCEDURE migrate_PVtoNonPartitioned

IF OBJECT_ID('migrate_ClonePrimaryKeyAndIndexesPVTable') IS NOT NULL
	DROP PROCEDURE migrate_ClonePrimaryKeyAndIndexesPVTable
	
IF OBJECT_ID('migrate_TruncateTablesDropView') IS NOT NULL
	DROP PROCEDURE migrate_TruncateTablesDropView
	
IF OBJECT_ID('migrate_DropUnnecessaryStructure') IS NOT NULL
	DROP PROCEDURE migrate_DropUnnecessaryStructure
	
PRINT('Database ' + DB_NAME() + ' migrated to non partition DB successfully.')

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)	
END CATCH

