
			create table t_ep_map ( 
				id_principal int not null,
				nm_ep_tablename nvarchar(256) not null,
				nm_desc nvarchar(256) not null,
				b_core char(1) not null,
				constraint t_ep_map_PK primary key (id_principal,nm_ep_tablename)
				) 
	 