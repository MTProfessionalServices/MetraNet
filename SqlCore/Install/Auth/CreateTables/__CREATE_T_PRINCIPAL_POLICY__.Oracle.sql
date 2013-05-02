
					CREATE TABLE t_principal_policy (id_policy NUMBER(10) NOT NULL,
					id_acc number(10) NULL,
					id_role number(10) NULL,
					policy_type VARCHAR2(1),
					tx_name NVARCHAR2(255), 
					tx_desc NVARCHAR2(255),  
					CONSTRAINT pk_t_principal_policy PRIMARY KEY (id_policy),
					CONSTRAINT c_principal_policy CHECK(id_acc IS NULL OR id_role IS NULL))
				