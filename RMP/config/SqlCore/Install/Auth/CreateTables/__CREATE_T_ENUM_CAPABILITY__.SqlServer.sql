
				CREATE TABLE t_enum_capability (
				id_cap_instance int NOT NULL,
				tx_param_name nvarchar(2000) NULL,
				tx_op VARCHAR(1) NOT NULL,
				param_value int,
				CONSTRAINT pk_t_enum_capability PRIMARY KEY(id_cap_instance)
				)
			