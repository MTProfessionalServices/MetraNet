
        	create table t_counter_params_metadata ( 	ParamType varchar(256) not null,
																										DBType varchar(256) null,
																										id_counter_meta int not null,
																										id_prop int not null)  
				
					alter table t_counter_params_metadata
					add constraint t_counter_params_metadata_PK primary key (id_prop)   
       