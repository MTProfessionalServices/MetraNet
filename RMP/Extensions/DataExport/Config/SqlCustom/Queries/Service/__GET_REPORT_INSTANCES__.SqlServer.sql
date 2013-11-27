
				SELECT id_work_queue,
				       id_rep,
				       id_rep_instance_id,
				       ISNULL(id_schedule, 0) AS 'id_schedule',
				       ISNULL(c_sch_type, 'QUEUED') AS 'c_sch_type',
				       c_rep_type,
				       c_rep_title
				FROM   t_export_workqueue
				WHERE  ISNULL(c_current_process_stage, 0) = 0
				       AND LEN(ISNULL(c_processing_server, '')) = 0
				ORDER BY
				       dt_queued
			