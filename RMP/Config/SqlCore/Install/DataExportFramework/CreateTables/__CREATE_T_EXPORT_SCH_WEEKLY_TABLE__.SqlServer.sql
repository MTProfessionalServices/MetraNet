
      CREATE TABLE [t_sch_weekly](
	      [id_schedule_weekly] [int] IDENTITY(1,1) NOT NULL,
	      [c_exec_time] [char](5) NOT NULL,
	      [c_exec_week_days] [varchar](27) NULL,
	      [c_skip_week_days] [varchar](27) NULL,
	      [c_month_to_date] [bit] NOT NULL CONSTRAINT [DF_t_sch_weekly_c_month_to_date]  DEFAULT (0),
       CONSTRAINT [PK_t_sch_weekly] PRIMARY KEY CLUSTERED 
      (
	      [id_schedule_weekly] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]
			 