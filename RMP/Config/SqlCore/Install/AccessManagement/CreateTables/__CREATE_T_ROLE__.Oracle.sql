
					CREATE TABLE t_role (id_role NUMBER(10) NOT NULL, 
					tx_guid RAW(16),
					tx_name NVARCHAR2(255) NOT NULL, 
					tx_desc NVARCHAR2(255) NOT NULL,  
					csr_assignable VARCHAR2(1) NULL,
					subscriber_assignable VARCHAR2(1) NULL,
					CONSTRAINT PK_t_role PRIMARY KEY (id_role))
				