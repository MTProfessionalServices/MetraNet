 
CREATE PROCEDURE archive_delete
(
    @partition_name  NVARCHAR(30) = NULL,
    @interval_id     INT = NULL,
    @result          NVARCHAR(4000) OUTPUT
)
AS
	/*
	How to run this stored procedure
	declare @result nvarchar(2000)
	exec archive_delete @partition_name='N_20040701_20040731',@result=@result output
	print @result
	or
	declare @result nvarchar(2000)
	exec archive_delete @interval_id=827719717,@result=@result output
	print @result
	*/
	SET NOCOUNT ON
	DECLARE @sql1 NVARCHAR(4000)
	DECLARE @tab1 NVARCHAR(1000)
	DECLARE @var1 NVARCHAR(1000)
	DECLARE @vartime DATETIME
	DECLARE @maxtime DATETIME		
	DECLARE @servername NVARCHAR(100)
	DECLARE @dbname NVARCHAR(100)
	DECLARE @interval INT
	DECLARE @partition1 NVARCHAR(4000)
	DECLARE @min_id_sess INT
	DECLARE @max_id_sess INT
	DECLARE @ParmDefinition NVARCHAR(500)
	
	SELECT @servername = @@servername
	SELECT @dbname = DB_NAME()
	SELECT @vartime = GETDATE()
	SELECT @maxtime = dbo.mtmaxdate()
	
	--Checking the following Business rules
	
	--Either partition or Interval should be specified
	IF ((@partition_name IS NOT NULL AND @interval_id IS NOT NULL)
	       OR (@partition_name IS NULL AND @interval_id IS NULL))
	BEGIN
	    SET @result = '2000001-archive_delete operation failed-->Either Partition or Interval should be specified'
	    RETURN
	END
	
	--Get the list of intervals that need to be archived
	IF (@partition_name IS NOT NULL)
	BEGIN
	    IF ((SELECT COUNT(id_interval)
	               FROM   t_partition_interval_map map
	               WHERE  id_partition
	                      IN (SELECT id_partition
	                          FROM   t_partition
	                          WHERE  partition_name = @partition_name)) <= 0)
	    BEGIN
	        SET @result = '2000002-archive_delete operation failed-->None of the Intervals in the Partition needs to be archived'
	        RETURN
	    END
	    
	    --Partition should not already by archived
	    IF EXISTS (
	           SELECT *
	           FROM   t_archive_partition
	           WHERE  partition_name = @partition_name
	                  AND STATUS = 'A'
	                  AND tt_end = @maxtime)
	    BEGIN
	        SET @result = '2000003-archive_delete operation failed-->Partition already archived'
	        RETURN
	    END
	    
	    DECLARE interval_id CURSOR FAST_FORWARD 
	    FOR
	        SELECT id_interval
	        FROM   t_partition_interval_map map
	        WHERE  id_partition = (
	                   SELECT id_partition
	                   FROM   t_partition
	                   WHERE  partition_name = @partition_name
	               )
	END
	ELSE
	BEGIN
	    --Check that Interval exists
	    IF NOT EXISTS (SELECT 1
						FROM   t_usage_interval
						WHERE  id_interval = @interval_id)
	    BEGIN
	        SET @result = '2000024-archive_delete operation failed-->Interval Does not exists'
	        RETURN
	    END
	    --Interval should be hard-closed
	    IF EXISTS (SELECT 1
					FROM   t_usage_interval
					WHERE  id_interval = @interval
						  AND tx_interval_status IN ('O', 'B'))
	    BEGIN
	        SET @result = '2000025-archive operation failed-->Interval is not Hard Closed'	        
	        RETURN
	    END
	    
	    DECLARE interval_id CURSOR FAST_FORWARD 
	    FOR
	        SELECT @interval_id
	    
	    IF (SELECT b_partitioning_enabled
	        FROM   t_usage_server) = 'Y'
	    BEGIN
	        SELECT @partition1 = partition_name
	        FROM   t_partition part
	               INNER JOIN t_partition_interval_map map
	                    ON  part.id_partition = map.id_partition
	                    AND map.id_interval = @interval_id
	    END
	END
	
	OPEN interval_id
	FETCH NEXT FROM interval_id INTO @interval
	WHILE (@@fetch_status = 0)
	BEGIN
	    --Interval should not be already archived
	    IF EXISTS (SELECT TOP 1 * 
					FROM   t_archive
					WHERE  id_interval = @interval
						  AND STATUS = 'A'
						AND tt_end = @maxtime)
	    BEGIN
	        SET @result =  '2000004-archive operation failed-->Interval is already archived'
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    --Interval should exist and in export state
	    IF EXISTS (SELECT 1
				   FROM   t_acc_usage
				   WHERE  id_usage_interval = @interval
						  AND NOT EXISTS (SELECT 1
											FROM   t_archive
											WHERE  id_interval = @interval
													AND STATUS = 'E'
													AND tt_end = @maxtime))
	    BEGIN
	        SET @result = '2000005-archive operation failed-->Interval is not exported..run the archive_export procedure'
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    --Interval should not be already Dearchived
	    IF EXISTS (SELECT TOP 1 * 
				   FROM   t_archive
				   WHERE  id_interval = @interval
						  AND STATUS = 'D'
						  AND tt_end = @maxtime)
	    BEGIN
	        SET @result = '2000006-archive operation failed-->Interval is Dearchived..run the trash procedure'	        
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    
	    FETCH NEXT FROM interval_id INTO @interval
	END
	CLOSE interval_id
	
	
	BEGIN TRAN
	OPEN interval_id
	FETCH NEXT FROM interval_id INTO @interval
	WHILE (@@fetch_status = 0)
	BEGIN
	    IF OBJECT_ID('tempdb..#adjustment') IS NOT NULL
	        DROP TABLE #adjustment
	    
	    CREATE TABLE #adjustment
	    (
	    	NAME NVARCHAR(2000)
	    )
	    DECLARE c2 CURSOR FAST_FORWARD 
	    FOR
	        SELECT table_name
	        FROM   information_schema.tables
	        WHERE  table_name LIKE 't_aj_%'
	               AND table_name NOT IN ('T_AJ_TEMPLATE_REASON_CODE_MAP', 't_aj_type_applic_map')
	    
	    OPEN c2
	    FETCH NEXT FROM c2 INTO @var1
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        --Get the name of t_aj tables that have usage in this interval
	        SET @sql1 = N'if exists
 					(select 1 from ' + @var1 + 
	            ' where id_adjustment in
 					(select id_adj_trx from t_adjustment_transaction where id_usage_interval = ' 
	            + CAST(@interval AS VARCHAR(10)) + 
	            N'))
 					insert into #adjustment values(''' + @var1 + ''')'
	        
	        EXEC sp_executesql @sql1
	        SET @sql1 = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
	        
	        EXEC sp_executesql @sql1
	        FETCH NEXT FROM c2 INTO @var1
	    END
	    CLOSE c2
	    DEALLOCATE c2
	    
	    IF OBJECT_ID('tempdb..tmp_t_adjustment_transaction') IS NOT NULL
	        DROP TABLE tempdb..tmp_t_adjustment_transaction
	    
	    SELECT @sql1 = 
	           N'SELECT id_adj_trx into tempdb..tmp_t_adjustment_transaction FROM ' 
	           + @dbname + '..t_adjustment_transaction where id_usage_interval=' 
	           + CAST(@interval AS VARCHAR(10)) + N' order by id_sess'
	    
	    EXEC (@sql1)
	    CREATE UNIQUE CLUSTERED INDEX idx_tmp_t_adjustment_transaction ON tempdb..tmp_t_adjustment_transaction(id_adj_trx)
	    DECLARE c1 CURSOR FAST_FORWARD 
	    FOR
	        SELECT DISTINCT NAME
	        FROM   #adjustment
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @var1
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        --Delete from t_aj tables
	        SELECT @sql1 = N'delete aj FROM ' + @dbname + '..' + @var1 + 
	               ' aj inner join
 				tempdb..tmp_t_adjustment_transaction tmp on aj.id_adjustment = tmp.id_adj_trx'
	        
	        EXEC (@sql1)
	        IF (@@error <> 0)
	        BEGIN
	            SET @result = '2000007-archive operation failed-->Error in t_aj tables Delete operation'	            
	            ROLLBACK TRAN
	            CLOSE c1
	            DEALLOCATE c1
	            CLOSE interval_id
	            DEALLOCATE interval_id
	            RETURN
	        END
	        
	        FETCH NEXT FROM c1 INTO @var1
	    END
	    CLOSE c1
	    DEALLOCATE c1
	    
	    --Delete from t_adjustment_transaction table
	    SELECT @sql1 = N'delete FROM ' + @dbname + 
	           '..t_adjustment_transaction where id_usage_interval=' + CAST(@interval AS VARCHAR(10))
	    
	    EXEC (@sql1)
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000008-Error in Delete from t_adjustment_transaction table'
	        ROLLBACK TRAN
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    
	    COMMIT TRAN
	    --Delete from Unique constraints table
	    IF (SELECT b_partitioning_enabled
	        FROM   t_usage_server) = 'Y'
	    BEGIN
	        DECLARE c3 CURSOR FAST_FORWARD 
	        FOR
	            SELECT nm_table_name
	            FROM   t_unique_cons
	        
	        OPEN c3
	        FETCH NEXT FROM c3 INTO @tab1
	        WHILE (@@fetch_status = 0)
	        BEGIN
	            SELECT @sql1 = N'select @min_id_sess = min(id_sess) FROM ' + @dbname 
	                   + '..' + @tab1 + ' where id_usage_interval=' + CAST(@interval AS VARCHAR(10))
	            
	            SET @ParmDefinition = N' @min_id_sess varchar(30) OUTPUT';
	            EXEC sp_executesql @sql1,
	                 @ParmDefinition,
	                 @min_id_sess = @min_id_sess OUTPUT
	            
	            SELECT @sql1 = N'select @max_id_sess = max(id_sess) FROM ' + @dbname 
	                   + '..' + @tab1 + ' where id_usage_interval=' + CAST(@interval AS VARCHAR(10))
	            
	            SET @ParmDefinition = N' @max_id_sess varchar(30) OUTPUT'
	            EXEC sp_executesql @sql1,
	                 @ParmDefinition,
	                 @max_id_sess = @max_id_sess OUTPUT
	            
	            WHILE (@min_id_sess < @max_id_sess)
	            BEGIN
	                BEGIN TRAN
	                SELECT @sql1 = N'delete FROM ' + @dbname + '..' + @tab1 + 
	                       ' where id_usage_interval=' + CAST(@interval AS VARCHAR(10)) 
	                       +
	                       ' and id_sess between ' + CAST(@min_id_sess AS VARCHAR(10)) 
	                       + ' and ' + CAST(@min_id_sess AS VARCHAR(10)) + 
	                       ' + 1000000'
	                
	                EXEC (@sql1)
	                IF (@@error <> 0)
	                BEGIN
	                    SET @result = '2000024-Error in Delete from unique constraint table'	                    
	                    ROLLBACK TRAN
	                    CLOSE c3
	                    DEALLOCATE c3
	                    CLOSE interval_id
	                    DEALLOCATE interval_id
	                    RETURN
	                END
	                
	                COMMIT TRAN
	                SET @min_id_sess = @min_id_sess + 1000001
	            END
	            FETCH NEXT FROM c3 INTO @tab1
	        END
	        CLOSE c3
	        DEALLOCATE c3
	    END
	    
	    BEGIN TRAN
	    --Checking for post bill adjustments that have corresponding usage archived
	    IF OBJECT_ID('tempdb..#t_adjustment_transaction_temp') IS NOT NULL
	        DROP TABLE #t_adjustment_transaction_temp
	    
	    CREATE TABLE #t_adjustment_transaction_temp
	    (
	    	id_sess BIGINT
	    )
	    SELECT @sql1 = N'insert into #t_adjustment_transaction_temp select id_sess
 						from t_adjustment_transaction where n_adjustmenttype=1
 						and id_sess in (select id_sess from t_acc_usage where id_usage_interval=' 
						+ CAST(@interval AS VARCHAR(10)) + ' )'
	    
	    EXECUTE (@sql1)
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000009-archive operation failed-->Error in create adjustment temp table operation'	        
	        ROLLBACK TRAN
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    
	    IF ((SELECT COUNT(*)
	         FROM   #t_adjustment_transaction_temp) > 0)
	    BEGIN
	        UPDATE t_adjustment_transaction
	        SET    archive_sess = id_sess,
	               id_sess = NULL
	        WHERE  id_sess IN (SELECT id_sess
	                           FROM   #t_adjustment_transaction_temp)
	        
	        IF (@@error <> 0)
	        BEGIN
	            SET @result = '2000010-archive operation failed-->Error in Update adjustment operation'	            
	            ROLLBACK TRAN
	            CLOSE interval_id
	            DEALLOCATE interval_id
	            RETURN
	        END
	    END
	    
	    UPDATE t_acc_bucket_map
	    SET    tt_end = DATEADD(s, -1, @vartime)
	    WHERE  id_usage_interval = @interval
	           AND STATUS = 'E'
	           AND tt_end = @maxtime
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000011-archive operation failed-->Error in update t_acc_bucket_map table'
	        ROLLBACK TRAN
	        CLOSE interval_id
	        DEALLOCATE interval_id
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
	    SELECT @interval,
	           id_acc,
	           bucket,
	           'A',
	           @vartime,
	           @maxtime
	    FROM   t_acc_bucket_map
	    WHERE  id_usage_interval = @interval
	           AND STATUS = 'E'
	           AND tt_end = DATEADD(s, -1, @vartime)
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000012-archive operation failed-->Error in insert into t_acc_bucket_map table'	        
	        ROLLBACK TRAN
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    
	    UPDATE t_archive
	    SET    tt_end = DATEADD(s, -1, @vartime)
	    WHERE  id_interval = @interval
	           AND STATUS = 'E'
	           AND tt_end = @maxtime
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000013-archive operation failed-->Error in update t_archive table'	        
	        ROLLBACK TRAN
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    
	    INSERT INTO t_archive
	    SELECT id_interval,
	           id_view,
	           adj_name,
	           'A',
	           @vartime,
	           @maxtime
	    FROM   t_archive
	    WHERE  id_interval = @interval
	           AND STATUS = 'E'
	           AND tt_end = DATEADD(s, -1, @vartime)
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000014-archive operation failed-->Error in insert t_archive table'	        
	        ROLLBACK TRAN
	        CLOSE interval_id
	        DEALLOCATE interval_id
	        RETURN
	    END
	    
	    FETCH NEXT FROM interval_id INTO @interval
	END
	CLOSE interval_id
	DEALLOCATE interval_id
	
	IF (@partition_name IS NULL)
	BEGIN
	    IF ((SELECT COUNT(*)
			   FROM   t_partition_interval_map map
			   WHERE  id_partition = (
						  SELECT id_partition
						  FROM   t_partition_interval_map
						  WHERE  id_interval = @interval_id)) <= 1)
	       AND (SELECT b_partitioning_enabled 
	            FROM   t_usage_server) = 'Y'
	    BEGIN
	        SELECT @partition_name = partition_name
	        FROM   t_partition part
	               INNER JOIN t_partition_interval_map map
	                    ON  part.id_partition = map.id_partition
	        WHERE  map.id_interval = @interval_id
	        
	        SET @interval_id = NULL
	    END
	END
	
	IF (@partition_name IS NOT NULL)
	BEGIN	   
	    EXEC arch_delete_usage_data_by_partition_name
	         @partition_name = @partition_name,
	         @result = @result
	    
	    IF (@result IS NOT NULL)
	    BEGIN
	        ROLLBACK TRAN
	        RETURN
	    END
	END
	
	IF (@interval_id IS NOT NULL)
	BEGIN
	    IF OBJECT_ID('tempdb..##id_view') IS NOT NULL
	        DROP TABLE ##id_view
	    
	    SELECT @sql1 = ' select distinct id_view into ##id_view from t_acc_usage  where id_usage_interval = ' 
						+ CAST(@interval_id AS NVARCHAR(100))
	    
	    EXEC (@sql1)
	    DECLARE c1 CURSOR FAST_FORWARD 
	    FOR
	        SELECT id_view
	        FROM   ##id_view
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @var1
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        SELECT @tab1 = nm_table_name
	        FROM   t_prod_view
	        WHERE  id_view = @var1 --and nm_table_name not like '%temp%'
	                               --Delete from product view tables
	        SELECT @sql1 = N'delete pv FROM ' + @tab1 + 
	               ' pv inner join t_acc_usage tmp on
				pv.id_sess = tmp.id_sess and pv.id_usage_interval=tmp.id_usage_interval
				and tmp.id_usage_interval = ' + CAST(@interval_id AS NVARCHAR(100))
	        
	        EXEC (@sql1)
	        IF (@@error <> 0)
	        BEGIN
	            SET @result = '2000017-archive operation failed-->Error in product view Delete operation'	            
	            ROLLBACK TRAN
	            CLOSE c1
	            DEALLOCATE c1
	            RETURN
	        END
	        
	        FETCH NEXT FROM c1 INTO @var1
	    END
	    CLOSE c1
	    DEALLOCATE c1
	    --Delete from t_acc_usage table
	    SELECT @sql1 = N'delete au from t_acc_usage au
						where au.id_usage_interval = ' + CAST(@interval_id AS NVARCHAR(100))
	    
	    EXEC (@sql1)
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000018-archive operation failed-->Error in Delete t_acc_usage operation'	        
	        ROLLBACK TRAN
	        RETURN
	    END
	END
	
	IF (((@partition_name IS NOT NULL)
	      OR NOT EXISTS (SELECT 1
						  FROM   t_partition_interval_map map
								 LEFT OUTER JOIN t_archive inte
									  ON  inte.id_interval = map.id_interval
									  AND tt_end = @maxtime
						  WHERE  map.id_partition = (
									 SELECT id_partition
									 FROM   t_partition_interval_map
									 WHERE  id_interval = @interval_id)
	                         AND (STATUS IS NULL OR STATUS <> 'A')))
	       AND (SELECT b_partitioning_enabled
	               FROM   t_usage_server) = 'Y')
	BEGIN
	    UPDATE t_archive_partition
	    SET    tt_end = DATEADD(s, -1, @vartime)
	    WHERE  partition_name = ISNULL(@partition_name, @partition1)
	           AND tt_end = @maxtime
	           AND STATUS = 'E'
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000021-archive operation failed-->Error in update t_archive_partition table'	        
	        ROLLBACK TRAN
	        RETURN
	    END
	    
	    INSERT INTO t_archive_partition
	    VALUES
	      (
	        ISNULL(@partition_name, @partition1),
	        'A',
	        @vartime,
	        @maxtime
	      )
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000022-archive operation failed-->Error in insert into t_archive_partition table'	        
	        ROLLBACK TRAN
	        RETURN
	    END
	    
	    UPDATE t_partition
	    SET    b_active = 'N'
	    WHERE  partition_name = ISNULL(@partition_name, @partition1)
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000023-archive operation failed-->Error in update t_partition table'	        
	        ROLLBACK TRAN
	        RETURN
	    END
	END
	
	IF (@partition_name IS NOT NULL)
	BEGIN	   
	    EXEC arch_delete_temp_tables
	         @result = @result
	    
	    IF (@result IS NOT NULL)
	    BEGIN
	        ROLLBACK TRAN
	        RETURN
	    END
	END
	
	IF OBJECT_ID('tempdb..tmp_t_adjustment_transaction') IS NOT NULL
	    DROP TABLE tempdb..tmp_t_adjustment_transaction
	
	IF OBJECT_ID('tempdb..##id_view') IS NOT NULL
	    DROP TABLE ##id_view
	
	SET @result = '0-archive_delete operation successful'
	COMMIT TRAN