
			create table t_charge_prop ( 
		        id_charge_prop int not null identity,
				id_charge int not null,
				id_prod_view_prop int not null,
				constraint pk_t_charge_prop primary key(id_charge_prop)
				)
	 