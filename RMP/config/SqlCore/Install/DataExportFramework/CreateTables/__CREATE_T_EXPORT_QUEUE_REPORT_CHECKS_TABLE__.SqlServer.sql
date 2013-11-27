
      CREATE TABLE [t_export_queue_report_checks](
	      [source] [varchar](20) NULL,
	      [id_rep] [int] NULL,
	      [id_rep_instance_id] [int] NULL,
	      [id_query] [varchar](100) NULL,
	      [log_error_delay] [int] NULL,
	      [last_status] [varchar](500) NULL,
	      [last_message_log_date] [datetime] NULL,
	      [email_a_warning] [int] NOT NULL,
	      [email_subject] [nvarchar](200) NULL,
	      [email_address] [varchar](200) NULL,
       CONSTRAINT [IX_t_export_queue_report_checks] UNIQUE NONCLUSTERED 
      (
	      [id_rep] ASC,
	      [id_rep_instance_id] ASC,
	      [id_query] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]

      CREATE NONCLUSTERED INDEX [IX_t_export_queue_report_checks_1] ON [t_export_queue_report_checks] 
      (
	      [source] ASC,
	      [id_rep] ASC,
	      [id_rep_instance_id] ASC
      ) ON [PRIMARY]
		 