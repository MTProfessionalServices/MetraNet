
			create table t_principals ( 
				id_principal int not null,
				nm_table_name varchar(256) not null,
				nm_pk varchar(100) default 'id_prop',
				nm_sprocname varchar(256) not null,
				nm_inherit_sprocname varchar(256) null,
				constraint t_principals_PK primary key (id_principal),
				CONSTRAINT C_unique_t_principals UNIQUE (id_principal,nm_table_name))
	 