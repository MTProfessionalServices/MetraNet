
				CREATE TABLE t_capability_instance 
				(id_cap_instance int NOT NULL identity(1, 1), 
				tx_guid varbinary(16),
				id_parent_cap_instance int NULL,
				id_policy int NOT NULL,
				id_cap_type int NOT NULL,
				CONSTRAINT pk_t_capability_instance PRIMARY KEY(id_cap_instance)
				)
				