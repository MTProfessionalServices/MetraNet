
					SELECT 
						id_audit AS AuditID, 
						c_rep_title AS ReportTitle, 
						c_exec_type AS ReportExecutionTypeText, 
						c_rep_output_type AS ReportOutputTypeText, 
						NVL(c_output_file_name,'NA') AS OutputFileName, 
						NVL(c_rep_destn,'NA') AS ReportDestination, 
						c_rep_distrib_type AS ReportDistributionTypeText,
						run_start_dt AS LastRunDate, 
						run_end_dt AS NextRunDate, 
						c_run_result_descr AS InstanceRunResult, 
						id_rep AS IDReport
					FROM t_export_execute_audit 
                        