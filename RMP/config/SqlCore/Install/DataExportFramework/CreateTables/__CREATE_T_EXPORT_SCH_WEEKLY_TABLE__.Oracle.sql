
              CREATE TABLE t_sch_weekly
              (
                id_schedule_weekly NUMBER(10,0)  NOT NULL,
                c_exec_time CHAR(5)  NOT NULL,
                c_exec_week_days VARCHAR2(30)  ,
                c_skip_week_days VARCHAR2(30)  ,
                c_month_to_date NUMBER(1,0) DEFAULT (0) NOT NULL,
                CONSTRAINT PK_t_sch_weekly PRIMARY KEY( id_schedule_weekly )
              )
			 