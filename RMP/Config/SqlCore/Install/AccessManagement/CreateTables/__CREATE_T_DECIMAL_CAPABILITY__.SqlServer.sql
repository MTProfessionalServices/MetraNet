
				CREATE TABLE t_decimal_capability (
				id_cap_instance int NOT NULL,
				tx_param_name nvarchar(2000) NULL,
				tx_op VARCHAR(2) NOT NULL,
				param_value numeric(22,10),
				CONSTRAINT pk_t_decimal_capability PRIMARY KEY(id_cap_instance)
				)
			