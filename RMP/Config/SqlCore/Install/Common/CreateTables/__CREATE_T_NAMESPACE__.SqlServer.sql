
			    CREATE TABLE t_namespace (
				nm_space nvarchar (40) NOT NULL,
				tx_desc nvarchar(255) NOT NULL,
				nm_method nvarchar(255) NULL,
				tx_typ_space nvarchar(40) NOT NULL
           		CONSTRAINT PK_t_NAMESPACE PRIMARY KEY CLUSTERED (nm_space))
			 