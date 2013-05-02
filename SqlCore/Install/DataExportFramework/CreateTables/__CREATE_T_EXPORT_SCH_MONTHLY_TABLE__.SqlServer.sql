
      CREATE TABLE [t_sch_monthly](
	      [id_schedule_monthly] [int] IDENTITY(1,1) NOT NULL,
	      [c_exec_day] [int] NULL,
	      [c_exec_time] [char](5) NOT NULL,
	      [c_exec_first_month_day] [bit] NOT NULL CONSTRAINT [DF_t_sch_monthly_c_exec_first_month_day]  DEFAULT (0),
	      [c_exec_last_month_day] [bit] NOT NULL CONSTRAINT [DF_t_sch_monthly_c_exec_last_month_day]  DEFAULT (0),
	      [c_skip_months] [varchar](35) NULL,
       CONSTRAINT [PK_t_sch_monthly] PRIMARY KEY CLUSTERED 
      (
	      [id_schedule_monthly] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]
			 