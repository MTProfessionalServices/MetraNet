
			CREATE TABLE t_counterpropdef ( 
													id_prop int not null,
													id_pi int not null,
													nm_servicedefprop nvarchar(255) not null,
													n_order int not null,
													nm_preferredcountertype nvarchar(255) not null,
													CONSTRAINT t_counterpropdef_PK primary key (id_prop))
 		