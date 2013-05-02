
			   CREATE TABLE t_enum_data (
			   nm_enum_data nvarchar(255) NOT NULL,
			   id_enum_data int NOT NULL,
			   CONSTRAINT PK_t_enum_data PRIMARY KEY CLUSTERED (id_enum_data),
			   CONSTRAINT C_nm_enum_data UNIQUE (nm_enum_data)
				 )
			 