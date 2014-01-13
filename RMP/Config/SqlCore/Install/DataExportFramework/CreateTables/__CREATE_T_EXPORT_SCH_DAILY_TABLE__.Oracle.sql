
              CREATE TABLE t_sch_daily
              (
                id_schedule_daily NUMBER(10,0)  NOT NULL,
                c_exec_time CHAR(5)  NOT NULL,
                c_repeat_hour NUMBER(10,0)  ,
                c_exec_start_time CHAR(5)  ,
                c_exec_end_time CHAR(5)  ,
                c_skip_last_day_month NUMBER(1,0) DEFAULT (0) NOT NULL,
                c_skip_first_day_month NUMBER(1,0) DEFAULT (0) NOT NULL,
                c_days_interval NUMBER(10,0) DEFAULT (1) NOT NULL,
                c_month_to_date NUMBER(1,0) DEFAULT (0) NOT NULL,
                CONSTRAINT PK_t_sch_daily PRIMARY KEY( id_schedule_daily )
              )
			 