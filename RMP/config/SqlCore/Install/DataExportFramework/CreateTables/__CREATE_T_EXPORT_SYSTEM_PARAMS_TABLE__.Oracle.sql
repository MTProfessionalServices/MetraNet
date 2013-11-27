
              CREATE TABLE t_export_system_parms
              (
                parm_name VARCHAR2(50)  NOT NULL,
                parm_value VARCHAR2(1024)  NOT NULL,
                CONSTRAINT PK_t_export_system_parms PRIMARY KEY( parm_name )
              )
			 