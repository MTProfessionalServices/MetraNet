
			CREATE TABLE [t_export_param_names](
			[id_param_name] [int] IDENTITY(1,1) NOT NULL,
			[c_param_name] [varchar](50) NOT NULL,
			[c_param_desc] [varchar](50) NULL,
 			CONSTRAINT [PK_t_export_param_names] PRIMARY KEY CLUSTERED 
			(
			[id_param_name] ASC
			) ON [PRIMARY]
			) ON [PRIMARY]
			 