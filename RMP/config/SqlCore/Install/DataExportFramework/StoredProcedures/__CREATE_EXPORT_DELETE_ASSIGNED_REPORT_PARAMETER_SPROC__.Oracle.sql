                                       
              CREATE OR REPLACE PROCEDURE Export_DeleteAssignedReportPar
              (
                p_id_rep IN NUMBER DEFAULT NULL ,
                p_id_param_name IN NUMBER DEFAULT NULL 
              )
              AS
              
              BEGIN
                 DELETE t_export_default_param_values
                  WHERE id_rep_instance_id IN ( SELECT id_rep_instance_id 
                                                FROM t_export_report_instance 
                                                 WHERE id_rep = p_id_rep )
                       AND id_param_name = p_id_param_name;
              
                 DELETE t_export_report_params
                  WHERE id_rep = p_id_rep
                          AND id_param_name = p_id_param_name;
              END;
	 