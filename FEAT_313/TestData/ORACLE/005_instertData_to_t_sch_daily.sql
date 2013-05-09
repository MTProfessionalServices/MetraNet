whenever sqlerror exit 2;

DECLARE
BEGIN
	
INSERT ALL	
-- id_schedule_dayli = 1
	INTO t_sch_daily
           (c_exec_time
           ,c_repeat_hour
           ,c_exec_start_time
           ,c_exec_end_time
           ,c_skip_last_day_month
           ,c_skip_first_day_month
           ,c_days_interval
           ,c_month_to_date)
     VALUES
           ('07:35'
           ,0
           ,'07:35'
           ,'07:35'
           ,0
           ,0
           ,1
           ,0)
           
-- id_schedule_dayli = 2           
	INTO t_sch_daily
           (c_exec_time
           ,c_repeat_hour
           ,c_exec_start_time
           ,c_exec_end_time
           ,c_skip_last_day_month
           ,c_skip_first_day_month
           ,c_days_interval
           ,c_month_to_date)
     VALUES
           ('08:35'
           ,0
           ,'08:35'
           ,'08:35'
           ,0
           ,0
           ,1
           ,0)       
 
SELECT * FROM dual;
COMMIT;           
END;
 /