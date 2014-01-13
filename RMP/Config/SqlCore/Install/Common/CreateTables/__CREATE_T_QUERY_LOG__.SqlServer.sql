
			CREATE TABLE [t_query_log] (
				[c_id] [int] IDENTITY (1, 1) NOT NULL ,
				[c_groupid] [varchar] (50) NOT NULL ,
				[c_id_view] [int] NULL ,
				[c_old_schema] [varchar] (8000) NOT NULL ,
				[c_query] [nvarchar] (4000) NOT NULL ,
				[c_timestamp] [datetime] NOT NULL CONSTRAINT [DF_t_query_log_c_timestamp] DEFAULT (getdate())
			) ON [PRIMARY]
		