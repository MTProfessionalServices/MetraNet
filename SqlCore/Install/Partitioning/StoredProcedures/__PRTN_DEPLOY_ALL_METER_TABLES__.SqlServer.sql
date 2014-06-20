	CREATE PROCEDURE prtn_deploy_all_meter_tables
	AS
	BEGIN
		DECLARE @svc_table_name VARCHAR(200),
				@meter_partition_schema VARCHAR(100)

		BEGIN TRY 
			SET @meter_partition_schema = dbo.prtn_GetMeterPartitionSchemaName()

			IF dbo.IsSystemPartitioned()=0
				RAISERROR('System not enabled for partitioning.', 16, 1)

			DECLARE svctablecur CURSOR FOR 
								SELECT nm_table_name 
								FROM t_service_def_log 

			--------------------------------------------------------------------------
			------------------Deploy service definition tables -----------------------
			--------------------------------------------------------------------------
			OPEN svctablecur 
			FETCH NEXT FROM svctablecur INTO @svc_table_name 
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				EXEC prtn_deploy_table 
						@svc_table_name, 
						N'id_source_sess ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'    
			
			FETCH NEXT FROM svctablecur INTO @svc_table_name 
			END 

			-------------------------------------------------------------------------
			-----------------Deploy message and session tables-----------------------
			-------------------------------------------------------------------------
			EXEC prtn_deploy_table
						N't_message', 
						N'id_message ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition'  

			EXEC prtn_deploy_table 
						N't_session', 
						N'id_ss ASC, id_source_sess ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition' 

			EXEC prtn_deploy_table 
						N't_session_set', 
						N'id_ss ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition' 

			EXEC prtn_deploy_table 
						N't_session_state', 
						N'id_sess ASC, dt_end ASC, tx_state ASC, id_partition ASC',
						@meter_partition_schema,
						N'id_partition' 
		END TRY 
		BEGIN CATCH 
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT	
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()	
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState) 
		END CATCH 
	END