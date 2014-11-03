
				CREATE TABLE t_composite_capability_type
				(id_cap_type int NOT NULL identity(1, 1),
				tx_guid varbinary(16) not null,
				tx_name nvarchar(255) NOT NULL,
				tx_desc nvarchar(255) NOT NULL,
				tx_progid nvarchar(255) NOT NULL,
				tx_editor nvarchar(255) NULL,
				csr_assignable VARCHAR(1) NOT NULL,
				subscriber_assignable VARCHAR(1) NOT NULL,
				multiple_instances VARCHAR(1) NOT NULL,
				umbrella_sensitive  VARCHAR(1) NOT NULL,
				CONSTRAINT pk_composite_capability_type PRIMARY KEY (id_cap_type))
			