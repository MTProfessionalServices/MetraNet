

			select id_audit as AuditID, c_rep_title as ReportTitle, c_exec_type as ReportExecutionTypeText, c_rep_output_type as ReportOutputTypeText, 
isnull(c_output_file_name,'NA') as OutputFileName, isnull(c_rep_destn,'NA') as ReportDestination, c_rep_distrib_type as ReportDistributionTypeText,
run_start_dt as LastRunDate, run_end_dt as NextRunDate, c_run_result_descr as InstanceRunResult, id_rep as IDReport
FROM t_export_execute_audit 

  