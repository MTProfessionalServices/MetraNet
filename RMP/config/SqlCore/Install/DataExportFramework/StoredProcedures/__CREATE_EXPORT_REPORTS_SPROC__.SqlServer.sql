

      CREATE         PROC EXPORT_REPORTS 
                                    
      AS 
      BEGIN 
            /*
            OPEN
            1.    None
            
            CLOSED
            1.    None
 
            /* exec Export_reports */
 
            */
 
            SET NOCOUNT ON
 
            SELECT RPT.id_rep as 'REPORT ID', RPT.c_report_title as 'REPORT TITLE', 
            CASE WHEN ISNULL(INSTANCE.c_rep_instance_desc, '0') = '0' THEN '!!! - No Instance Defined - Ad Hoc Only' ELSE INSTANCE.c_rep_instance_desc END as 'REPORT INSTANCE DESC', 
            INSTANCE.dt_activate as 'DATE ACTIVATED', INSTANCE.dt_last_run as 'LAST RUN', INSTANCE.dt_next_run as 'NEXT RUN',
            INSTANCE.c_rep_output_type as 'OUTPUT TYPE', INSTANCE.c_rep_distrib_type as 'DISTRIBUTION TYPE', INSTANCE.c_report_destn as 'DISTRIBUTION DESTINATION', 
            dbo.ExportGetParmsAndValues(INSTANCE.id_rep_instance_id) as 'SET PARMS', ISNULL(INSTANCE.c_exec_type, 'ad-hoc') as 'TYPE',
            CASE WHEN ISNULL(SCHEDDETAIL.schedule_details, '0') = '0' AND INSTANCE.c_exec_type = 'SCH' THEN '!!! - No Schedule is Set Up' WHEN INSTANCE.c_exec_type = 'EOP' THEN 'EOP Step - ' + c_eop_step_instance_name ELSE SCHEDDETAIL.schedule_details END as 'SCHEDULE DETAILS'     
       
            FROM t_export_reports RPT
            LEFT OUTER JOIN t_export_report_instance INSTANCE ON RPT.id_rep = INSTANCE.id_rep 
            LEFT OUTER JOIN t_export_schedule SCHEDULE ON INSTANCE.id_rep_instance_id = SCHEDULE.id_rep_instance_id  
            LEFT OUTER JOIN 
                        (SELECT 'DAILY' as TYPE, id_schedule_daily as id_schedule, 'Daily at ' + c_exec_time + ' EST' as Schedule_details 
                        FROM t_sch_daily
                        UNION ALL
                        SELECT 'WEEKLY', id_schedule_weekly, 'Weekly on ' + c_exec_week_days + ' at ' + c_exec_time + ' EST'  
                        FROM t_sch_weekly
                        UNION ALL
                        SELECT 'MONTHLY', id_schedule_monthly, 'Monthly on the ' + CONVERT(VARCHAR, c_exec_day) + ' day at ' + c_exec_time + ' EST'
                        FROM t_sch_monthly) SCHEDDETAIL ON SCHEDULE.c_sch_type = SCHEDDETAIL.type AND SCHEDULE.id_schedule = SCHEDDETAIL.id_schedule
            ORDER BY RPT.id_rep, dt_activate
      END
	 