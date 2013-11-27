
      CREATE TABLE [t_sch_daily](
	      [id_schedule_daily] [int] IDENTITY(1,1) NOT NULL,
	      [c_exec_time] [char](5) NOT NULL,
	      [c_repeat_hour] [int] NULL,
	      [c_exec_start_time] [char](5) NULL,
	      [c_exec_end_time] [char](5) NULL,
	      [c_skip_last_day_month] [bit] NOT NULL CONSTRAINT [DF_t_sch_daily_c_skip_last_day_month]  DEFAULT (0),
	      [c_skip_first_day_month] [bit] NOT NULL CONSTRAINT [DF_t_sch_daily_c_skip_first_day_month]  DEFAULT (0),
	      [c_days_interval] [int] NOT NULL CONSTRAINT [DF_t_sch_daily_c_days_interval]  DEFAULT (1),
	      [c_month_to_date] [bit] NOT NULL CONSTRAINT [DF_t_sch_daily_c_month_to_date]  DEFAULT (0),
       CONSTRAINT [PK_t_sch_daily] PRIMARY KEY CLUSTERED 
      (
	      [id_schedule_daily] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]
			 