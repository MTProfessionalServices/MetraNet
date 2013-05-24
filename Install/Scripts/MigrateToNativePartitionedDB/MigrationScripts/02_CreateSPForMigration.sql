-- migrate_PVtoNonPartitioned
IF OBJECT_ID('migrate_PVtoNonPartitioned') IS NOT NULL
	DROP PROCEDURE migrate_PVtoNonPartitioned
GO 
CREATE PROCEDURE migrate_PVtoNonPartitioned
	@table_name VARCHAR(128)
AS
DECLARE @old_view_name VARCHAR(128),
		@count_from_PV_view INT,
		@count_from_PV_table INT,
		@count_from_PV_view_text NVARCHAR(5),
		@count_from_PV_table_text NVARCHAR(5),
		@sql_cmd NVARCHAR(MAX),
		@table_id INT
		
SET @old_view_name = @table_name + '_old'

--rename
SELECT @table_id = t.[object_id] FROM sys.tables t
WHERE t.name = @table_name

IF @table_id IS NULL
BEGIN 
	EXEC('sp_rename ' + @table_name + ', ' + @old_view_name)
	PRINT('View ' + @table_name + ' was renamed to: ' + @old_view_name)
END
ELSE
BEGIN 
	EXEC('DROP TABLE ' + @table_name)
	PRINT('Dublicate table ' + @table_name + ' was dropped.')	
END

--create PV table
EXEC ('SELECT * INTO ' + @table_name + ' FROM ' + @old_view_name)
PRINT ('Table ' + @table_name + ' was created.' )

--check count
SET @sql_cmd = 'SELECT @count_from_PV_view = COUNT(*) FROM ' + @old_view_name
EXEC sp_executesql 
		@query = @sql_cmd, 
		@params = N'@count_from_PV_view INT OUTPUT', 
		@count_from_PV_view = @count_from_PV_view OUTPUT		
		
SET @sql_cmd = 'SELECT @count_from_PV_table = COUNT(*) FROM ' + @table_name
EXEC sp_executesql 
		@query = @sql_cmd, 
		@params = N'@count_from_PV_table INT OUTPUT', 
		@count_from_PV_table = @count_from_PV_table OUTPUT		
		
IF @count_from_PV_view <> @count_from_PV_table
BEGIN
	SET @count_from_PV_view_text = CAST(@count_from_PV_view AS NVARCHAR(5))
	SET @count_from_PV_table_text = CAST(@count_from_PV_table AS NVARCHAR(5))		
	RAISERROR('The counts of source rows = %s and destination rows = %s is not equal',16,1, @count_from_PV_view_text, @count_from_PV_table_text)	
END

GO 

-- migrate_ClonePrimaryKeyAndIndexesPVTable
IF OBJECT_ID('migrate_ClonePrimaryKeyAndIndexesPVTable') IS NOT NULL
	DROP PROCEDURE migrate_ClonePrimaryKeyAndIndexesPVTable
GO 
CREATE PROCEDURE migrate_ClonePrimaryKeyAndIndexesPVTable
	@table_name VARCHAR(128)
AS
DECLARE	@column_name NVARCHAR(128),
		@src_db VARCHAR(50),
		@sql VARCHAR(MAX)		

