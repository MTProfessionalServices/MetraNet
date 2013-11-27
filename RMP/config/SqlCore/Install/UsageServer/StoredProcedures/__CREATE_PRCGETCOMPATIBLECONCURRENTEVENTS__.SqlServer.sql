
			/*                                                                                                                   */
			/*	Returns a list of events that are compatible with currently running events.                                      */
			/*	This is either all events if nothing is running or the list of events compatible with currently running events.  */
			/*                                                                                                                   */
			CREATE PROCEDURE [dbo].[prcGetCompatibleConcurrentEvents]
			AS
			BEGIN	
				/* All internal events                                                                            */
				/* All unique event names when there are no running adapters (no conflicts)                       */
				/* Intentionally not checking against active events to make sure we don't                         */
				/* skip any older events that do not have rules or have been deactivated but still have instances */
	
				DECLARE @inProgress NVARCHAR(20);
				SET @inProgress = N'InProgress';

				SELECT 
					DISTINCT
					evt.tx_name 
				FROM 
					#t_recevent evt
				WHERE 
					evt.tx_type = 'Root'
				UNION
				(

				SELECT 
					DISTINCT 
					evt.tx_name 
				FROM 
					#t_recevent evt
				WHERE 
					evt.tx_type NOT IN ('Checkpoint','Root')
				AND 
					(
						(	
							SELECT 
								COUNT(*)
							FROM 
								#t_recevent_run
							WHERE 
								tx_status = @inProgress
						) 
					= 0)
				)
				UNION
				(
					/* List of events compatible with currently running events */
					SELECT 
						tx_compatible_eventname
					FROM 
						(
							SELECT
								evt.tx_name
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
								evt_run.tx_status = @inProgress
							GROUP BY 
								evt.tx_name, 
								evt.id_event
						) r 
					JOIN 
						t_recevent_concurrent c 
					ON
						r.tx_name = c.tx_eventname
					GROUP BY 
						tx_compatible_eventname
					HAVING COUNT(*) = (
										SELECT 
											COUNT(*) 
										FROM 
											(
												SELECT 
													id_run 
												FROM 
													#t_recevent_run evt_run 
												WHERE 
													evt_run.tx_status = @inProgress 
												GROUP BY 
													id_run
											) d
										)
				);
			END
		