
			     CREATE TABLE t_profile (id_profile int NOT NULL,
				 nm_tag nvarchar(32) NOT NULL,
				 val_tag nvarchar(80) NULL, tx_desc nvarchar(255) NULL,
				 CONSTRAINT PK_t_profile PRIMARY KEY CLUSTERED (id_profile,
				 nm_tag))
			 