
              CREATE TABLE t_export_default_param_values
              (
                id_param_values NUMBER(10,0)  NOT NULL,
                id_rep_instance_id NUMBER(10,0)  NOT NULL,
                id_param_name NUMBER(10,0)  NOT NULL,
                c_param_value VARCHAR2(1000)  NOT NULL,
                CONSTRAINT PK_t_export_param_values PRIMARY KEY( id_param_values )
              )
			 