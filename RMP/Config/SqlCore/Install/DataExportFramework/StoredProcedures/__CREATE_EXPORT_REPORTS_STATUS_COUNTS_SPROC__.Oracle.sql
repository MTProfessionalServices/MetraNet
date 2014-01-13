                                       
              CREATE OR REPLACE PROCEDURE Export_ReportsStatusCounts
              (
                v_start_dt IN DATE DEFAULT NULL ,
                v_end_dt IN DATE DEFAULT NULL ,
                cv_1 IN OUT SYS_REFCURSOR
              )
              AS
                 v_successCount NUMBER(10,0);
                 v_failedCount NUMBER(10,0);
              
              BEGIN
                 SELECT COUNT(*) 
              
                   INTO v_successCount
                   FROM t_export_execute_audit 
                  WHERE run_end_dt >= v_start_dt
                          AND run_end_dt < v_end_dt
                          AND c_run_result_status = 'success';
                 SELECT COUNT(*) 
              
                   INTO v_failedCount
                   FROM t_export_execute_audit 
                  WHERE run_end_dt >= v_start_dt
                          AND run_end_dt < v_end_dt
                          AND c_run_result_status = 'failed';
                 OPEN cv_1 FOR
                    SELECT v_successCount SUCCESS  ,
                           v_failedCount FAILED  
                      FROM DUAL ;
                 RETURN;
              END;
	 