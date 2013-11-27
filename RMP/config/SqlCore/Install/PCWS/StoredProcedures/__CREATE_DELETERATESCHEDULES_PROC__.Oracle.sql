
				CREATE OR REPLACE PROCEDURE DeleteRateSchedules(
					p_plID int,
					p_piTemp int,
					p_ptId int,
					p_status out int
				)
				AS
					l_sched_id int;
					pt_status int;
				BEGIN
					/* Delete rate schedules.  */
                	DECLARE CURSOR rsCursor IS
						SELECT rs.id_sched FROM	
							t_rsched rs
                		WHERE	
							rs.id_pricelist = p_plID
							AND
							rs.id_pi_template = p_piTemp
							and
							rs.id_pt = p_ptId;
							
                    BEGIN
                        OPEN rsCursor;
                        IF rsCursor%ISOPEN THEN
                        LOOP
                            FETCH rsCursor INTO l_sched_id;
                            EXIT WHEN rsCursor%NOTFOUND;
                            
                            DeleteRateSchedule(l_sched_id, pt_status);
                        END LOOP;
                        END IF;
                        CLOSE rsCursor;
                    END;                	
				END;
				