
CREATE PROCEDURE archive_export
(
			@partition_name NVARCHAR(30)= NULL,
			@interval_id INT = NULL,
			@path NVARCHAR(1000),
			@avoid_rerun CHAR(1) = 'N',
			@result NVARCHAR(4000)OUTPUT
)
AS
/*
		How to run this stored procedure
		
		DECLARE @result NVARCHAR(2000)
		exec archive_export @partition_name='N_20040701_20040731',@path='c:\backup\archive', @avoid_rerun = 'N', @result=@result output
		print @result
		
		or
		
		DECLARE @result NVARCHAR(2000)
		exec archive_export @interval_id=827719717,@path='c:\backup\archive',@avoid_rerun = 'N',@result=@result output
		print @result
*/

	   SET NOCOUNT ON
	   
	   DECLARE @acc INT
	   DECLARE @interval INT
	   DECLARE @partition NVARCHAR(30)
	   DECLARE @minid INT
	   DECLARE @maxid INT
	   
--Checking the Business rules

--Either Partition or Interval should be specified
	   IF ((@partition_name IS NOT NULL AND @interval_id IS NOT NULL) OR (@partition_name IS NULL AND @interval_id IS NULL))
	   BEGIN
		   SET @result = '1000001-archive_export operation failed-->Either Partition or Interval should be specified'
		   RETURN
	   END
	   
--Get the list of Intervals that need to be archived
	--Partition name should be correct
       IF (@partition_name IS NOT NULL) AND NOT EXISTS(SELECT 1 FROM t_partition tp WHERE tp.partition_name = @partition_name)
       BEGIN
		   SET @result = '1000002-archive operation failed-->Partition name is incorrect. There is no partitions in DB with such partition name.'
           RETURN  
       END
           
	   IF (@partition_name IS NOT NULL)
	   BEGIN
		   DECLARE  interval_id CURSOR FAST_FORWARD FOR 
		   SELECT id_interval FROM t_partition_interval_map map WHERE id_partition 
		   = (SELECT id_partition  FROM t_partition WHERE partition_name = @partition_name)
	   END
	   ELSE
	   BEGIN
		   DECLARE interval_id CURSOR FAST_FORWARD FOR SELECT @interval_id
		   
		   SELECT @partition = partition_name FROM t_partition part 
		   INNER JOIN t_partition_interval_map map 
					ON part.id_partition = map.id_partition
						AND map.id_interval = @interval_id
	   END
	   
       OPEN interval_id
       FETCH NEXT FROM interval_id INTO @interval
       WHILE (@@fetch_status = 0)
       BEGIN
           --interval should EXISTS
           IF NOT EXISTS (SELECT 1 FROM t_usage_interval WHERE id_interval = @interval)
           BEGIN
               SET @result = '1000002-archive operation failed-->Interval does not exist'
               CLOSE interval_id
               DEALLOCATE interval_id
               RETURN
           END
           
           --Interval should be hard-CLOSEd
           IF EXISTS (SELECT 1 FROM t_usage_interval WHERE id_interval = @interval AND tx_interval_status in ('O','B'))
           BEGIN
               SET @result = '1000003-archive operation failed-->Interval is not Hard Closed'
               CLOSE interval_id
               DEALLOCATE interval_id
               RETURN
           END
           --Interval should not be already archived
           IF  EXISTS (SELECT 1 FROM t_archive WHERE id_interval = @interval AND status ='A' AND tt_end =dbo.mtmaxdate())
           BEGIN
			   SET @result = '1000004-archive operation failed-->Interval is already archived-Deleted'
			   CLOSE interval_id
			   DEALLOCATE interval_id
			   RETURN
           END
           --Interval should have bucket mapping
           IF NOT EXISTS (SELECT 1 FROM t_acc_bucket_map WHERE id_usage_interval=@interval)
           BEGIN
               SET @result = '1000005-archive operation failed-->Interval does not have bucket mappings'
               CLOSE interval_id
               DEALLOCATE interval_id
               RETURN
           END
           --Interval should be Dearchived
           IF  EXISTS (SELECT 1 FROM t_archive WHERE id_interval=@interval AND status ='D' AND tt_end = dbo.mtmaxdate())
           BEGIN
               SET @result = '1000006-archive operation failed-->Interval is Dearchived AND not be exported..run trash/delete procedure'
               CLOSE interval_id
               DEALLOCATE interval_id
               RETURN
           END
 
           ----------------
           --Archive_export for account usages 
           ----------------
           -- Fill temporary account usage tables
           IF OBJECT_ID('tempdb..tmp_t_acc_usage') IS NOT NULL 
		   DROP TABLE tempdb..tmp_t_acc_usage
		   
		   SELECT tabm.bucket, tau.id_sess, tau.id_usage_interval, tau.id_acc INTO tempdb..tmp_t_acc_usage
			  FROM t_acc_usage tau WITH (NOLOCK) 
				INNER JOIN t_acc_bucket_map tabm ON tau.id_usage_interval = tabm.id_usage_interval
											  AND tau.id_acc = tabm.id_acc 
												  WHERE tau.id_usage_interval = @interval AND tabm.[status]= 'U'
			
		    ALTER TABLE tempdb..tmp_t_acc_usage ADD CONSTRAINT pk_tmp_t_acc_usage PRIMARY KEY CLUSTERED (bucket, id_sess)
		    
		   -- Fill temporary product views table	
		   IF OBJECT_ID('tempdb..##productViews') IS NOT NULL
		   DROP TABLE ##productViews									  
		   SELECT DISTINCT id_view INTO ##productViews FROM t_acc_usage WITH(NOLOCK)
									WHERE  id_usage_interval =  @interval
										
												  
			--Create the temp table that will store the output of the bcp operation
		   IF OBJECT_ID('tempdb..##bcpoutput') IS NOT NULL
		   DROP TABLE ##bcpoutput
		   CREATE TABLE ##bcpoutput(OutputLine nvarchar(4000))
		   
		   EXEC Create_folder
	   			@folder_path = @path
		   ----------------
       --Archive_export for account usages 
       ----------------				
		   DECLARE  cursor_account_usage CURSOR FAST_FORWARD FOR SELECT DISTINCT bucket FROM tempdb..tmp_t_acc_usage WITH (NOLOCK)
					   
		   OPEN cursor_account_usage
		   FETCH NEXT FROM cursor_account_usage INTO @acc
		   WHILE (@@fetch_status = 0)
		   BEGIN
		   		   		BEGIN TRY
	   					SELECT @minid = min(id_sess), @maxid = max(id_sess) 
	   						FROM tempdb..tmp_t_acc_usage WITH (NOLOCK) WHERE bucket = @acc
				   			
						EXEC arch_export_account_usages
												@path = @path,
												@acc = @acc,
												@interval_id = @interval,
												@minid = @minid,
												@maxid = @maxid 					

					   ----------------
					   --Archive_export for unique_cons tables
					   ----------------			
					   IF (SELECT b_partitioning_enabled FROM t_usage_server) = 'Y'
					   BEGIN
							EXEC arch_export_unique_cons_tables
													@path = @path,
													@acc = @acc,
													@interval_id = @interval
					   END	
					   
					   ----------------
					   --Archive_export for product_view tables
					   ----------------	
						EXEC arch_export_product_view_tables
							@path = @path,
							@acc = @acc,
							@interval_id = @interval,
							@minid = @minid,
							@maxid = @maxid
							
					   ----------------
					   --Archive_export for amp tables
					   ----------------	
					   	EXEC arch_export_amp_tables
							@path = @path,
							@acc = @acc,
							@interval_id = @interval,
							@minid = @minid,
							@maxid = @maxid
							
							
											 												 
					 ----------------
					 --Archive_export update t_acc_bucket_map table
					----------------	
							
					   EXEC arch_update_account_bucket_map
											@status_to_insert = 'E',
											@acc = @acc,
											@interval_id = @interval
			   END TRY
			   BEGIN CATCH
						CLOSE cursor_account_usage
						DEALLOCATE cursor_account_usage
						CLOSE interval_id
						DEALLOCATE interval_id
						DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
						SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
						RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
						RETURN
			   END CATCH
		   FETCH NEXT FROM cursor_account_usage INTO @acc
		   END
		   CLOSE cursor_account_usage
		   DEALLOCATE cursor_account_usage
			 BEGIN TRY
				   EXEC arch_export_adjustment_transaction
							@path = @path,
							@interval_id = @interval	
				   
				   EXEC arch_export_adjustment_tables	
							@path = @path,
							@interval_id = @interval
		   END TRY
		   BEGIN CATCH
					CLOSE interval_id
					DEALLOCATE interval_id	
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
					RETURN
		   END CATCH
	  FETCH NEXT FROM interval_id INTO @interval
	  END
	  CLOSE interval_id                          
	  
	  
