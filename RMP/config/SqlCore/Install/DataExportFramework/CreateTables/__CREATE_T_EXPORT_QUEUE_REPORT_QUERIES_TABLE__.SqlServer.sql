
      CREATE TABLE [t_export_queue_report_queries](
	      [id_query] [varchar](100) NULL,
	      [descr] [varchar](500) NULL,
	      [query_string] [varchar](7000) NULL,
       CONSTRAINT [IX_t_export_queue_report_queries] UNIQUE NONCLUSTERED 
      (
	      [id_query] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]
			 