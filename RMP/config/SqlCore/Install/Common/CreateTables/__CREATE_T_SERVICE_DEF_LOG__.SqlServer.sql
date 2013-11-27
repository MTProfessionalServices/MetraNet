
			CREATE TABLE t_service_def_log
			(id_service_def int identity not null,
			nm_service_def nvarchar(100) NOT NULL,
			id_revision int NOT NULL,
			tx_checksum varchar(100) NOT NULL,
			nm_table_name varchar(255),
			CONSTRAINT PK_t_service_def_log PRIMARY KEY CLUSTERED (id_service_def))
			