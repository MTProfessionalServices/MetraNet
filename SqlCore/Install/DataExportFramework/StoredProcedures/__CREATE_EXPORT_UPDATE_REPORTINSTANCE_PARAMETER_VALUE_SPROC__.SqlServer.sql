
      CREATE PROCEDURE Export_UpdateReportInstancePar
      @id_parameter_value INT,
      @parameter_value    VARCHAR(500) = 'DEFAULT' 

      AS
      BEGIN	
	      SET NOCOUNT ON
              UPDATE t_export_default_param_values set c_param_value = @parameter_value
              WHERE id_param_values = @id_parameter_value

      END
	 