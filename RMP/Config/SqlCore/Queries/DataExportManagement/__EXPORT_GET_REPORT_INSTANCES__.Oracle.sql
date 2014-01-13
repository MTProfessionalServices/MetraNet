
					SELECT 
						id_rep_instance_id as IDReportInstance, 
						eri.id_rep IDReport, 
						c_rep_instance_desc as ReportInstanceDescription, 
						c_exec_type as ReportExecutionTypeText, 
						erp.c_report_title as ReportTitle 
					FROM t_export_report_instance eri 
						INNER JOIN t_export_reports erp ON eri.id_rep = erp.id_rep
							WHERE eri.id_rep = %%ID_REP%%
                        