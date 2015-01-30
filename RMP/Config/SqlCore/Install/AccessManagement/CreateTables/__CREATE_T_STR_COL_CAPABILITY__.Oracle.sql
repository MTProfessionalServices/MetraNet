
			  CREATE TABLE t_str_col_capability (
			  str_col_key NUMBER(10) NOT NULL,
			  id_cap_instance int NOT NULL,
			  tx_param_name NVARCHAR2(2000) NULL,
			  tx_op VARCHAR2(1) NULL,
			  param_value NVARCHAR2(255),
			  CONSTRAINT pk_t_str_col_capability PRIMARY KEY(id_cap_instance)
			  )