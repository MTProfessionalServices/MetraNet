
      CREATE PROCEDURE [dbo].[Export_DeleteInstanceSchedule]
      @id_rep_instance_id INT
      AS
      BEGIN	
	      SET NOCOUNT ON

	      DELETE FROM t_export_schedule 
	      WHERE id_rep_instance_id = @id_rep_instance_id 

      END
	 