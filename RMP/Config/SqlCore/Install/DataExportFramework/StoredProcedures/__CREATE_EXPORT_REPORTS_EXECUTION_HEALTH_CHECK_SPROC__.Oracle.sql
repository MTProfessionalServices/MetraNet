                                       
              CREATE OR REPLACE PROCEDURE Export_ReportsExecutionHealthC
              (
                v_start_dt IN DATE DEFAULT NULL ,
                v_end_dt IN DATE DEFAULT NULL ,
                cv_1 IN OUT SYS_REFCURSOR
              )
              AS
              
              BEGIN
                 OPEN cv_1 FOR
                    SELECT c_rep_title ,
                           run_start_dt ,
                           run_end_dt ,
                           c_run_result_status ,
                           c_run_result_descr ,
                           c_sch_type ,
                           c_execute_paraminfo 
                      FROM t_export_execute_audit 
                     WHERE run_end_dt >= v_start_dt
                             AND run_end_dt < v_end_dt;
              END;
	 