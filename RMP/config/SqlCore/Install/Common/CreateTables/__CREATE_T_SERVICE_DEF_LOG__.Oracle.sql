
			CREATE TABLE t_service_def_log
			(
			id_service_def number(10) not null,
			nm_service_def nvarchar2(100) NOT NULL,
			id_revision number(10) NOT NULL,
			tx_checksum varchar2(100) NOT NULL,
      nm_table_name varchar2(255),
			CONSTRAINT PK_t_service_def_log PRIMARY KEY (id_service_def))
			