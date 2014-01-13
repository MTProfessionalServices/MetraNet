                                       
            CREATE OR REPLACE
			PROCEDURE export_getqueuedreportinstancs(
														p_workQId IN CHAR DEFAULT NULL,
														p_servername IN VARCHAR2 DEFAULT NULL,
														cv_1 IN OUT SYS_REFCURSOR
													)
			AS
				v_rawWorkQId RAW(16) := NULL;              
			BEGIN

				IF p_workQId IS NOT NULL THEN 
					v_rawWorkQId := HEXTORAW(TRANSLATE(p_workqid,'0{-}','0'));
				END IF;
				
				IF NVL(LENGTH(v_rawWorkQId), 0) != 0 THEN
					DECLARE v_temp NUMBER(1, 0) := 0;
					BEGIN
						BEGIN
							SELECT 1 INTO v_temp
							FROM   DUAL
							WHERE  EXISTS (
									   SELECT tq.id_work_queue
									   FROM   t_export_workqueue tq
									   WHERE  tq.id_work_queue = v_rawWorkQId
											  AND NVL(tq.c_current_process_stage, 0) = 0
											  AND NVL(LENGTH(c_processing_server), 0) = 0
								   ); 
							EXCEPTION 
								WHEN OTHERS THEN NULL;
						END;
						
						IF v_temp = 1 THEN
							BEGIN
								export_UpdateRepWorkQExecStat(v_rawWorkQId, p_servername, 1); 
								OPEN cv_1 FOR
									SELECT id_work_queue,
										   NVL(id_rep, 0) id_rep,
										   NVL(id_rep_instance_id, 0) id_rep_instance_id,
										   NVL(id_schedule, 0) id_schedule,
										   NVL(c_sch_type, 'QUEUED') c_sch_type,
										   c_rep_type,
										   c_rep_title
									FROM   t_export_workqueue
									WHERE  id_work_queue = v_rawWorkQId;
							END;
						END IF;
					END;
				ELSE
					BEGIN
						OPEN cv_1 FOR
							SELECT id_work_queue,
								   id_rep,
								   id_rep_instance_id,
								   NVL(id_schedule, 0) id_schedule,
								   NVL(c_sch_type, 'QUEUED') c_sch_type,
								   c_rep_type,
								   c_rep_title
							FROM   t_export_workqueue
							WHERE  id_work_queue = COALESCE(v_rawWorkQId, id_work_queue)
								   AND NVL(c_current_process_stage, 0) = 0
								   AND NVL(LENGTH(c_processing_server), 0) = 0
							ORDER BY
									dt_queued;
					END;        
				END IF;
			END;
	 