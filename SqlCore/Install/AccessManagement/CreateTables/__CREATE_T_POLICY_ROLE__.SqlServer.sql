
				CREATE TABLE t_policy_role 
				(id_policy int NOT NULL, 
				id_role int NOT NULL,
				CONSTRAINT pk_t_policy_role PRIMARY KEY(id_policy, id_role) 
				)
				