
				CREATE TABLE t_principal_policy
				(id_policy int NOT NULL identity(1, 1),
				id_acc int NULL,
				id_role int NULL,
				policy_type VARCHAR(1),
				tx_name nvarchar(255),
				tx_desc nvarchar(255),
				CONSTRAINT pk_t_principal_policy PRIMARY KEY (id_policy),
				CONSTRAINT c_principal_policy CHECK(id_acc IS NULL OR id_role IS NULL))
			