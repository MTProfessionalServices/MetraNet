
				CREATE PROCEDURE DeleteRateSchedules(
					@plID int,
					@piTemp int,
					@ptId int,
					@status int output
				)
				AS
				BEGIN
					Declare @sched_id int, @pt_status int;

					/* Delete rate schedules.  */
                	DECLARE rsCursor CURSOR FOR
						SELECT rs.id_sched FROM	
							t_rsched rs
                		WHERE	
							rs.id_pricelist = @plID
							AND
							rs.id_pi_template = @piTemp
							and
							rs.id_pt = @ptId;

					
					OPEN rsCursor
					FETCH NEXT FROM rsCursor into @sched_id
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						Exec DeleteRateSchedule @sched_id, @pt_status						
						
						FETCH NEXT FROM rsCursor into @sched_id
					END
					
					CLOSE rsCursor
					DEALLOCATE rsCursor
				END
				