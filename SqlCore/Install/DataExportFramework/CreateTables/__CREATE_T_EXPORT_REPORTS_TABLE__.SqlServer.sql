
			CREATE TABLE [t_export_reports](
			[id_rep] [int] IDENTITY(1,1) NOT NULL,
			[c_report_title] [varchar](50) NOT NULL,
			[c_rep_type] [varchar](50) NOT NULL,
			[c_rep_def_source] [varchar](100) NULL,
			[c_rep_query_tag] [varchar](100) NULL,
			[c_report_desc] [varchar](255) NULL,
			[c_prevent_adhoc_execution] [INT] NULL CONSTRAINT [DF_t_export_report_c_prevent_adhoc_execution]  DEFAULT (0),
 			CONSTRAINT [PK_t_export_reports] PRIMARY KEY CLUSTERED 
			(
				[id_rep] ASC
			) ON [PRIMARY]
			) ON [PRIMARY]
			 