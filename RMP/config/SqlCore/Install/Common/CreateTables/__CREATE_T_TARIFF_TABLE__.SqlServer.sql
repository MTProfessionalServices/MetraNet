
			    CREATE TABLE t_tariff (id_tariff int identity (1000,1) NOT NULL,
				id_enum_tariff int NOT NULL, tx_currency nvarchar(255) NOT NULL,
				CONSTRAINT PK_TARIFF PRIMARY KEY CLUSTERED (id_enum_tariff))
			 