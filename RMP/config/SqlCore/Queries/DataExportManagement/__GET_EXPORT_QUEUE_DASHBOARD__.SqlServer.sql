
			 select 
			 id_work_queue WorkQueueID,
			 rp.c_report_title as ReportTitle,
			 c_exec_type as ReportExecutionTypeText, 
			 c_rep_output_type as ReportOutputTypeText,
			 isnull(c_output_file_name,'NA') as OutputFileName,
			 isnull(c_rep_destn,'NA') as ReportDestination,
			 c_rep_distrib_type as ReportDistributionTypeText,
			 dt_queued as LastRunDate, 
			 dt_sched_run as NextRunDate,    
			 case c_current_process_stage
                                when 0 then 'Waiting For Execution'
	         		else 'Attempted Execution but did not complete'
			 end as InstanceRunResult,
                         rp.id_rep as ReportID,
			 c_id_work_queue_int as intWorkQueueID 
 			 from t_export_workqueue q with(nolock)
                         inner join t_export_reports rp on q.id_rep = rp.id_rep

	
        