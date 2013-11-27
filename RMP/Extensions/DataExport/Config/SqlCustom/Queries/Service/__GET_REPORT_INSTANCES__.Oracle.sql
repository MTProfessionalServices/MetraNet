
				SELECT id_work_queue,
				       id_rep,
				       id_rep_instance_id,
				       NVL(id_schedule, 0) id_schedule,
				       NVL(c_sch_type, 'QUEUED') c_sch_type,
				       c_rep_type,
				       c_rep_title
				FROM   t_export_workqueue
				WHERE  NVL(c_current_process_stage, 0) = 0
				       AND NVL(LENGTH(c_processing_server), 0) = 0
				ORDER BY
				       dt_queued
			