
	      CREATE TABLE [t_export_default_param_values](
	      [id_param_values] [int] IDENTITY(1,1) NOT NULL,
	      [id_rep_instance_id] [int] NOT NULL,
	      [id_param_name] [int] NOT NULL,
	      [c_param_value] [varchar](1000) NOT NULL,
       CONSTRAINT [PK_t_export_param_values] PRIMARY KEY CLUSTERED 
      (
	      [id_param_values] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]
			 