
      CREATE PROCEDURE Export_DeleteReportDefintion
      @id_rep INT
      AS
      BEGIN	
	      SET NOCOUNT ON

	      DELETE FROM t_export_default_param_values 
	      WHERE id_rep_instance_id IN 
		      (SELECT id_rep_instance_id FROM t_export_report_instance WHERE id_rep = @id_rep)

	      DELETE FROM t_export_schedule 
	      WHERE id_rep_instance_id IN 
		      (SELECT id_rep_instance_id FROM t_export_report_instance WHERE id_rep = @id_rep)

	      DELETE FROM t_export_report_params
	      WHERE id_rep = @id_rep

	      DELETE FROM t_export_report_instance
	      WHERE id_rep = @id_rep
	
	      DELETE FROM t_export_reports 
	      WHERE id_rep = @id_rep
      END
	 