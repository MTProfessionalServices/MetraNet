
			      CREATE TABLE [dbo].[t_wf_be_inst_map] (
	            [id_instance] [nvarchar](36) NOT NULL,
	            [workflow_type] [nvarchar](250) NOT NULL,
	            [id_type_instance] [nvarchar](36) NOT NULL,
	            [id_workflow_instance] [nvarchar](36) NOT NULL
            ) ON [PRIMARY]
            ALTER TABLE [t_wf_be_inst_map] ADD CONSTRAINT PK_t_wf_be_inst_map PRIMARY KEY CLUSTERED 
	            (id_instance, workflow_type, id_type_instance) ON [PRIMARY]
				