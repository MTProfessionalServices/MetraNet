                                       
              CREATE OR REPLACE PROCEDURE Export_ReverseQueuedReports
              (
                v_RunIdToReverse IN NUMBER DEFAULT NULL 
              )
              AS
              
              BEGIN
                 DELETE t_export_workqueue
              
                  WHERE id_run = v_RunIdToReverse;
                 UPDATE t_export_execute_audit
                    SET c_execution_backedout = 1
                    WHERE id_run = v_RunIdToReverse;
              END;
	 