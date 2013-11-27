
            CREATE TABLE t_wf_be_inst_map (
	            id_instance nvarchar2(36) NOT NULL,
	            workflow_type nvarchar2(250) NOT NULL,
	            id_type_instance nvarchar2(36) NOT NULL,
	            id_workflow_instance nvarchar2(36) NOT NULL
            );
            ALTER TABLE t_wf_be_inst_map ADD CONSTRAINT PK_t_wf_be_inst_map PRIMARY KEY 
	            (id_instance, workflow_type, id_type_instance);

