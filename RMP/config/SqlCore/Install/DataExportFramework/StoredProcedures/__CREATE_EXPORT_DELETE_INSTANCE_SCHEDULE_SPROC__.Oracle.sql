                                       
              CREATE OR REPLACE PROCEDURE Export_DeleteInstanceSchedule
              (
                v_id_rep_instance_id IN NUMBER DEFAULT NULL 
              )
              AS
              
              BEGIN
                 DELETE t_export_schedule
              
                  WHERE id_rep_instance_id = v_id_rep_instance_id;
              END;
	 