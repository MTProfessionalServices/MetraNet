
					SELECT 
						id_work_queue WorkQueueID,
						rp.c_report_title as ReportTitle,
						c_exec_type as ReportExecutionTypeText, 
						c_rep_output_type as ReportOutputTypeText,
						NVL(c_output_file_name,'NA') as OutputFileName,
						NVL(c_rep_destn,'NA') as ReportDestination,
						c_rep_distrib_type as ReportDistributionTypeText,
						dt_queued as LastRunDate, 
						dt_sched_run as NextRunDate,
    
					CASE c_current_process_stage
							WHEN 0 THEN 'Waiting For Execution'
									ELSE 'Attempted Execution but did not complete'
					END as InstanceRunResult,
							rp.id_rep as ReportID,
							c_id_work_queue_int as intWorkQueueID 
					FROM t_export_workqueue q
                         INNER JOIN t_export_reports rp on q.id_rep = rp.id_rep
                        