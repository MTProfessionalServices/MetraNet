
			create table t_pi ( 
				id_pi int not null,
				id_parent int null,
				nm_servicedef varchar(100) not null,  
				nm_productview varchar(100),
				n_servicedef int null,  
				n_productview int null,
				b_constrain_cycle char(1),
				constraint t_pi_PK primary key (id_pi))
	 