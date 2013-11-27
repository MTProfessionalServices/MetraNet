
				CREATE TABLE t_policy_role (id_policy NUMBER(10) NOT NULL, 
				id_role NUMBER(10) NOT NULL,
				CONSTRAINT pk_t_policy_role PRIMARY KEY(id_policy, id_role) 
				)
				