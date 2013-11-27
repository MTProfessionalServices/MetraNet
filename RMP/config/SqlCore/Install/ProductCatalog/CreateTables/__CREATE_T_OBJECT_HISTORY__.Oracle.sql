
			create table t_object_history ( 
				id_prop NUMBER(10),
				nm_tablename VARCHAR2(100),
				n_version char(10) not null,
				tx_checksum varchar2(100) not null)
		