                                      
              CREATE OR REPLACE PROCEDURE EXPORT_REPORTS
              (
                cv_1 IN OUT SYS_REFCURSOR
              )
              AS
              
              BEGIN
                 /*
                             OPEN
                             1.    None
                             
                             CLOSED
                             1.    None
                  
                             -- exec Export_reports --
                  
                             */
                 OPEN cv_1 FOR
                    SELECT RPT.id_rep REPORT_ID  ,
                           RPT.c_report_title REPORT_TITLE  ,
                           CASE 
                                WHEN NVL(INSTANCE.c_rep_instance_desc, '0') = '0' THEN '!!! - No Instance Defined - Ad Hoc Only'
                           ELSE INSTANCE.c_rep_instance_desc
                              END REPORT_INSTANCE_DESC  ,
                           INSTANCE.dt_activate DATE_ACTIVATED  ,
                           INSTANCE.dt_last_run LAST_RUN  ,
                           INSTANCE.dt_next_run NEXT_RUN  ,
                           INSTANCE.c_rep_output_type OUTPUT_TYPE  ,
                           INSTANCE.c_rep_distrib_type DISTRIBUTION_TYPE  ,
                           INSTANCE.c_report_destn DISTRIBUTION_DESTINATION  ,
                           ExportGetParmsAndValues(INSTANCE.id_rep_instance_id) SET_PARMS  ,
                           NVL(INSTANCE.c_exec_type, 'ad-hoc') TYPE  ,
                           CASE 
                                WHEN NVL(SCHEDDETAIL.schedule_details, '0') = '0'
                                  AND INSTANCE.c_exec_type = 'SCH' THEN '!!! - No Schedule is Set Up'
                                WHEN INSTANCE.c_exec_type = 'EOP' THEN 'EOP Step - ' || CAST(c_eop_step_instance_name AS CHAR(10))
                           ELSE SCHEDDETAIL.schedule_details
                              END SCHEDULE_DETAILS  
                      FROM t_export_reports RPT
                             LEFT JOIN t_export_report_instance INSTANCE
                              ON RPT.id_rep = INSTANCE.id_rep
                             LEFT JOIN t_export_schedule SCHEDULE
                              ON INSTANCE.id_rep_instance_id = SCHEDULE.id_rep_instance_id
                             LEFT JOIN ( SELECT 'DAILY' TYPE  ,
                                                id_schedule_daily id_schedule  ,
                                                'Daily at ' || c_exec_time || ' EST' Schedule_details  
                                         FROM t_sch_daily 
                                         UNION ALL 
                                         SELECT 'WEEKLY' ,
                                                id_schedule_weekly ,
                                                'Weekly on ' || c_exec_week_days || ' at ' || c_exec_time || ' EST' 
                                         FROM t_sch_weekly 
                                         UNION ALL 
                                         SELECT 'MONTHLY' ,
                                                id_schedule_monthly ,
                                                'Monthly on the ' || CAST(c_exec_day AS VARCHAR2(4000)) || ' day at ' || c_exec_time || ' EST' 
                                         FROM t_sch_monthly  ) SCHEDDETAIL
                              ON SCHEDULE.c_sch_type = SCHEDDETAIL.TYPE
                             AND SCHEDULE.id_schedule = SCHEDDETAIL.id_schedule
                      ORDER BY RPT.id_rep,
                               dt_activate;
              END;
	 