SET @src_db = 'N_default'
BEGIN TRY
	-- Get the primary key columns from source table in "N_default" partition DB
	SET @sql = 
		'
		DECLARE pk_cur CURSOR GLOBAL 
		FOR
			SELECT column_name --, kcu.constraint_name, ordinal_position,
			FROM ' + @src_db + '.INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
				   JOIN ' + @src_db + '.INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
						ON  kcu.constraint_name = tc.constraint_name
			WHERE  kcu.table_name = ''' + @table_name + '''
				   AND kcu.constraint_catalog = ''' + @src_db + '''
				   AND tc.constraint_type = ''PRIMARY KEY''
			ORDER BY
				   ordinal_position'
	EXEC (@sql)

	DECLARE @pk_ddl   VARCHAR(MAX)

	OPEN pk_cur
	FETCH pk_cur INTO @column_name
	SET @pk_ddl = '' -- ignore CONCAT_NULL_YIELDS_NULL

	-- Concat pk columns for primary key ddl
	WHILE @@fetch_status >= 0
	BEGIN
		SET @pk_ddl = @pk_ddl + @column_name + ', ' 
		FETCH pk_cur INTO @column_name
	END
	DEALLOCATE pk_cur

	-- Compose primary key ddl
	SET @pk_ddl = LEFT(@pk_ddl, LEN(@pk_ddl) -1)  -- chop trailing comma
	SET @pk_ddl = 'ALTER TABLE ' + @table_name + ' ADD CONSTRAINT pk_' + @table_name + 
				' PRIMARY KEY CLUSTERED(' + @pk_ddl + ')'
	EXEC (@pk_ddl)

	PRINT ('Primary key for table: "'+ @table_name + '" was created.');

	-- Hardcoding FK Constraint creation for "t_acc_usage"
	IF @table_name = 't_acc_usage'
	BEGIN
		-- FK on t_account(id_acc)
		ALTER TABLE t_acc_usage WITH CHECK ADD CONSTRAINT fk2_t_acc_usage FOREIGN KEY(id_payee)
			REFERENCES t_account (id_acc)
		ALTER TABLE t_acc_usage CHECK CONSTRAINT fk2_t_acc_usage
		PRINT ('Foreign key for table "t_acc_usage" was created. On comlumn: id_payee. Reffers on: t_account (id_acc).')
		
		-- FK on t_po(id_po)
		ALTER TABLE t_acc_usage WITH CHECK ADD CONSTRAINT fk3_t_acc_usage FOREIGN KEY(id_prod)
			REFERENCES t_po (id_po)
		ALTER TABLE t_acc_usage CHECK CONSTRAINT fk3_t_acc_usage
		PRINT ('Foreign key for table "t_acc_usage" was created. On comlumn: id_prod. Reffers on: t_po (id_po).')
		
		-- Unique constraint on tx_UID field
		ALTER TABLE t_acc_usage ADD CONSTRAINT C_t_acc_usage UNIQUE NONCLUSTERED (tx_UID ASC)
		PRINT ('Unique constraint for table "t_acc_usage" was created. On comlumn: tx_UID.')
	END
	
	-- Copying non-clustered indexes
	DECLARE @index_name NVARCHAR(128)
	DECLARE @str  NVARCHAR(MAX)

	SET @str = ''
	SET @sql = '
		DECLARE index_name CURSOR  
		FOR
			SELECT DISTINCT i.name
			FROM   ' + @src_db + '.sys.indexes i
				   INNER JOIN ' + @src_db + '.sys.objects o
						ON  o.object_id = i.object_id
				   INNER JOIN ' + @src_db + '.sys.stats s
						ON  i.object_id = s.object_id
			WHERE  i.object_id IN (SELECT OBJECT_ID
								   FROM   ' + @src_db + '.sys.objects
								   WHERE  NAME = ''' + @table_name + ''')
				   AND i.is_hypothetical <> 1
				   AND i.type_desc <> ''CLUSTERED''
				   AND s.auto_created = 0
				   AND o.type = (''U'')
				   AND i.name NOT IN (SELECT constraint_name
									  FROM   ' + @src_db + '.information_schema.table_constraints
									  WHERE  table_name = ''' + @table_name + ''')
	'
	EXEC (@sql)

	OPEN index_name
	FETCH NEXT FROM index_name INTO @index_name
	WHILE (@@fetch_status = 0)
	BEGIN
		SET @sql = '
		DECLARE column_name CURSOR  
		FOR
			SELECT DISTINCT c.name
			FROM   ' + @src_db + '.sys.objects o
				   INNER JOIN ' + @src_db + '.sys.indexes i
						ON  o.object_id = i.object_id
				   INNER JOIN ' + @src_db + '.sys.index_columns ic
						ON  i.object_id = ic.object_id
						AND i.index_id = ic.index_id
				   INNER JOIN ' + @src_db + '.sys.columns c
						ON  ic.object_id = c.object_id
						AND ic.column_id = c.column_id
				   INNER JOIN ' + @src_db + '.sys.stats s
						ON  i.object_id = s.object_id
			WHERE  o.type = ''U''
				   AND o.name = ''' + @table_name + '''
				   AND i.is_hypothetical <> 1
				   AND i.type_desc <> ''CLUSTERED''
				   AND s.auto_created = 0
				   AND i.name = ''' + @index_name + '''
			ORDER BY
				   c.name
		'
		EXEC (@sql)
		
		OPEN column_name
		FETCH NEXT FROM column_name INTO @column_name
		WHILE (@@fetch_status = 0)
		BEGIN
			IF (@str <> '')
				SET @str = @str + ','
			
			SET @str = @str + @column_name
			FETCH NEXT FROM column_name INTO @column_name
		END
		CLOSE column_name
		DEALLOCATE column_name

		SET @sql = 'CREATE INDEX ' + @index_name + ' ON ' + @table_name + '(' + @str + ')'
		EXEC (@sql)
		
		PRINT ('Index "' + @index_name + '" was created for table: "'+ @table_name + '". On columns:' + @str + '.');
		
		SET @str = ''
		FETCH NEXT FROM index_name INTO @index_name
	END
	CLOSE index_name
	DEALLOCATE index_name

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT	
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH

GO

-- migrate_TruncateTablesDropView
IF OBJECT_ID('migrate_TruncateTablesDropView') IS NOT NULL
	DROP PROCEDURE migrate_TruncateTablesDropView
