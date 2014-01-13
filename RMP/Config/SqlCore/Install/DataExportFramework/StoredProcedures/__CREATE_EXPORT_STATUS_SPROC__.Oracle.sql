
              CREATE OR REPLACE PROCEDURE Export_Status
              (
                cv_1 IN OUT SYS_REFCURSOR
              )
              AS
              
              BEGIN
                 INSERT INTO tt_DEF_Export_Status_Table
                   ( SELECT 'Export System Status' status_item  ,
                            CASE parm_value
                                           WHEN '0' THEN 'System is currently running.'
                            ELSE 'System is currently paused.'
                               END status_msg  
                     FROM t_export_system_parms 
                      WHERE parm_name = 'system_suspended'
                     UNION 
                     SELECT 'Refresh Status' status_item  ,
                            'Refresh currently in progress.' status_msg  
                     FROM t_export_system_parms 
                      WHERE parm_name = 'refresh_in_progress'
                              AND CAST(parm_value AS NUMBER(10,0)) > 0 );
                 OPEN cv_1 FOR
                    SELECT * 
                      FROM tt_DEF_Export_Status_Table ;
                 /*EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DEF_Export_Status_Table ';*/
                 RETURN;
              END;
	 