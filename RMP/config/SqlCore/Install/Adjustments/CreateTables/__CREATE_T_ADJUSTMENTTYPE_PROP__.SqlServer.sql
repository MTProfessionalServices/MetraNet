
    create table t_adjustment_type_prop
	    (id_prop int not null,
	     n_direction int not null,
	     nm_datatype varchar(255) not null,
	     id_adjustment_type int not null,
	     constraint pk_t_adjustment_type_prop primary key(id_prop),
	     )
		