
				CREATE TABLE t_role
				(id_role int NOT NULL identity(1, 1),
				tx_guid varbinary(16),
				tx_name nvarchar(255) NOT NULL,
				tx_desc nvarchar(255) NOT NULL,
				csr_assignable VARCHAR(1) NULL,
				subscriber_assignable VARCHAR(1) NULL,
				CONSTRAINT PK_t_role PRIMARY KEY (id_role))
			