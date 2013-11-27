
			CREATE TABLE t_composite_capability_type 
				(id_cap_type NUMBER(10) NOT NULL,
				tx_guid RAW(16) NOT NULL,
				tx_name NVARCHAR2(255) NOT NULL,
				tx_desc NVARCHAR2(255)NOT NULL,
				tx_progid NVARCHAR2(255) NOT NULL,
				tx_editor NVARCHAR2(255) NULL,
				csr_assignable VARCHAR2(1) NOT NULL,
				subscriber_assignable VARCHAR2(1) NOT NULL,
				multiple_instances  VARCHAR2(1) NOT NULL,
				umbrella_sensitive  VARCHAR2(1) NOT NULL,
				CONSTRAINT pk_composite_capability_type PRIMARY KEY (id_cap_type))
				