
			 	CREATE TABLE t_decimal_capability (
				id_cap_instance NUMBER(10) NOT NULL,
				tx_param_name NVARCHAR2(2000) NULL,
				tx_op VARCHAR2(2) NOT NULL,
				param_value NUMBER(22,10),
                CONSTRAINT pk_t_decimal_capability PRIMARY KEY(id_cap_instance)
				)
				