--Update the archiving tables...t_archive, t_archive_partition
      BEGIN TRAN
      
		   OPEN interval_id
		   FETCH NEXT FROM interval_id INTO @interval
		   WHILE (@@fetch_status = 0)
		   BEGIN
		   		EXEC arch_update_archive_table
		   				@status_to_insert = 'E',
							 @interval_id = @interval,
						   @result = @result
		   				
		   		IF (@result IS NOT NULL)
				BEGIN
					ROLLBACK TRAN
	   				CLOSE interval_id
	   				DEALLOCATE interval_id
	   				RETURN
				END				   	
		   FETCH NEXT FROM interval_id INTO @interval	
		   END
		   CLOSE interval_id
		   DEALLOCATE interval_id
		   
		   EXEC arch_update_archive_partition_table
						@partition_name = @partition_name,
						@partition = @partition,
						@interval_id = @interval_id,
						@status_to_insert = 'E',
						@result = @result

       IF (@result IS NOT NULL)
		   BEGIN 
				ROLLBACK TRAN
		   END	
			
		   IF OBJECT_ID('tempdb..tmp_t_acc_usage') IS NOT NULL 
			   DROP TABLE tempdb..tmp_t_acc_usage
		    	
		   IF OBJECT_ID('tempdb..##productViews') IS NOT NULL
			   DROP TABLE ##productViews			
			  	
		   IF OBJECT_ID('tempdb..##bcpoutput') IS NOT NULL
			   DROP TABLE ##bcpoutput
			   
		   	IF OBJECT_ID('tempdb..##adjustment') IS NOT NULL
				DROP TABLE ##adjustment	
	   
		   SET @result = '0-archive_export operation successful'

	 COMMIT TRAN
		