
		create table t_aggregate ( 
			id_prop int not null,
			id_usage_cycle int,
			id_cycle_type int
			)  
		
		alter table t_aggregate
			add constraint t_aggregate_PK primary key (id_prop)   
		