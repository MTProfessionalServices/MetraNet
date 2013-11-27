
    CREATE PROCEDURE Dearchive_account
			(
			@interval_id int,
			@account_id_list nvarchar(4000),
			@path nvarchar(1000),
			@constraint nchar(1) = 'Y',
			@data_file_type nchar(1) = 'n',
			@result nvarchar(4000) output
			)
	AS
	/*		How to run this procedure
	declare @result nvarchar(2000)
	exec dearchive_account @interval_id=827719717,@account_id_list=null,@path='c:\backup\archive',@result=@result output
	print @result
	*/
	
	SET NOCOUNT ON
	DECLARE @sql1 NVARCHAR(4000)
	DECLARE @tab1 NVARCHAR(1000)
	DECLARE @tab2 NVARCHAR(1000)
	DECLARE @var1 NVARCHAR(100)		
	DECLARE @vartime DATETIME
	DECLARE @maxtime DATETIME
	DECLARE @bucket INT
	DECLARE @dbname NVARCHAR(100)
	DECLARE @partition NVARCHAR(4000)
	
	SELECT @vartime = GETDATE()
	SELECT @maxtime = dbo.mtmaxdate()
	SELECT @dbname = DB_NAME()
	--Checking following Business rules :
	--Interval should be archived
	--Account is in archived state
	--Verify the database name
	IF (@data_file_type <> 'c' AND @data_file_type <> 'n')
	BEGIN
	    SET @result = 
	        '5000001a-dearchive operation failed-->@data_file_type should be either c or n'
	    
	    RETURN
	END
	
	SELECT @tab2 = table_name
	FROM   information_schema.tables
	WHERE  table_name = 'T_ACC_USAGE'
	       AND table_catalog = @dbname
	
	IF (@tab2 IS NULL)
	BEGIN
	    SET @result = 
	        '5000001-dearchive operation failed-->check the database name'
	    
	    RETURN
	END
	
	IF NOT EXISTS (
	       SELECT TOP 1 * 
	       FROM   t_archive
	       WHERE  id_interval = @interval_id
	              AND STATUS = 'A'
	              AND tt_end = @maxtime
	   )
	BEGIN
	    SET @result = 
	        '5000002-dearchive operation failed-->Interval is not archived (Data from this Interval was not deleted).'
	    
	    RETURN
	END
	--TO GET LIST OF ACCOUNT
	CREATE TABLE #AccountIDsTable
	(
		ID      INT NOT NULL,
		bucket  INT
	)
	
	IF (@account_id_list IS NOT NULL)
	BEGIN
	    BEGIN TRY
	    	INSERT INTO #AccountIDsTable
	    	  (
	    	    ID
	    	  )
	    	SELECT items
	    	FROM   mvm_split(@account_id_list, ',')
	    END TRY
	    BEGIN CATCH
	    	SET @result = 
	    	    '5000004-dearchive operation failed-->error in insert into #AccountIDsTable, Details: ' 
	    	    +
	    	    ERROR_MESSAGE()
	    	
	    	RETURN
	    END CATCH		
	    
	    UPDATE #AccountIDsTable
	    SET    bucket = act.bucket
	    FROM   #AccountIDsTable
	           INNER JOIN t_acc_bucket_map act
	                ON  #AccountIDsTable.id = act.id_acc
	    WHERE  act.id_usage_interval = @interval_id
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000005-dearchive operation failed-->error in update #AccountIDsTable'
	        
	        RETURN
	    END
	END
	ELSE
	BEGIN
	    SET @sql1 = 
	        'insert into #AccountIDsTable(id,bucket) select id_acc,bucket from
			t_acc_bucket_map where status =''A'' and tt_end = dbo.mtmaxdate() and id_acc not in (select distinct id_acc from t_acc_usage where
			id_usage_interval = ' + CAST(@interval_id AS VARCHAR(20)) + 
	        ') and id_usage_interval = ' + CAST(@interval_id AS VARCHAR(20))
	    
	    EXEC (@sql1)
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000006-dearchive operation failed-->error in insert into #AccountIDsTable'
	        
	        RETURN
	    END
	END
	
	IF EXISTS (
	       SELECT 1
	       FROM   t_acc_bucket_map
	       WHERE  id_usage_interval = @interval_id
	              AND STATUS = 'D'
	              AND tt_end = @maxtime
	              AND id_acc IN (SELECT id
	                             FROM   #AccountIDsTable)
	   )
	BEGIN
	    SET @result = 
	        '5000007-dearchive operation failed-->one of the account is already dearchived'
	    
	    RETURN
	END
	
	IF EXISTS(
	       SELECT 1
	       FROM   #AccountIDsTable
	       WHERE  bucket IS NULL
	   )
	BEGIN
	    SET @result = 
	        '5000008-dearchive operation failed-->one of the account does not have bucket mapping...check the accountid'
	    
	    RETURN
	END
	-----------------------------------------------------------------------------
	--- check that product view files are exist for dearchive
	-----------------------------------------------------------------------------
	DECLARE c1 CURSOR FAST_FORWARD 
	FOR
	    SELECT DISTINCT id_view
	    FROM   t_archive
	    WHERE  id_interval = @interval_id
	           AND tt_end = @maxtime
	           AND id_view IS NOT NULL
					-------------------------------------------------------
					--Checking the existence of import files for each table
					-------------------------------------------------------
					DECLARE c2 CURSOR FAST_FORWARD 
					FOR
						SELECT DISTINCT bucket
						FROM   #AccountIDsTable
					
					OPEN c2
					FETCH NEXT FROM c2 INTO @bucket
					WHILE (@@fetch_status = 0)
					BEGIN
						
						DECLARE @FileName NVARCHAR(128)
						SELECT @FileName = 't_acc_usage' + '_' + CAST(@interval_id AS VARCHAR(10)) 
							   + '_' + CAST(@bucket AS VARCHAR(10)) + '.txt'
					    
						DECLARE @i INT
						DECLARE @File NVARCHAR(2000)
						SELECT @File = @Path + '\' + @FileName
						EXEC MASTER..xp_fileexist @File,
							 @i OUT
					    
						IF @i <> 1
						BEGIN
							SET @result = 
								'5000009-dearchive operation failed-->bcp usage file does not exist'
					        
							CLOSE c2
							DEALLOCATE c2
							DEALLOCATE c1
							RETURN
						END
	    
							OPEN c1
							FETCH NEXT FROM c1 INTO @var1
							WHILE @@fetch_status = 0
							BEGIN
								SELECT @tab1 = nm_table_name
								FROM   t_prod_view
								WHERE  id_view = @var1
						        
								SELECT @filename = @tab1 + '_' + CAST(@interval_id AS VARCHAR(10)) + 
									   '_' + CAST(@bucket AS VARCHAR(10)) + '.txt'
						        
								SELECT @File = @Path + '\' + @FileName
								EXEC MASTER..xp_fileexist @File,
									 @i OUT
						        
								IF @i <> 1
								BEGIN
									SET @result = '5000010-dearchive operation failed-->bcp ' + CAST(@FileName AS NVARCHAR(128)) 
										+ ' file does not exist'
						            
									CLOSE c1
									DEALLOCATE c1
									CLOSE c2
									DEALLOCATE c2
									RETURN
								END
						        
								FETCH NEXT FROM c1 INTO @var1
							END
							CLOSE c1
							
							-----------------------------------------------------------------------------------------
							-------check existing agg_usage_audit_trail files for dearchiving
							-----------------------------------------------------------------------------------------
							SELECT @filename = 'agg_usage_audit_trail_' + CAST(@interval_id AS VARCHAR(10)) + 
									   '_' + CAST(@bucket AS VARCHAR(10)) + '.txt'
						        
								SELECT @File = @Path + '\' + @FileName
								EXEC MASTER..xp_fileexist @File,
									 @i OUT
						        
								IF @i <> 1
								BEGIN
									SET @result = '5000010-dearchive operation failed-->bcp ' + CAST(@filename AS NVARCHAR(128)) 
										+ ' file does not exist'
						            
									CLOSE c1
									DEALLOCATE c1
									CLOSE c2
									DEALLOCATE c2
									RETURN
								END
							
							
							-----------------------------------------------------------------------------------------
							-------check existing agg_charge_audit_trail files for dearchiving
							-----------------------------------------------------------------------------------------
							SELECT @filename = 'agg_charge_audit_trail_' + CAST(@interval_id AS VARCHAR(10)) + 
									   '_' + CAST(@bucket AS VARCHAR(10)) + '.txt'
						        
								SELECT @File = @Path + '\' + @FileName
								EXEC MASTER..xp_fileexist @File,
									 @i OUT
						        
								IF @i <> 1
								BEGIN
									SET @result = '5000010-dearchive operation failed-->bcp ' + CAST(@filename AS NVARCHAR(128)) 
										+ ' file does not exist'
						            
									CLOSE c1
									DEALLOCATE c1
									CLOSE c2
									DEALLOCATE c2
									RETURN
								END
			
			
					FETCH NEXT FROM c2 INTO @bucket
				END
	CLOSE c2
	DEALLOCATE c1
	
	-----------------------------------------------------------------------------
	--- check that t_adjustment_transaction file is exist for dearchive
	-----------------------------------------------------------------------------
	
	IF NOT EXISTS (
	       SELECT TOP 1 id_adj_trx
	       FROM   t_adjustment_transaction
	       WHERE  id_usage_interval = @interval_id
	   )
	BEGIN
	    SELECT @FileName = 't_adjustment_transaction' + '_' + CAST(@interval_id AS VARCHAR(10)) 
	           + '.txt'
	    
	    SELECT @File = @Path + '\' + @FileName
	    EXEC MASTER..xp_fileexist @File,
	         @i OUT
	    
	    IF @i <> 1
	    BEGIN
	        SET @result = 
	            '5000011-dearchive operation failed-->bcp t_adjustment_transaction file does not exist'
	            DEALLOCATE c2
	        
	        RETURN
	    END
	    
		-----------------------------------------------------------------------------
		--- check that t_aj_* files are exist for dearchive
		-----------------------------------------------------------------------------
	    DECLARE c1 CURSOR FAST_FORWARD 
	    FOR
	        SELECT DISTINCT adj_name
	        FROM   t_archive
	        WHERE  id_interval = @interval_id
	               AND tt_end = @maxtime
	               AND adj_name IS NOT NULL
	               AND STATUS = 'A'
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @var1
	    WHILE @@fetch_status = 0
	    BEGIN
	        SELECT @filename = @var1 + '_' + CAST(@interval_id AS VARCHAR(10)) + 
	               '.txt'
	        
	        SELECT @File = @Path + '\' + @FileName
	        EXEC MASTER..xp_fileexist @File,
	             @i OUT
	        
	        IF @i <> 1
	        BEGIN
	            SET @result = '5000012-dearchive operation failed-->bcp ' + CAST(@FileName AS NVARCHAR(128)) 
	                + ' file does not exist'
	            
	            CLOSE c1
	            DEALLOCATE c1
	            DEALLOCATE c2
	            RETURN
	        END
	        
	        FETCH NEXT FROM c1 INTO @var1
	    END
	    CLOSE c1
	    DEALLOCATE c1
	END
	
	-----------------------------------------------------------------------------
	------ dearchive data from txt files
	------------------------------------------------------------------------------
	
	BEGIN TRAN
	------------------------------------
	--Insert data into t_acc_usage
	------------------------------------
	OPEN c2
	FETCH NEXT FROM c2 INTO @bucket
	WHILE (@@fetch_status = 0)
	BEGIN
	    IF OBJECT_ID('tempdb..#tmp_t_acc_usage') IS NOT NULL
	        DROP TABLE #tmp_t_acc_usage
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000012a--dearchive operation failed-->error in dropping #tmp_t_acc_usage'
	        
	        ROLLBACK TRAN
	        CLOSE c2
	        DEALLOCATE c2
	        RETURN
	    END
	    
	    SELECT * INTO #tmp_t_acc_usage
	    FROM   t_acc_usage
	    WHERE  0 = 1
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000012b-dearchive operation failed-->error in creating #tmp_t_acc_usage'
	        
	        ROLLBACK TRAN
	        CLOSE c2
	        DEALLOCATE c2
	        RETURN
	    END
	    
	    IF (@data_file_type = 'n')
	    BEGIN
	        SELECT @sql1 = 'bulk insert #tmp_t_acc_usage from ''' + @path + 
	               '\t_acc_usage' + '_' +
	               CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
	               + 
	               '.txt''
					WITH
	      				(
					DATAFILETYPE = ''native'',
	       				CHECK_CONSTRAINTS
	      				)'
	    END
	    
	    IF (@data_file_type = 'c')
	    BEGIN
	        SELECT @sql1 = 'bulk insert #tmp_t_acc_usage from ''' + @path + 
	               '\t_acc_usage' + '_' +
	               CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
	               + 
	               '.txt''
					WITH
	      				(
					FIELDTERMINATOR = ''\t'',
	       				ROWTERMINATOR = ''\n'',
	       				CHECK_CONSTRAINTS
	      				)'
	    END
	    
	    EXEC (@sql1)
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000013-dearchive operation failed-->error in usage bulk insert operation'
	        
	        ROLLBACK TRAN
	        CLOSE c2
	        DEALLOCATE c2
	        RETURN
	    END
	    
	    CREATE UNIQUE CLUSTERED INDEX idx_tmp_t_acc_usage ON #tmp_t_acc_usage(id_sess, id_usage_interval)
	    CREATE INDEX idx1_tmp_t_acc_usage ON #tmp_t_acc_usage(id_acc)
	    
	    IF (@constraint = 'Y')
	    BEGIN
	        IF EXISTS (
	               SELECT 1
	               FROM   #tmp_t_acc_usage
	               WHERE  id_pi_template NOT IN (SELECT id_template
	                                             FROM   t_pi_template)
	           )
	        BEGIN
	            SET @result = 
	                '5000014-dearchive operation failed-->id_pi_template key violation'
	            
	            ROLLBACK TRAN
	            CLOSE c2
	            DEALLOCATE c2
	            RETURN
	        END
	        
	        IF EXISTS (
	               SELECT 1
	               FROM   #tmp_t_acc_usage
	               WHERE  id_pi_instance NOT IN (SELECT id_pi_instance
	                                             FROM   t_pl_map)
	           )
	        BEGIN
	            SET @result = 
	                '5000015-dearchive operation failed-->id_pi_instance key violation'
	            
	            ROLLBACK TRAN
	            CLOSE c2
	            DEALLOCATE c2
	            RETURN
	        END
	        
	        IF EXISTS (
	               SELECT 1
	               FROM   #tmp_t_acc_usage
	               WHERE  id_view NOT IN (SELECT id_view
	                                      FROM   t_prod_view)
	           )
	        BEGIN
	            SET @result = 
	                '5000016-dearchive operation failed-->id_view key violation'
	            
	            ROLLBACK TRAN
	            CLOSE c2
	            DEALLOCATE c2
	            RETURN
	        END
	    END
	    
	    INSERT INTO t_acc_usage
	    SELECT *
	    FROM   #tmp_t_acc_usage
	    WHERE  id_acc IN (SELECT id
	                      FROM   #AccountIDsTable)
	    
	    ----------------------------------------
	    --Insert data into amp tables
	    ----------------------------------------- 
	    --- insert data into agg_usage_audit_trail
	    IF OBJECT_ID('agg_usage_audit_trail') IS NOT NULL
	    BEGIN
				IF OBJECT_ID('tempdb..#tmp_agg_usage_audit_trail') IS NOT NULL
					DROP TABLE #tmp_agg_usage_audit_trail
			    
				IF (@@error <> 0)
				BEGIN
					SET @result = 
						'5000012a--dearchive operation failed-->error in dropping #tmp_agg_usage_audit_trail'
			        
					ROLLBACK TRAN
					CLOSE c2
					DEALLOCATE c2
					RETURN
				END
			    
				SELECT * INTO #tmp_agg_usage_audit_trail
				FROM   agg_usage_audit_trail
				WHERE  0 = 1
			    
				IF (@@error <> 0)
				BEGIN
					SET @result = 
						'5000012b-dearchive operation failed-->error in creating #tmp_agg_usage_audit_trail'
			        
					ROLLBACK TRAN
					CLOSE c2
					DEALLOCATE c2
					RETURN
				END
			    
				IF (@data_file_type = 'n')
				BEGIN
					SELECT @sql1 = 'bulk insert #tmp_agg_usage_audit_trail from ''' + @path + 
						   '\agg_usage_audit_trail_' +
						   CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
						   + 
						   '.txt''
							WITH
	      						(
							DATAFILETYPE = ''native'',
	       						CHECK_CONSTRAINTS
	      						)'
				END
			    
				IF (@data_file_type = 'c')
				BEGIN
					SELECT @sql1 = 'bulk insert #tmp_agg_usage_audit_trail from ''' + @path + 
						   '\agg_usage_audit_trail_' +
						   CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
						   + 
						   '.txt''
							WITH
	      						(
							FIELDTERMINATOR = ''\t'',
	       						ROWTERMINATOR = ''\n'',
	       						CHECK_CONSTRAINTS
	      						)'
				END
			    
				EXEC (@sql1)
				IF (@@error <> 0)
				BEGIN
					SET @result = 
						'5000013-dearchive operation failed-->error in agg_usage_audit_trail bulk insert operation'
			        
					ROLLBACK TRAN
					CLOSE c2
					DEALLOCATE c2
					RETURN
				END
				
				INSERT INTO agg_usage_audit_trail
				SELECT * FROM #tmp_agg_usage_audit_trail 
		END
	    
	    --- insert data into agg_charge_audit_trail
	    IF OBJECT_ID('agg_charge_audit_trail') IS NOT NULL
	    BEGIN
	    	
				IF OBJECT_ID('tempdb..#tmp_agg_charge_audit_trail') IS NOT NULL
					DROP TABLE #tmp_agg_charge_audit_trail
			    
				IF (@@error <> 0)
				BEGIN
					SET @result = 
						'5000012a--dearchive operation failed-->error in dropping #tmp_agg_charge_audit_trail'
			        
					ROLLBACK TRAN
					CLOSE c2
					DEALLOCATE c2
					RETURN
				END
			    
				SELECT * INTO #tmp_agg_charge_audit_trail
				FROM   agg_charge_audit_trail
				WHERE  0 = 1
			    
				IF (@@error <> 0)
				BEGIN
					SET @result = 
						'5000012b-dearchive operation failed-->error in creating #tmp_agg_charge_audit_trail'
			        
					ROLLBACK TRAN
					CLOSE c2
					DEALLOCATE c2
					RETURN
				END
			    
				IF (@data_file_type = 'n')
				BEGIN
					SELECT @sql1 = 'bulk insert #tmp_agg_charge_audit_trail from ''' + @path + 
						   '\agg_charge_audit_trail_' +
						   CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
						   + 
						   '.txt''
							WITH
	      						(
							DATAFILETYPE = ''native'',
	       						CHECK_CONSTRAINTS
	      						)'
				END
			    
				IF (@data_file_type = 'c')
				BEGIN
					SELECT @sql1 = 'bulk insert #tmp_agg_charge_audit_trail from ''' + @path + 
						   '\agg_charge_audit_trail_' +
						   CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
						   + 
						   '.txt''
							WITH
	      						(
							FIELDTERMINATOR = ''\t'',
	       						ROWTERMINATOR = ''\n'',
	       						CHECK_CONSTRAINTS
	      						)'
				END
			    
				EXEC (@sql1)
				IF (@@error <> 0)
				BEGIN
					SET @result = 
						'5000013-dearchive operation failed-->error in agg_charge_audit_trail bulk insert operation'
			        
					ROLLBACK TRAN
					CLOSE c2
					DEALLOCATE c2
					RETURN
				END 
				
				INSERT INTO agg_charge_audit_trail
				SELECT * FROM #tmp_agg_charge_audit_trail tacht
				
		END              
	    
	    ----------------------------------------
	    --Insert data into product view tables
	    -----------------------------------------
	    
	    DECLARE c1 CURSOR FAST_FORWARD 
	    FOR
	        SELECT DISTINCT id_view
	        FROM   #tmp_t_acc_usage
	        WHERE  id_acc IN (SELECT id
	                          FROM   #AccountIDsTable)
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @var1
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        SELECT @tab1 = nm_table_name
	        FROM   t_prod_view
	        WHERE  id_view = @var1
	        
	        IF EXISTS (
	               SELECT 1
	               FROM   t_query_log pv
	                      INNER JOIN t_archive arc
	                           ON  pv.c_id_view = arc.id_view
	                           AND pv.c_id_view = @var1
	                           AND pv.c_timestamp > arc.tt_start
	                           AND arc.id_interval = @interval_id
	                           AND arc.status = 'E'
	                           AND NOT EXISTS (
	                                   SELECT 1
	                                   FROM   t_archive arc1
	                                   WHERE  arc.id_interval = arc1.id_interval
	                                          AND arc.id_view = arc1.id_view
	                                          AND arc1.status = 'E'
	                                          AND arc1.tt_start > arc.tt_start
	                               )
	           )
	        BEGIN
	            SELECT @sql1 = N'IF object_id(''tempdb..tmp_' + @tab1 + 
	                   ''') is not null drop table tempdb..tmp_' + @tab1
	            
	            EXEC (@sql1)
	            
	            DECLARE @create_table VARCHAR(8000)
	            SELECT TOP 1 @create_table = c_old_schema
	            FROM   t_query_log pv
	                   INNER JOIN t_archive arc
	                        ON  pv.c_id_view = arc.id_view
	                        AND pv.c_id_view = @var1
	                        AND pv.c_timestamp > arc.tt_start
	                        AND arc.id_interval = @interval_id
	                        AND arc.status = 'E'
	                        AND pv.c_old_schema IS NOT NULL
	            ORDER BY
	                   pv.c_timestamp,
	                   c_id
	            
	            SELECT @create_table = REPLACE(@create_table, @tab1, 'tempdb..tmp_' + @tab1)
	            EXEC (@create_table)
	            IF (@@error <> 0)
	            BEGIN
	                SET @result = 
	                    '5000017-dearchive operation failed-->error in creating temp pv table' 
	                    + CAST(@tab1 AS NVARCHAR(1000))
	                
	                ROLLBACK TRAN
	                CLOSE c1
	                DEALLOCATE c1
	                CLOSE c2
	                DEALLOCATE c2
	                RETURN
	            END
	            
	            DECLARE @change NVARCHAR(4000)
	            DECLARE @c_id INT
	            DECLARE c3 CURSOR  
	            FOR
	                SELECT DISTINCT c_query,
	                       c_id
	                FROM   t_query_log pv
	                       INNER JOIN t_archive
	                            arc
	                            ON  pv.c_id_view = arc.id_view
	                            AND pv.c_id_view = @var1
	                            AND pv.c_timestamp > arc.tt_start
	                            AND arc.id_interval = @interval_id
	                            AND arc.status = 'E'
	                            AND pv.c_query IS NOT NULL
	                ORDER BY
	                       c_id
	        END
	        ELSE
	        BEGIN
	            SELECT @sql1 = N'IF object_id(''tempdb..tmp_' + @tab1 + 
	                   ''') is not null drop table tempdb..tmp_' + @tab1
	            
	            EXEC (@sql1)
	            SELECT @sql1 = 'select * into  tempdb..tmp_' + @tab1 + ' from ' 
	                   + @dbname + '..' + @tab1 + ' where 0=1'
	            
	            EXEC (@sql1)
	            IF (@@error <> 0)
	            BEGIN
	                SET @result = 
	                    '5000018-dearchive operation failed-->error in creating temp pv table from origional ' 
	                    + CAST(@tab1 AS NVARCHAR(1000))
	                
	                ROLLBACK TRAN
	                CLOSE c1
	                DEALLOCATE c1
	                CLOSE c2
	                DEALLOCATE c2
	                RETURN
	            END
	        END
	        IF (@data_file_type = 'n')
	        BEGIN
	            SELECT @sql1 = 'bulk insert tempdb..tmp_' + @tab1 + ' from ''' + 
	                   @path + '\' + @tab1 +
	                   '_' + CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
	                   + 
	                   '.txt'' WITH
	      					(
							DATAFILETYPE = ''native''
	      					)'
	        END
	        
	        IF (@data_file_type = 'c')
	        BEGIN
	            SELECT @sql1 = 'bulk insert tempdb..tmp_' + @tab1 + ' from ''' + 
	                   @path + '\' + @tab1 +
	                   '_' + CAST(@interval_id AS VARCHAR(10)) + '_' + CAST(@bucket AS VARCHAR(10)) 
	                   + 
	                   '.txt'' WITH
	      					(
						FIELDTERMINATOR = ''\t'',
	       					ROWTERMINATOR = ''\n''
	      					)'
	        END
	        
	        EXEC (@sql1)
	        IF (@@error <> 0)
	        BEGIN
	            SET @result = 
	                '5000019-dearchive operation failed-->error in bulk insert operation for table ' 
	                + CAST(@tab1 AS NVARCHAR(1000))
	            
	            ROLLBACK TRAN
	            CLOSE c1
	            DEALLOCATE c1
	            CLOSE c2
	            DEALLOCATE c2
	            RETURN
	        END
	        
	        IF EXISTS (
	               SELECT 1
	               FROM   t_query_log pv
	                      INNER JOIN t_archive arc
	                           ON  pv.c_id_view = arc.id_view
	                           AND pv.c_id_view = @var1
	                           AND pv.c_timestamp > arc.tt_start
	                           AND arc.id_interval = @interval_id
	                           AND arc.status = 'E'
	           )
	        BEGIN
	            OPEN c3
	            FETCH c3 INTO @change,@c_id
	            WHILE (@@FETCH_STATUS = 0)
	            BEGIN
	                SELECT @change = STUFF(
	                           @change,
	                           CHARINDEX(@tab1, @change),
	                           LEN(@tab1),
	                           'tempdb..tmp_' + @tab1
	                       )
	                
	                EXEC (@change)
	                FETCH NEXT FROM c3 INTO @change,@c_id
	            END
	            CLOSE c3
	            DEALLOCATE c3
	        END
	        
	        SELECT @sql1 = 'insert into ' + @dbname + '..' + @tab1 + 
	               ' select * from tempdb..tmp_' + @tab1 + 
	               ' where id_sess
 						in (select id_sess from #tmp_t_acc_usage where id_acc in (select id from #AccountIDsTable))'
	        
	        EXEC (@sql1)
	        IF (@@error <> 0)
	        BEGIN
	            SET @result = 
	                '5000020-dearchive operation failed-->error in insert into pv table from temp table ' 
	                + CAST(@tab1 AS NVARCHAR(1000))
	            
	            ROLLBACK TRAN
	            CLOSE c1
	            DEALLOCATE c1
	            CLOSE c2
	            DEALLOCATE c2
	            RETURN
	        END
	        
	        SELECT @sql1 = N'IF object_id(''tempdb..tmp_' + @tab1 + 
	               ''') is not null drop table tempdb..tmp_' + @tab1
	        
	        EXEC (@sql1)
	        FETCH NEXT FROM c1 INTO @var1
	    END
	    CLOSE c1
	    DEALLOCATE c1
	    FETCH NEXT FROM c2 INTO @bucket
	END
	CLOSE c2
	DEALLOCATE c2
	
	---------------------------------------------
	 --Insert data into t_adjustment_transaction
	---------------------------------------------
	IF NOT EXISTS (
	       SELECT TOP 1 id_adj_trx
	       FROM   t_adjustment_transaction
	       WHERE  id_usage_interval = @interval_id
	   )
	BEGIN
	    --Insert data into t_adjustment_transaction
	    IF OBJECT_ID('tempdb..#tmp_t_adjustment_transaction') IS NOT NULL
	        DROP TABLE #tmp_t_adjustment_transaction
	    
	    SELECT * INTO #tmp_t_adjustment_transaction
	    FROM   t_adjustment_transaction
	    WHERE  0 = 1
	    
	    IF (@data_file_type = 'n')
	    BEGIN
	        SELECT @sql1 = 'bulk insert #tmp_t_adjustment_transaction from ''' + 
	               @path + '\t_adjustment_transaction' + '_' + CAST(@interval_id AS VARCHAR(10)) 
	               + 
	               '.txt'' WITH
	      				(
					DATAFILETYPE = ''native'',
		       			CHECK_CONSTRAINTS
	      				)'
	    END
	    
	    IF (@data_file_type = 'c')
	    BEGIN
	        SELECT @sql1 = 'bulk insert #tmp_t_adjustment_transaction from ''' + 
	               @path + '\t_adjustment_transaction' + '_' + CAST(@interval_id AS VARCHAR(10)) 
	               + 
	               '.txt'' WITH
	      					(
						FIELDTERMINATOR = ''\t'',
	       					ROWTERMINATOR = ''\n'',
			       			CHECK_CONSTRAINTS
	      					)'
	    END
	    
	    EXEC (@sql1)
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000021-dearchive operation failed-->error in adjustment bulk insert operation'
	        
	        ROLLBACK TRAN
	        CLOSE c1
	        DEALLOCATE c1
	        RETURN
	    END
	    --------------------------------------------------------------------------------------------------------------
	    --update t_adjustment_transaction to copy data from archive_sess to id_sess if usage is already in t_acc_usage
	    --------------------------------------------------------------------------------------------------------------
	    UPDATE trans
	    SET    id_sess = archive_sess,
	           archive_sess = NULL
	    FROM   #tmp_t_adjustment_transaction trans
	           INNER JOIN t_acc_usage au
	                ON  trans.archive_sess = au.id_sess
	    WHERE  trans.id_sess IS NULL
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000022-dearchive operation failed-->error in update adjustment transaction'
	        
	        ROLLBACK TRAN
	        CLOSE c1
	        DEALLOCATE c1
	        RETURN
	    END
	    ---------------------------------------------------------------------------------------------------------------------------------
	    --This update is to cover the scenario if post bill adjustments are archived before usage and now dearchive before usage interval
	    ----------------------------------------------------------------------------------------------------------------------------------
	    UPDATE trans
	    SET    archive_sess = id_sess,
	           id_sess = NULL
	    FROM   #tmp_t_adjustment_transaction trans
	    WHERE  NOT EXISTS
	           (
	               SELECT 1
	               FROM   t_acc_usage au
	               WHERE  au.id_sess = trans.id_sess
	           )
	           AND trans.archive_sess IS NULL
	               --				and n_adjustmenttype = 1
	           AND id_usage_interval = @interval_id
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000023-dearchive operation failed-->error in update adjustment transaction'
	        
	        ROLLBACK TRAN
	        CLOSE c1
	        DEALLOCATE c1
	        RETURN
	    END
	    
	    INSERT INTO t_adjustment_transaction
	    SELECT *
	    FROM   #tmp_t_adjustment_transaction
	    
	    IF OBJECT_ID('tempdb..#tmp_t_adjustment_transaction') IS NOT NULL
	        DROP TABLE #tmp_t_adjustment_transaction
	        
	    -----------------------------------------------
	    --Insert data into t_aj tables
	    -----------------------------------------------
	    DECLARE c1 CURSOR FAST_FORWARD 
	    FOR
	        SELECT DISTINCT adj_name
	        FROM   t_archive
	        WHERE  id_interval = @interval_id
	               AND tt_end = @maxtime
	               AND adj_name IS NOT NULL
	               AND STATUS = 'A'
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @var1
	    WHILE @@fetch_status = 0
	    BEGIN
	        IF (@data_file_type = 'n')
	        BEGIN
	            SELECT @sql1 = 'bulk insert ' + @dbname + '..' + @var1 + 
	                   ' from ''' + @path + '\' + @var1 + '_' + CAST(@interval_id AS VARCHAR(10)) 
	                   + 
	                   '.txt'' WITH
	      					(
						DATAFILETYPE = ''native'',
		       				CHECK_CONSTRAINTS
	      					)'
	        END
	        
	        IF (@data_file_type = 'c')
	        BEGIN
	            SELECT @sql1 = 'bulk insert ' + @dbname + '..' + @var1 + 
	                   ' from ''' + @path + '\' + @var1 + '_' + CAST(@interval_id AS VARCHAR(10)) 
	                   + 
	                   '.txt'' WITH
	      					(
						FIELDTERMINATOR = ''\t'',
	       					ROWTERMINATOR = ''\n'',
		       				CHECK_CONSTRAINTS
						)'
	        END
	        
	        EXEC (@sql1)
	        IF (@@error <> 0)
	        BEGIN
	            SET @result = 
	                '5000024-dearchive operation failed-->error in bulk insert operation for table ' 
	                + CAST(@var1 AS NVARCHAR(1000))
	            
	            ROLLBACK TRAN
	            CLOSE c1
	            DEALLOCATE c1
	            RETURN
	        END
	        
	        FETCH NEXT FROM c1 INTO @var1
	    END
	    CLOSE c1
	    DEALLOCATE c1
	END
	
	---------------------------------------
	---update t_acc_bucket_map--------------
	---------------------------------------
	
	UPDATE act
	SET    tt_end = DATEADD(s, -1, @vartime)
	FROM   t_acc_bucket_map act
	       INNER JOIN #AccountIDsTable tmp
	            ON  act.id_acc = tmp.id
	WHERE  act.id_usage_interval = @interval_id
	       AND act.status = 'A'
	       AND act.tt_end = @maxtime
	
	IF (@@error <> 0)
	BEGIN
	    SET @result = 
	        '5000025-dearchive operation failed-->error in update t_acc_bucket_map'
	    
	    ROLLBACK TRAN
	    RETURN
	END
	
	INSERT INTO t_acc_bucket_map
	  (
	    id_usage_interval,
	    id_acc,
	    bucket,
	    STATUS,
	    tt_start,
	    tt_end
	  )
	SELECT @interval_id,
	       id,
	       bucket,
	       'D',
	       @vartime,
	       @maxtime
	FROM   #AccountIDsTable
	
	IF (@@error <> 0)
	BEGIN
	    SET @result = 
	        '5000026-dearchive operation failed-->error in insert into t_acc_bucket_map'
	    
	    ROLLBACK TRAN
	    RETURN
	END
	
	--------------------------------------------------------------------------------
	--Update t_archive table to record the fact that interval is no longer archived
	-----------------------------------------------------------------------------------
	IF NOT EXISTS (
	       SELECT 1
	       FROM   t_acc_bucket_map map
	              LEFT OUTER JOIN t_acc_usage au
	                   ON  map.id_acc = au.id_acc
	                   AND map.id_usage_interval = au.id_usage_interval
	       WHERE  map.status = 'A'
	              AND map.id_usage_interval = @interval_id
	              AND tt_end = @maxtime
	   )
	BEGIN

	    UPDATE t_archive
	    SET    tt_end = DATEADD(s, -1, @vartime)
	    WHERE  id_interval = @interval_id
	           AND STATUS = 'A'
	           AND tt_end = @maxtime
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000027-dearchive operation failed-->error in update t_archive'
	        
	        ROLLBACK TRAN
	        RETURN
	    END
	    
	    INSERT INTO t_archive
	    SELECT @interval_id,
	           id_view,
	           NULL,
	           'D',
	           @vartime,
	           @maxtime
	    FROM   t_archive
	    WHERE  id_interval = @interval_id
	           AND STATUS = 'A'
	           AND tt_end = DATEADD(s, -1, @vartime)
	           AND id_view IS NOT NULL
	    UNION ALL
	    SELECT @interval_id,
	           NULL,
	           adj_name,
	           'D',
	           @vartime,
	           @maxtime
	    FROM   t_archive
	    WHERE  id_interval = @interval_id
	           AND STATUS = 'A'
	           AND tt_end = DATEADD(s, -1, @vartime)
	           AND adj_name IS NOT NULL
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000028-dearchive operation failed-->error in insert t_archive'
	        
	        ROLLBACK TRAN
	        RETURN
	    END
	END
	--Following update will be required for post bill adjustments that are already in system when current usage is dearchived
	UPDATE trans
	SET    id_sess = archive_sess,
	       archive_sess = NULL
	FROM   t_adjustment_transaction trans
	       INNER JOIN t_acc_usage au
	            ON  trans.archive_sess = au.id_sess
	WHERE  trans.id_sess IS NULL
	
	IF (@@error <> 0)
	BEGIN
	    SET @result = 
	        '5000029-dearchive operation failed-->error in update adjustment transaction'
	    
	    ROLLBACK TRAN
	    RETURN
	END
	-------------------------------------------------------------------------------------------------
	--If all the intervals of the partition are dearchived then update the t_archive_partition table
	----------------------------------------------------------------------------------------------------
	
	SELECT @partition = partition_name
	FROM   t_partition part
	       INNER JOIN t_partition_interval_map map
	            ON  part.id_partition = map.id_partition
	WHERE  map.id_interval = @interval_id
	
	IF EXISTS (
	       SELECT 1
	       FROM   t_partition part
	              INNER JOIN t_partition_interval_map map
	                   ON  part.id_partition = map.id_partition
	                   AND part.partition_name = @partition
	              INNER JOIN t_archive_partition back
	                   ON  part.partition_name = back.partition_name
	                   AND back.status = 'A'
	                   AND tt_end = @maxtime
	                   AND map.id_interval NOT IN (SELECT id_interval
	                                               FROM   t_archive
	                                               WHERE  STATUS <> 'D'
	                                                      AND tt_end = @maxtime)
	   )
	BEGIN
	    UPDATE t_archive_partition
	    SET    tt_end = DATEADD(s, -1, @vartime)
	    WHERE  partition_name = @partition
	           AND tt_end = @maxtime
	           AND STATUS = 'A'
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000030-archive operation failed-->Error in update t_archive_partition table'
	        
	        ROLLBACK TRAN
	        RETURN
	    END
	    
	    INSERT INTO t_archive_partition
	    VALUES
	      (
	        @partition,
	        'D',
	        @vartime,
	        @maxtime
	      )
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000031-archive operation failed-->Error in insert into t_archive_partition table'
	        
	        ROLLBACK TRAN
	        RETURN
	    END
	    
	    UPDATE t_partition
	    SET    b_active = 'Y'
	    WHERE  partition_name = @partition
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = 
	            '5000032-archive operation failed-->Error in update t_partition table'
	        
	        ROLLBACK TRAN
	        RETURN
	    END
	END
	------------------------------------------------------------------------------------------------------------
	
	SET @result = '0-dearchive operation successful'
	COMMIT TRAN

    