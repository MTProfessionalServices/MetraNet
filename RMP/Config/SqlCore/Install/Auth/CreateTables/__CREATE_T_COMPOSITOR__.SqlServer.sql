
				CREATE TABLE t_compositor (
				id_atomic int NOT NULL,
				id_composite int NOT NULL,
				tx_description nvarchar(255) NOT NULL,
				tx_param nvarchar(255),
				CONSTRAINT PK_t_compositor PRIMARY KEY (id_atomic, id_composite)
				)
			