
      CREATE PROCEDURE Export_DeleteReportInstance
      @id_rep_instance INT
      AS
      BEGIN	
	      SET NOCOUNT ON

	      DELETE FROM t_export_default_param_values 
	      WHERE id_rep_instance_id = @id_rep_instance

	      DELETE FROM t_export_schedule 
	      WHERE id_rep_instance_id = @id_rep_instance

	      DELETE FROM t_export_report_instance
	      WHERE id_rep_instance_id = @id_rep_instance
      END
	 