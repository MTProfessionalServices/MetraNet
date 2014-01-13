
              CREATE OR REPLACE PROCEDURE export_UpdateRepWorkQExecStat
              (
                v_workQId IN CHAR DEFAULT NULL ,
                v_servername IN VARCHAR2 DEFAULT NULL ,
                v_status IN NUMBER DEFAULT NULL 
              )
              AS
              
              BEGIN
                 UPDATE t_export_workQueue
                    SET c_current_process_stage = v_status,
                        c_processing_server = v_servername
                    WHERE id_work_queue = v_workQId;
              END;
	 