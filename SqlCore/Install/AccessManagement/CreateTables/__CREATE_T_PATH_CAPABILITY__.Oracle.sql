
          CREATE TABLE t_path_capability (
          id_cap_instance number(10) NOT NULL,
          tx_param_name NVARCHAR2(2000) NULL,
          tx_op VARCHAR2(1) NULL,
          param_value NVARCHAR2(2000),
			  constraint pk_t_path_capability PRIMARY KEY(id_cap_instance)
          )
        