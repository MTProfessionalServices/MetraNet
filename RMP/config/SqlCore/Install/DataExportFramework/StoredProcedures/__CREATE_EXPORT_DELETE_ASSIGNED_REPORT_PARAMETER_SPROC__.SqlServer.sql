
      CREATE PROCEDURE [dbo].[Export_DeleteAssignedReportPar]
      @id_rep INT,
      @id_param_name INT
      
      AS
      BEGIN	
	      SET NOCOUNT ON

	      DELETE FROM t_export_default_param_values 
	      WHERE id_rep_instance_id IN 
		      (SELECT id_rep_instance_id FROM t_export_report_instance WHERE id_rep = @id_rep)
              AND id_param_name = @id_param_name    

	      DELETE FROM t_export_report_params
	      WHERE id_rep = @id_rep
	      AND id_param_name = @id_param_name

      END
	 