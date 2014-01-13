
              CREATE OR REPLACE PROCEDURE Export_DeleteReportDefintion
              (
                p_id_rep IN NUMBER DEFAULT NULL 
              )
              AS              
              BEGIN
                 DELETE t_export_default_param_values              
                 WHERE id_rep_instance_id IN ( SELECT id_rep_instance_id 
                                                FROM t_export_report_instance 
                                                 WHERE id_rep = p_id_rep );                                                 
                 DELETE t_export_schedule              
                 WHERE id_rep_instance_id IN ( SELECT id_rep_instance_id 
                                                FROM t_export_report_instance 
                                                 WHERE id_rep = p_id_rep );
                                                 
                 DELETE t_export_report_params
                 WHERE id_rep = p_id_rep;
              
                 DELETE t_export_report_instance
                 WHERE id_rep = p_id_rep;
              
                 DELETE t_export_reports
                 WHERE id_rep = p_id_rep;
              END;
	 