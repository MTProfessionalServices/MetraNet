
				CREATE TABLE t_str_col_capability (
				str_col_key int NOT NULL identity(1, 1),
				id_cap_instance int NOT NULL,
				tx_param_name nvarchar(2000) NULL,
				tx_op VARCHAR(1) NULL,
				param_value NVARCHAR(255),
				CONSTRAINT pk_t_str_col_capability PRIMARY KEY(str_col_key)
				)
			