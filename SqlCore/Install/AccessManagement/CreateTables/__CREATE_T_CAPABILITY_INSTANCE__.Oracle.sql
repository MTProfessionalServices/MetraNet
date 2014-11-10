
				CREATE TABLE t_capability_instance (id_cap_instance number(10) NOT NULL,
				tx_guid RAW(16), 
				id_parent_cap_instance NUMBER(10) NULL,
				id_policy NUMBER(10) NOT NULL,
				id_cap_type NUMBER(10) NOT NULL,
				CONSTRAINT pk_t_capability_instance PRIMARY KEY(id_cap_instance)
			  )
				