
				CREATE TABLE t_path_capability (
				id_cap_instance int NOT NULL,
				tx_param_name nvarchar(2000) NULL,
				tx_op VARCHAR(1) NULL,
				param_value NVARCHAR(2000),
				CONSTRAINT pk_t_path_capability PRIMARY KEY(id_cap_instance)
				)
			