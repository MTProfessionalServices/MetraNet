
			CREATE TABLE t_account_view_log
			(id_account_view number(10) not null,
			nm_account_view nvarchar2(100) NOT NULL,
			id_revision number(10) NOT NULL,
			tx_checksum varchar2(100) NOT NULL,
			nm_table_name varchar2(255),
			constraint pk_t_account_view_log primary key(id_account_view))
			