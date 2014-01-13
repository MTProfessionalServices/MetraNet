
		create table t_rsched ( 
			id_sched int not null,
			id_pt int not null,
			id_eff_date int not null,
			id_pricelist int not null,
			dt_mod datetime,
			id_pi_template int not null,
			constraint t_rsched_PK primary key (id_sched))
		