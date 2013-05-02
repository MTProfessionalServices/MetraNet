
					SELECT 
					exprep.id_rep as ReportID, 
					c_report_title as ReportTitle, 
					c_report_desc as ReportDescription, 
					c_prevent_adhoc_execution 
					FROM t_export_reports exprep
					WHERE c_prevent_adhoc_execution = 0
                        