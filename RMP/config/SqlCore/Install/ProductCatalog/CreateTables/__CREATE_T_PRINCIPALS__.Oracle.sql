
			create table t_principals ( 
				id_principal number(10) not null,
				nm_table_name varchar2(256) not null,
				nm_pk varchar2(100) default 'id_prop',
				nm_sprocname varchar2(256) not null,
				nm_inherit_sprocname varchar2(256),
				constraint t_principals_PK primary key (id_principal))   
	 