GO 
CREATE PROCEDURE migrate_TruncateTablesDropView
	@table_name VARCHAR(128)
AS
DECLARE	
	@view_name VARCHAR(128)

SET @view_name = @table_name + '_old';
	  
DECLARE partcur CURSOR FOR
	SELECT partition_name
	FROM t_partition 
	
DECLARE @partition_name VARCHAR(50)

OPEN partcur
FETCH NEXT FROM partcur INTO @partition_name
WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF OBJECT_ID(@partition_name + '.dbo.' + @table_name) IS NOT NULL
	BEGIN
		EXEC ('TRUNCATE TABLE ' + @partition_name + '.dbo.' + @table_name)
		PRINT ('Table '+ @table_name + ' from database '+ @partition_name + ' was truncated.');
	END
		
	FETCH NEXT FROM partcur INTO @partition_name
END

CLOSE partcur
DEALLOCATE partcur 

IF OBJECT_ID(@view_name) IS NOT NULL
	BEGIN
		EXEC ('DROP VIEW '+ @view_name)
		PRINT('View '+ @view_name + ' was dropped.')
    END
GO

-- migrate_DropUnnecessaryStructure
IF OBJECT_ID('migrate_DropUnnecessaryStructure') IS NOT NULL
	DROP PROCEDURE migrate_DropUnnecessaryStructure
GO

CREATE PROCEDURE migrate_DropUnnecessaryStructure	
AS 
-- Drop all partition views DB
PRINT('Drop partitioned view databases')

DECLARE partviewcur CURSOR FOR
	SELECT partition_name
	FROM t_partition 
	
DECLARE @partition_name VARCHAR(50)

OPEN partviewcur
FETCH NEXT FROM partviewcur INTO @partition_name
WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF EXISTS(SELECT NAME FROM sys.databases WHERE NAME = @partition_name) 
	BEGIN
		EXEC ('DROP DATABASE ' + @partition_name)
		PRINT ('Database '+ @partition_name + ' was dropped.')
	END  
	FETCH NEXT FROM partviewcur INTO @partition_name
END

CLOSE partviewcur
DEALLOCATE partviewcur 

-- Drop t_uk_* tables
PRINT('Drop unique key tables')

DECLARE uktablecur CURSOR FOR
	SELECT TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_NAME LIKE 't_uk_%'
	
DECLARE @uk_table_name VARCHAR(50)

OPEN uktablecur
FETCH NEXT FROM uktablecur INTO @uk_table_name
WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF OBJECT_ID(@uk_table_name) IS NOT NULL
	BEGIN
		EXEC ('DROP TABLE ' + @uk_table_name)
		PRINT ('Table '+ @uk_table_name + ' was dropped.')
	END  
	FETCH NEXT FROM uktablecur INTO @uk_table_name
END

CLOSE uktablecur
DEALLOCATE uktablecur 

-- Cleanup info about PV unique constraints to make them be created on PV HOOK run
ALTER TABLE t_unique_cons_columns DROP fk1_t_unique_cons_col

BEGIN TRAN
DECLARE @acc_usage_uc_id INT

SELECT @acc_usage_uc_id = id_unique_cons
FROM   t_unique_cons
       JOIN t_prod_view tpv
            ON  tpv.id_prod_view = t_unique_cons.id_prod_view
WHERE  tpv.nm_table_name = 't_acc_usage'
PRINT('Truncate t_unique_cons table')
DELETE FROM t_unique_cons WHERE id_unique_cons <> @acc_usage_uc_id;

PRINT('Truncate t_unique_cons_columns table')
DELETE FROM t_unique_cons_columns WHERE id_unique_cons <> @acc_usage_uc_id

PRINT('Clear all checksums in t_product_view_log')
UPDATE t_product_view_log SET tx_checksum = ''
COMMIT

ALTER TABLE t_unique_cons_columns WITH CHECK ADD CONSTRAINT fk1_t_unique_cons_col FOREIGN KEY(id_unique_cons)
REFERENCES t_unique_cons (id_unique_cons)
ALTER TABLE t_unique_cons_columns CHECK CONSTRAINT fk1_t_unique_cons_col

--Truncate t_partition,t_partition_storage tables
PRINT('Truncate t_partition table')
IF OBJECT_ID('t_partition') IS NOT NULL 
	TRUNCATE TABLE t_partition 
	
PRINT('Truncate t_partition_storage table')
IF OBJECT_ID('t_partition_storage') IS NOT NULL 
TRUNCATE TABLE t_partition_storage

-- Update t_usage_server
PRINT('Update t_usage_server table')
UPDATE t_usage_server
SET b_partitioning_enabled = 'N'

--Remove column from t_prod_view
PRINT('Remove column from t_prod_view')
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
ELSE
	PRINT('Table t_prod_view doesn''t have column b_migrated')