
              CREATE TABLE t_sch_monthly
              (
                id_schedule_monthly NUMBER(10,0)  NOT NULL,
                c_exec_day NUMBER(10,0),
                c_exec_time CHAR(5)  NOT NULL,
                c_exec_first_month_day NUMBER(1,0) DEFAULT (0) NOT NULL,
                c_exec_last_month_day NUMBER(1,0) DEFAULT (0) NOT NULL,
                c_skip_months VARCHAR2(35),
                CONSTRAINT PK_t_sch_monthly PRIMARY KEY( id_schedule_monthly )
              )
			 