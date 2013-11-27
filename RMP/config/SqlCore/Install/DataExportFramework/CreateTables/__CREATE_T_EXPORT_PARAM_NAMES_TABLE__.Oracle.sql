
              CREATE TABLE t_export_param_names
              (
                id_param_name NUMBER(10,0)  NOT NULL,
                c_param_name VARCHAR2(50)  NOT NULL,
                c_param_desc VARCHAR2(50)  ,
                CONSTRAINT PK_t_export_param_names PRIMARY KEY( id_param_name )
              )
			 