
		create table t_discount ( 
			id_prop int not null,
			n_value_type int not null,
			id_usage_cycle int,
			id_cycle_type int,
			id_distribution_cpd int,
			constraint t_discount_PK primary key (id_prop)) 
		