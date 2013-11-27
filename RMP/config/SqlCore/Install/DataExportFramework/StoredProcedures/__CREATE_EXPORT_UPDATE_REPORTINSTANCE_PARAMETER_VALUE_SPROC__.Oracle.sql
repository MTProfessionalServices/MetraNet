
              CREATE OR REPLACE PROCEDURE Export_UpdateReportInstancePar
              (
                p_id_parameter_value IN NUMBER DEFAULT NULL ,
                p_parameter_value IN VARCHAR2 DEFAULT 'DEFAULT' 
              )
              AS
              
              BEGIN
                 UPDATE t_export_default_param_values
                    SET c_param_value = p_parameter_value
                    WHERE id_param_values = p_id_parameter_value;
              END;
	 