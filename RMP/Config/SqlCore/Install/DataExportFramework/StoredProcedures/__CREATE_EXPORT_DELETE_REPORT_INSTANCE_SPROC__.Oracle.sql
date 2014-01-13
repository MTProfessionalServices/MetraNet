                                       
              CREATE OR REPLACE PROCEDURE Export_DeleteReportInstance
              (
                p_id_rep_instance IN NUMBER DEFAULT NULL 
              )
              AS              
              BEGIN
				DELETE t_export_default_param_values              
                WHERE id_rep_instance_id = p_id_rep_instance;
                
				DELETE t_export_schedule
                WHERE id_rep_instance_id = p_id_rep_instance;
              
				DELETE t_export_report_instance
				WHERE id_rep_instance_id = p_id_rep_instance;
              END;
	 