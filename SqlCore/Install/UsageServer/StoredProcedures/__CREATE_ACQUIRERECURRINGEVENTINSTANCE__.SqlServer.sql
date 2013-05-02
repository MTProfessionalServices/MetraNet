
			CREATE PROCEDURE [dbo].[AcquireRecurringEventInstance]
(
@id_instance     INT, 
				@current_status   NVARCHAR(14),
				@new_status       NVARCHAR(14),
@id_run           INT,
				@tx_type          VARCHAR(7),
@reversed_run     INT,
				@tx_machine       VARCHAR(128),
@dt_start	    DATETIME, 
@status			INT OUTPUT
) 
			AS

				DECLARE @eventCount INT;
				DECLARE @rowcount   INT;
				DECLARE @updater    INT;

				DECLARE @classname  VARCHAR(255)
				DECLARE @eventName  NVARCHAR(255);
				DECLARE @inProgress NVARCHAR(20);

				DECLARE @ErrorMessage  NVARCHAR(4000);
				DECLARE @ErrorSeverity INT;
				DECLARE @ErrorState    INT;

				CREATE TABLE #t_compatible_concurrent_events
				(
					tx_compatible_eventname NVARCHAR (510)
				);

				SET @status = -1;
				SET @inProgress = N'InProgress';

				BEGIN TRY

					BEGIN TRANSACTION AcquireRecEventInstanceTran;
		
						/* Take rowlock from t_stored_procedure_table_lock for this procedure */
						SELECT
							@updater = 1
						FROM
							t_stored_procedure_table_lock WITH (UPDLOCK, ROWLOCK)
						WHERE
							c_stored_procedure_name = 'AcquireRecurringEventInstance';

						/* BEGIN - Store data in temporary tables to relieve contention on static tables */
						SELECT 
							id_event,
							tx_name,
							tx_type,
							b_multiinstance,
							tx_class_name
						INTO 
							#t_recevent 
						FROM 
							t_recevent
						ORDER BY 
							id_event;
			
						IF @@ROWCOUNT > 1000
BEGIN
							CREATE CLUSTERED INDEX idx_cl_temp_recevent ON #t_recevent (id_event ASC);
END  

						SELECT 
							id_run,
							id_instance,
							tx_status
						INTO 
							#t_recevent_run 
						FROM 
							t_recevent_run 
						WHERE 
							tx_status = @inProgress
						ORDER BY
							id_run, id_instance;

						IF @@ROWCOUNT > 1000
						BEGIN
							CREATE CLUSTERED INDEX idx_cl_temp_recevent_run ON #t_recevent_run (id_run ASC);
							CREATE NONCLUSTERED INDEX idx_ncl_temp_recevent_run ON #t_recevent_run (id_instance ASC);
						END
  
						SELECT
							inst.id_instance,
							inst.id_event
						INTO 
							#t_recevent_inst 
						FROM 
							t_recevent_inst inst
						LEFT JOIN
							#t_recevent_run run
						ON
							inst.id_instance = run.id_instance
						WHERE
							inst.id_instance IS NULL
						OR
							( inst.id_instance IS NOT NULL AND inst.id_instance = @id_instance )
						ORDER BY
							id_instance, id_event;

						IF @@ROWCOUNT > 1000
						BEGIN
							CREATE CLUSTERED INDEX idx_cl_temp_recevent_inst ON #t_recevent_inst (id_instance ASC);
							CREATE NONCLUSTERED INDEX idx_ncl_temp_recevent_inst ON #t_recevent_inst (id_event ASC);
						END;

						/* END - Store data in temporary tables to relieve contention on static tables */

						/* Check that if this is an adapter of a class that has MultiInstance set to false */
						/* don't allow it to run if other instances of the class are running */
						SELECT 
							@classname = tx_class_name 
						FROM 
							#t_recevent evt 
						JOIN 
							#t_recevent_inst evt_inst
						ON 
							evt.id_event = evt_inst.id_event
						WHERE 
							evt.b_multiinstance = 'N'
						AND 
							evt_inst.id_instance = @id_instance;

						/* Class doesn't allow multiple instances, see if any other events with this class are running */
						IF @classname IS NOT NULL
						BEGIN
							SELECT 
								@eventCount = COUNT(*) 
							FROM
								#t_recevent evt
							JOIN 
								#t_recevent_inst evt_inst
							ON 
								evt.id_event = evt_inst.id_event
							JOIN
								#t_recevent_run evt_run
							ON
								evt_inst.id_instance = evt_run.id_instance
							WHERE 
								evt.tx_class_name = @classname
							AND 
								evt_run.tx_status = @inProgress;
					
							IF @eventCount > 0
							BEGIN
							  /* Another event with the same class name is running */
							  COMMIT TRANSACTION AcquireRecEventInstanceTran;
							  SELECT @status = -3;  /* Can not run concurrently with other running adapters at the moment */
							  RETURN;
							END
END

						/* Determine Compatible Events */
						INSERT #t_compatible_concurrent_events
							EXEC prcGetCompatibleConcurrentEvents;
				
						/* Check that the event is still compatible with running events */
						SELECT
							@eventName = evt.tx_name
						FROM 
							#t_recevent evt
						JOIN 
							#t_recevent_inst evt_inst 
						ON 
							evt.id_event = evt_inst.id_event 
						AND 
							evt_inst.id_instance = @id_instance;
				
						IF ( (SELECT COUNT(*) FROM #t_compatible_concurrent_events WHERE tx_compatible_eventname = @eventName) = 0 )
						BEGIN
							COMMIT TRANSACTION AcquireRecEventInstanceTran;
							SELECT @status = -2;  /* Can not run concurrently with other running adapters at the moment */
							RETURN;
						END

						UPDATE 
							t_recevent_inst 
						SET 
							tx_status = @new_status,
							b_ignore_deps = 'N',
							dt_effective = NULL
WHERE 
							id_instance = @id_instance 
						AND
							tx_status = @current_status;

						/* the instance may not have been acquired if */
						/* another billing server picked it up first */
IF @@ROWCOUNT > 0 
						BEGIN
							INSERT INTO t_recevent_run
							(
								id_run,
								id_instance,
								tx_type,
								id_reversed_run,
								tx_machine,
								dt_start,
								dt_end,
								tx_status,
								tx_detail
							)
							VALUES 
							(
								@id_run,
								@id_instance,
								@tx_type,
								@reversed_run,
								@tx_machine,
								@dt_start, 
								NULL,
								@inProgress,
								NULL
							);
							SELECT @status = 0
						END
					COMMIT TRANSACTION AcquireRecEventInstanceTran;
				END TRY
				BEGIN CATCH
					IF @@TRANCOUNT > 0
					BEGIN
						ROLLBACK TRANSACTION AcquireRecEventInstanceTran;
					END
		
					SELECT  
						@ErrorMessage = 'Exception during execution of stored procedure "AcquireRecurringEventInstance":  ' + ERROR_MESSAGE(),
						@ErrorSeverity = ERROR_SEVERITY(),
						@ErrorState = ERROR_STATE();

					RAISERROR
					(
						@ErrorMessage, 
						@ErrorSeverity, 
						@ErrorState
					);
				END CATCH
		 