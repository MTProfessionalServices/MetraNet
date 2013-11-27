
				SELECT * FROM t_export_workqueue
				WHERE id_work_queue IN (SELECT idq FROM tt_def_queue_ids)
			