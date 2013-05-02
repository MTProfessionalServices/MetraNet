
			CREATE TABLE t_counterpropdef (
						id_prop number(10) not null,
						id_pi number(10) not null,
         					nm_servicedefprop nvarchar2(255) not null,
						n_order number(10) not null,
						nm_preferredcountertype nvarchar2(255) not null,
                                                CONSTRAINT t_counterpropdef_PK primary key (id_prop))
 		