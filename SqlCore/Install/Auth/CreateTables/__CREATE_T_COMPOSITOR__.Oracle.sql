
				CREATE TABLE t_compositor (
				id_atomic NUMBER(10) NOT NULL,
				id_composite NUMBER(10) NOT NULL,
				tx_description NVARCHAR2(255) NOT NULL,
				tx_param NVARCHAR2(255) NULL,
				CONSTRAINT PK_t_compositor PRIMARY KEY (id_atomic, id_composite) 
				)
				