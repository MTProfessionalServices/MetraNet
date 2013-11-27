
			CREATE TABLE [t_export_schedule](
			[id_rp_schedule] [int] IDENTITY(1,1) NOT NULL,
			[id_rep_instance_id] [int] NOT NULL,
			[id_schedule] [int] NOT NULL,
			[c_sch_type] [varchar](10) NOT NULL,
			[dt_crt] [datetime] NOT NULL,
 			CONSTRAINT [PK_t_export_Schedule] PRIMARY KEY CLUSTERED 
			(
			[id_rp_schedule] ASC
			) ON [PRIMARY]
			) ON [PRIMARY]
			 