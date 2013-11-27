
			CREATE TABLE t_account_view_log
			(id_account_view int identity not null,
			nm_account_view nvarchar(100) NOT NULL,
			id_revision int NOT NULL,
			tx_checksum varchar(100) NOT NULL,
			nm_table_name varchar(255),
			constraint pk_t_account_view_log primary key(id_account_view))
			