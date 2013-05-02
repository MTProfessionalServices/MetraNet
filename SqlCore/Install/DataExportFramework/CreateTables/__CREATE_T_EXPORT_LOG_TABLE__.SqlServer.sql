
      CREATE TABLE [dbo].[t_export_log](
	      [id_rep] [int] NULL,
	      [id_rep_instance] [int] NULL,
	      [log_time] [datetime] NULL,
	      [log_type] [varchar](20) NULL,
	      [message] [varchar](500) NULL
      ) ON [PRIMARY]
			 