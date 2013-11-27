
 CREATE PROCEDURE archive_trash
 (
			@partition_name NVARCHAR(30) = NULL,
			@interval_id INT = NULL,
			@account_id_list NVARCHAR(4000),
			@result NVARCHAR(4000) output
)
		AS
/*		How to run this stored procedure
		DECLARE @result NVARCHAR(2000)
		EXEC archive_trash @partition_name='N_20040701_20040731',@account_id_list=null,@result=@result output
		print @result
		OR
		DECLARE @result NVARCHAR(2000)
		EXEC archive_trash @interval_id=827719717,@account_id_list=null,@result=@result output
		print @result
*/
		SET NOCOUNT ON
		DECLARE @sqlstmt NVARCHAR(4000)
		DECLARE @table NVARCHAR(1000)
		DECLARE @var NVARCHAR(1000)
		DECLARE @vartime datetime
		DECLARE @maxtime datetime
		DECLARE	@dbname NVARCHAR(100)
		DECLARE	@servername NVARCHAR(100)
		DECLARE @partname NVARCHAR(30)
		DECLARE @interval INT

--get the server AND the database name
		SELECT @servername = @@servername
		SELECT @dbname = db_name()
		SELECT @vartime = getdate()
		SELECT @maxtime = dbo.mtmaxdate()

		--Either Partition OR IntervalId/AccountId can be specified
		IF ((@partition_name IS NOT NULL AND @interval_id IS NOT NULL) 
			OR (@partition_name IS NULL AND @interval_id IS NULL)
				OR (@partition_name IS NOT NULL AND @account_id_list IS NOT NULL))
		BEGIN
			SET @result = '3000001-archive_trash operation failed-->Either Partition OR Interval/AccountId should be specified'
			RETURN
		END
         
		IF (@partition_name IS NOT NULL)
		BEGIN
			--Checking the following Business rules
			--partition should be already archived OR Dearchived
			IF  NOT EXISTS (SELECT 1 FROM t_archive_partition 
										WHERE partition_name = @partition_name 
											AND [status] IN ('A','D') AND tt_end = @maxtime)
			BEGIN
				SET @result = '3000002-trash operation failed-->partition is not already archived/dearchived'
				RETURN
			END

			--partition should have atleast 1 Interval that is dearchived
			IF  NOT EXISTS (SELECT 1 FROM t_archive 
										WHERE [status] = 'D' 
											AND tt_end = @maxtime 
												AND id_interval IN(SELECT id_interval FROM t_partition_interval_map map
																		INNER JOIN t_partition part ON map.id_partition = part.id_partition 
																			WHERE part.partition_name= @partition_name))
			BEGIN
				SET @result = '3000002a-trash operation failed-->none of the intervals of partition is dearchived'
				RETURN
			END

		END
		
		BEGIN TRAN
			--IF partition is specified then apply the Truncate operation
			IF (@partition_name IS NOT NULL)
			BEGIN
				------------------------------------------
				--Cursor interval_id by partition intervals
				-------------------------------------------
				DECLARE interval_id CURSOR FAST_FORWARD FOR SELECT id_interval FROM t_partition_interval_map map 
																	WHERE id_partition IN(SELECT id_partition  FROM t_partition 
																								WHERE partition_name = @partition_name)
				OPEN interval_id
				FETCH NEXT FROM interval_id INTO @interval
				WHILE (@@fetch_status = 0)
				BEGIN
					---------------------------------
					----archive trash for adjustment tables
					---------------------------------
					IF object_id('tempdb..#adjustment') IS NOT NULL
					DROP TABLE #adjustment
					
					CREATE TABLE #adjustment(name NVARCHAR(2000))
					
					DECLARE cursor_adjustment_tables CURSOR FAST_FORWARD FOR SELECT table_name FROM information_schema.tables 
					                                                         WHERE table_name like 't_aj_%' 
																				AND table_name not in ('T_AJ_TEMPLATE_REASON_CODE_MAP','t_aj_type_applic_map')
					OPEN cursor_adjustment_tables
					FETCH NEXT FROM cursor_adjustment_tables INTO @var
					WHILE (@@fetch_status = 0)
					BEGIN
					--Get the name of t_aj tables that have usage in this interval
						SET @sqlstmt = N'IF EXISTS (SELECT 1 FROM ' + @var + ' WHERE id_adjustment in
														(SELECT id_adj_trx FROM t_adjustment_transaction WHERE id_usage_interval = ' 
														 + cast(@interval as varchar(10)) + N'))
																INSERT INTO #adjustment values(''' + @var + ''')'
						EXEC sp_executesql @sqlstmt
						
						SET @sqlstmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP VIEW bcpview'
						EXEC sp_executesql @sqlstmt
					
					FETCH NEXT FROM cursor_adjustment_tables INTO @var
					END
					CLOSE cursor_adjustment_tables
					DEALLOCATE cursor_adjustment_tables
					
					---------------------------------------
					------archive_trash product view tables and t_acc_usage
					---------------------------------------

					EXEC arch_delete_usage_data_by_partition_name
						 @partition_name = @partition_name,
						 @result = @result
				    
					IF (@result IS NOT NULL)
					BEGIN
						ROLLBACK TRAN
						RETURN
					END
					
					-----------------------------------------------------
					---archive_trash adjustment transactions
					-----------------------------------------------------
					
					IF object_id('tempdb..tmp_t_adjustment_transaction') IS NOT NULL
					DROP TABLE tempdb..tmp_t_adjustment_transaction
					
					SELECT @sqlstmt = N'SELECT id_adj_trx INTO tempdb..tmp_t_adjustment_transaction FROM ' 
														+ @dbname + '..t_adjustment_transaction WHERE id_usage_interval=' 
																+ cast (@interval as VARCHAR(10)) + N' order by id_sess'
					EXEC (@sqlstmt)
					
					CREATE UNIQUE CLUSTERED INDEX idx_tmp_t_adjustment_transaction ON tempdb..tmp_t_adjustment_transaction(id_adj_trx)
					
					DECLARE  cursor_adjustment_transaction CURSOR FAST_FORWARD FOR SELECT distinct name FROM #adjustment
					OPEN cursor_adjustment_transaction
					FETCH NEXT FROM cursor_adjustment_transaction INTO @var
					WHILE (@@fetch_status = 0)
					BEGIN
						--Delete FROM t_aj tables
						SELECT @sqlstmt = N'delete aj FROM ' + @dbname + '..' + @var +  ' aj INNER JOIN
						tempdb..tmp_t_adjustment_transaction tmp on aj.id_adjustment = tmp.id_adj_trx'
						EXEC (@sqlstmt)
						
						IF (@@error <> 0)
						BEGIN
							SET @result = '3000004-archive operation failed-->Error in t_aj tables Delete operation'
							ROLLBACK TRAN
							CLOSE cursor_adjustment_transaction
							DEALLOCATE cursor_adjustment_transaction
							RETURN
						END
					FETCH NEXT FROM c1 INTO @var
					END
					CLOSE cursor_adjustment_transaction
					DEALLOCATE cursor_adjustment_transaction

					--Delete FROM t_adjustment_transaction table
					SELECT @sqlstmt = N'delete FROM ' + @dbname + '..t_adjustment_transaction WHERE id_usage_interval=' 
																			+ cast (@interval AS VARCHAR(10))
					EXEC (@sqlstmt)
					
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000005-Error in Delete FROM t_adjustment_transaction table'
						ROLLBACK TRAN
						RETURN
					END

					--Checking for post bill adjustments that have corresponding usage archived
					IF object_id('tempdb..#t_adjustment_transaction_temp') IS NOT NULL
					DROP TABLE #t_adjustment_transaction_temp
					
					CREATE TABLE #t_adjustment_transaction_temp(id_sess bigint)
					
					SELECT @sqlstmt =  N'INSERT INTO #t_adjustment_transaction_temp SELECT id_sess
													FROM t_adjustment_transaction WHERE n_adjustmenttype=1
																AND id_sess in (SELECT id_sess FROM t_acc_usage WHERE id_usage_interval=' 
																				+ cast(@interval AS VARCHAR(10)) + ' )'
					EXEC (@sqlstmt)
					
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000006-archive operation failed-->Error in create adjustment temp table operation'
						ROLLBACK TRAN
						RETURN
					END
					
					IF ((SELECT count(*) FROM #t_adjustment_transaction_temp) > 0)
					BEGIN
						UPDATE t_adjustment_transaction SET archive_sess=id_sess,id_sess = null
								WHERE id_sess in (SELECT id_sess FROM #t_adjustment_transaction_temp)
								
						IF (@@error <> 0)
						BEGIN
							SET @result = '3000007-archive operation failed-->Error in Update adjustment operation'
							ROLLBACK TRAN
							RETURN
						END
					END
					
					----------------------------------------------------
					-----Update t_archive table 
					----------------------------------------------------

					UPDATE t_archive
					SET tt_end = dateadd(s,-1,@vartime)
						WHERE id_interval=@interval
							AND status='D'
								AND tt_end=@maxtime
								
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000009-archive operation failed-->Error in update t_archive table'
						ROLLBACK TRAN
						RETURN
					END
					
					INSERT INTO t_archive
						SELECT id_interval,id_view,adj_name,'A',@vartime,@maxtime FROM t_archive
							WHERE id_interval = @interval
									AND status ='D'
										AND tt_end=dateadd(s,-1,@vartime)
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000010-archive operation failed-->Error in insert t_archive table'
						ROLLBACK TRAN
						RETURN
					END
					
					------------------------------------------------------
					------Update t_acc_bucket_map
					------------------------------------------------------
					UPDATE t_acc_bucket_map
					SET tt_end = dateadd(s,-1,@vartime)
						WHERE id_usage_interval=@interval
							AND [status] = 'D'
								AND tt_end= @maxtime
								
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000011-archive operation failed-->Error in update t_acc_bucket_map table'
						ROLLBACK TRAN
						RETURN
					END
					
					INSERT INTO t_acc_bucket_map SELECT @interval,id_acc,bucket,'A',@vartime,@maxtime FROM t_acc_bucket_map
							WHERE id_usage_interval=@interval
								AND [status] ='D'
									AND tt_end=dateadd(s,-1,@vartime)
									
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000012-archive operation failed-->Error in insert INTO t_acc_bucket_map table'
						ROLLBACK TRAN
						RETURN
					END
				FETCH NEXT FROM interval_id INTO @interval
				END
				CLOSE interval_id
				DEALLOCATE interval_id
				
				----------------------------------------------------------
				------Update t_archive_partition
				----------------------------------------------------------

				UPDATE t_archive_partition
				SET tt_end = dateadd(s,-1,@vartime)
					WHERE partition_name = @partition_name
						AND tt_end= @maxtime
							AND status = 'D'
							
				IF (@@error <> 0)
				BEGIN
					SET @result = '3000012a-archive operation failed-->Error in update t_archive_partition table'
					ROLLBACK TRAN
					RETURN
				END
				
				INSERT INTO t_archive_partition VALUES(@partition_name,'A',@vartime,@maxtime)
				
				IF (@@error <> 0)
				BEGIN
					SET @result = '3000012b-archive operation failed-->Error in insert INTO t_archive_partition table'
					rollback tran
					RETURN
				END
				
				-------------------------------------------------------------
				-----Update t_partition table
				-------------------------------------------------------------
				UPDATE t_partition SET b_active = 'N' WHERE partition_name = @partition_name
				
				IF (@@error <> 0)
				BEGIN
					SET @result = '3000012c-archive operation failed-->Error in update t_partition table'
					ROLLBACK TRAN
					RETURN
				END
				
				-- drop temp tables
				IF object_id('tempdb..tmp_t_adjustment_transaction') IS NOT NULL
				DROP TABLE tempdb..tmp_t_adjustment_transaction
				IF object_id('tempdb..#adjustment') IS NOT NULL
				DROP TABLE #adjustment
				IF object_id('tempdb..##id_view') IS NOT NULL
				DROP TABLE ##id_view
			END
			
			
			--IF IntervalId is specified then apply the Delete operation
			IF (@interval_id IS NOT NULL)
			BEGIN
				--Checking the following Business rules
				--Interval should be already archived
				IF  NOT EXISTS (SELECT top 1 * FROM t_archive 
									WHERE id_interval=@interval_id 
										AND status  in ('A','D') 
											AND tt_end = @maxtime)
				BEGIN
					SET @result = '3000013-trash operation failed-->Interval is not already archived/dearchived'
					ROLLBACK TRAN
					RETURN
				END
				
				--check input account list
				CREATE TABLE #AccountIDsTable (ID INT NOT NULL)
				
				IF (@account_id_list IS NOT NULL)
				BEGIN
					WHILE CHARINDEX(',', @account_id_list) > 0
						BEGIN
							INSERT INTO #AccountIDsTable (ID)
							SELECT SUBSTRING(@account_id_list,1,(CHARINDEX(',', @account_id_list)-1))
							SET @account_id_list = SUBSTRING (@account_id_list, (CHARINDEX(',', @account_id_list)+1),
												(LEN(@account_id_list) - (CHARINDEX(',', @account_id_list))))
						END
					INSERT INTO #AccountIDsTable (ID) SELECT @account_id_list
				END
				ELSE
				BEGIN
					SET @sqlstmt = 'INSERT INTO #AccountIDsTable SELECT distinct id_acc FROM t_acc_usage WHERE id_usage_interval = ' + cast(@interval_id AS VARCHAR(20))
					EXEC (@sqlstmt)
				END
				
				--check account in the list is already dearchived
				IF  NOT EXISTS (SELECT top 1 id_acc FROM t_acc_bucket_map WHERE id_usage_interval=@interval_id AND status ='D' AND tt_end = @maxtime)
				BEGIN
					SET @result = '3000014-trash operation failed-->account in the list is not dearchived'
					ROLLBACK TRAN
					RETURN
				END
				
				

				IF object_id('tempdb..tmp_t_acc_usage') IS NOT NULL
				DROP TABLE tempdb..tmp_t_acc_usage
				
				IF object_id('tempdb..tmp_t_adjustment_transaction') IS NOT NULL
				DROP TABLE tempdb..tmp_t_adjustment_transaction
				
				SELECT @sqlstmt = N'SELECT id_sess,id_acc INTO tempdb..tmp_t_acc_usage FROM ' +
									@dbname + '..t_acc_usage WHERE id_usage_interval=' + cast (@interval_id as varchar(10)) +
										' AND id_acc in (SELECT id FROM #AccountIDsTable)'
				EXEC (@sqlstmt)
				
				CREATE UNIQUE CLUSTERED INDEX idx_tmp_t_acc_usage ON tempdb..tmp_t_acc_usage(id_sess)
				CREATE INDEX idx1_tmp_t_acc_usage ON tempdb..tmp_t_acc_usage(id_acc)
				
				----------------------------------
				----archive_trash for product views for interval
				----------------------------------

				DECLARE  cursor_product_view CURSOR FAST_FORWARD FOR SELECT distinct id_view FROM t_acc_usage
				WHERE id_usage_interval = @interval_id
					OPEN cursor_product_view
					FETCH NEXT FROM cursor_product_view INTO @var
					WHILE (@@fetch_status = 0)
					BEGIN
						SELECT @table = nm_table_name FROM t_prod_view WHERE id_view = @var --AND nm_table_name not like '%temp%'
						--Delete FROM product view tables
						SELECT @sqlstmt = N'delete pv FROM ' + @dbname + '..' + @table + ' pv INNER JOIN
												tempdb..tmp_t_acc_usage tmp on pv.id_sess = tmp.id_sess'
						EXEC (@sqlstmt)
						
						IF (@@error <> 0)
						BEGIN
							SET @result = '3000015-trash operation failed-->Error in Delete operation'
							ROLLBACK TRAN
							CLOSE ccursor_product_view
							DEALLOCATE cursor_product_view
							RETURN
						END
					FETCH NEXT FROM cursor_product_view INTO @var
					END
					CLOSE cursor_product_view
					DEALLOCATE cursor_product_view
					

				IF NOT EXISTS (SELECT 1 FROM t_acc_usage WHERE id_usage_interval = @interval_id AND id_acc NOT IN
																		(SELECT id FROM #AccountIDsTable))
				BEGIN
					-----------------------------
					-----archive_trash adjustmnet tables for interval
					-----------------------------
					IF object_id('tempdb..##id_view1') IS NOT NULL
					DROP TABLE ##id_view1
					
					SELECT DISTINCT id_view INTO ##id_view1 FROM t_acc_usage WHERE id_usage_interval = @interval_id
					
					SELECT @sqlstmt = N'SELECT id_adj_trx INTO tempdb..tmp_t_adjustment_transaction FROM '
					+ @dbname + '..t_adjustment_transaction WHERE id_usage_interval=' + cast(@interval_id AS VARCHAR(10))
					EXEC (@sqlstmt)
					
					CREATE UNIQUE CLUSTERED INDEX idx_tmp_t_adjustment_transaction ON
								tempdb..tmp_t_adjustment_transaction(id_adj_trx)
					CREATE TABLE  #adjustment1(name NVARCHAR(2000))
					
					DECLARE cursor_adjustment_table CURSOR FAST_FORWARD FOR SELECT table_name FROM information_schema.tables 
					                                   WHERE table_name like 't_aj_%' AND table_name not in ('T_AJ_TEMPLATE_REASON_CODE_MAP','t_aj_type_applic_map')
					OPEN cursor_adjustment_table
					FETCH NEXT FROM cursor_adjustment_table INTO @var
					WHILE (@@fetch_status = 0)
					BEGIN
						--Get the name of t_aj tables that have usage in this interval
						SET @sqlstmt = N'IF exists
								(SELECT 1 FROM ' + @var + ' WHERE id_adjustment in
								(SELECT id_adj_trx FROM t_adjustment_transaction WHERE id_usage_interval = ' + cast(@interval_id as varchar(10)) + N'))
								insert INTO #adjustment1 values(''' + @var + ''')'
						EXEC (@SQLStmt)
						
						SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP VIEW bcpview'
						EXEC (@SQLStmt)
					
					FETCH NEXT FROM cursor_adjustment_table INTO @var
					END
					CLOSE cursor_adjustment_table
					DEALLOCATE cursor_adjustment_table

					DECLARE  cursor_adjustment CURSOR FAST_FORWARD FOR SELECT distinct name FROM #adjustment1
					OPEN cursor_adjustment
					FETCH NEXT FROM cursor_adjustment INTO @var
					WHILE (@@fetch_status = 0)
					BEGIN
					--Delete FROM t_aj tables
						SELECT @sqlstmt = N'delete aj FROM ' + @dbname + '..' + @var +
								' aj INNER JOIN tempdb..tmp_t_adjustment_transaction tmp
								on aj.id_adjustment = tmp.id_adj_trx'
						EXEC (@sqlstmt)
						
						IF (@@error <> 0)
						BEGIN
							SET @result = '3000016-trash operation failed-->Error in Delete FROM t_aj tables'
							ROLLBACK TRAN
							CLOSE cursor_adjustment
							DEALLOCATE cursor_adjustment
							RETURN
						END
					FETCH NEXT FROM cursor_adjustment INTO @var
					END
					CLOSE cursor_adjustment
					DEALLOCATE cursor_adjustment

					--Delete FROM t_adjustment_transaction table
					SELECT @sqlstmt = N'delete FROM ' + @dbname + '..t_adjustment_transaction WHERE id_usage_interval=' + cast (@interval_id as varchar(10))
					EXEC (@sqlstmt)
					
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000017-Error in Delete FROM t_adjustment_transaction table'
						ROLLBACK TRAN
						RETURN
					END
					
					-----------------------------------------------------------------------
					--Checking for post bill adjustments that have corresponding usage archived
					--Update t_archive table
					-----------------------------------------------------------------------------
					
					UPDATE t_archive
					SET    tt_end       = DATEADD(s, -1, @vartime)
					WHERE  id_interval  = @interval_id
					       AND STATUS   = 'D'
					       AND tt_end   = @maxtime
					       
					IF (@@error <> 0)
					BEGIN
					    SET @result = '3000020-trash operation failed-->error in update t_acc_bucket_map'
					    
					    ROLLBACK TRAN
					    RETURN
					END
					
					INSERT INTO t_archive
					SELECT @interval_id,
					       id_view,
					       NULL,
					       'A',
					       @vartime,
					       @maxtime
					FROM   ##id_view1
					UNION ALL
					SELECT DISTINCT @interval_id,
					       NULL,
					       NAME,
					       'A',
					       @vartime,
					       @maxtime
					FROM   #adjustment1
					
					
					IF (@@error <> 0)
					BEGIN
						SET @result = '3000021-trash operation failed-->error in insert INTO t_acc_bucket_map'
						rollback tran
						RETURN
					END
				END
				----------------------------------------
				--Delete FROM t_acc_usage table
				----------------------------------------
				
				SELECT @sqlstmt = N'DELETE  au FROM ' + @dbname + 
				       '..t_acc_usage au INNER JOIN tempdb..tmp_t_acc_usage tmp on au.id_sess = tmp.id_sess'
				EXEC (@sqlstmt)
				
				IF (@@error <> 0)
				BEGIN
					SET @result = '3000022-trash operation failed-->Error in Delete t_acc_usage operation'
					ROLLBACK TRAN
					RETURN
				END
				
				----------------------------------------------
				---Update t_acc_bucket_map
				------------------------------------------------

				UPDATE t_acc_bucket_map
				SET    tt_end             = DATEADD(s, -1, @vartime)
				WHERE  id_usage_interval  = @interval_id
				       AND id_acc IN (SELECT id
				                      FROM   #AccountIDsTable)
				       AND STATUS = 'D'
				       AND tt_end = @maxtime
				
				IF (@@error <> 0)
				BEGIN
					SET @result = '3000023-trash operation failed-->error in update t_acc_bucket_map'
					ROLLBACK TRAN
					RETURN
				END
				
				INSERT INTO t_acc_bucket_map
				  (
				    id_usage_interval,
				    id_acc,
				    bucket,
				    [status],
				    tt_start,
				    tt_end
				  )
				SELECT @interval_id,
				       id,
				       bucket,
				       'A',
				       @vartime,
				       @maxtime
				FROM   #AccountIDsTable tmp
				       INNER JOIN t_acc_bucket_map act
				            ON  tmp.id = act.id_acc
				            AND act.id_usage_interval = @interval_id
				            AND act.status = 'D'
				            AND tt_end = DATEADD(s, -1, @vartime)
				
				
				IF (@@error <> 0)
				BEGIN
					SET @result = '3000024-trash operation failed-->error in insert INTO t_acc_bucket_map'
					ROLLBACK TRAN
					RETURN
				END
				
				------------------------------------------------
				--update t_archive_partition and t_partition
				------------------------------------------------
				IF (SELECT b_partitioning_enabled FROM t_usage_server) = 'Y'
				BEGIN
					
					SELECT @partname = partition_name
					FROM   t_partition_interval_map map
					       INNER JOIN t_partition part
					            ON  map.id_partition = part.id_partition
					WHERE  id_interval = @interval_id
					
					IF EXISTS (SELECT 1 FROM t_partition part 
									INNER JOIN t_partition_interval_map map ON part.id_partition = map.id_partition 
																		 AND part.partition_name = @partname
									INNER JOIN  t_archive_partition back on part.partition_name = back.partition_name
																				AND back.status = 'D' 
																				AND tt_end = @maxtime 
																				AND map.id_interval not in 
																				(SELECT id_interval FROM t_archive 
																							WHERE [status]  <> 'A' AND tt_end = @maxtime))
					BEGIN
						UPDATE t_archive_partition
						SET    tt_end          = DATEADD(s, -1, @vartime)
						WHERE  partition_name  = @partname
						       AND tt_end      = @maxtime
						       AND STATUS      = 'D'
						
						IF (@@error <> 0)
						BEGIN
							SET @result = '3000025-archive operation failed-->Error in update t_archive_partition table'
							rollback tran
							RETURN
						END
						
						INSERT INTO t_archive_partition
						VALUES
						  (
						    @partname,
						    'A',
						    @vartime,
						    @maxtime
						  )
						IF (@@error <> 0)
						BEGIN
							SET @result = '3000026-archive operation failed-->Error in insert INTO t_archive_partition table'
							ROLLBACK TRAN
							RETURN
						END
						
						UPDATE t_partition
						SET    b_active        = 'N'
						WHERE  partition_name  = @partname
						
						IF (@@error <> 0)
						BEGIN
							SET @result = '3000027-archive operation failed-->Error in update t_partition table'
							ROLLBACK TRAN
							RETURN
						END
					END
				END

				IF object_id('tempdb..tmp_t_acc_usage') IS NOT NULL
				DROP TABLE tempdb..tmp_t_acc_usage
				
				IF object_id('tempdb..tmp_t_adjustment_transaction') IS NOT NULL
				DROP TABLE tempdb..tmp_t_adjustment_transaction
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
			
			SET @result = '0-archive_trash operation successful'
		COMMIT TRAN