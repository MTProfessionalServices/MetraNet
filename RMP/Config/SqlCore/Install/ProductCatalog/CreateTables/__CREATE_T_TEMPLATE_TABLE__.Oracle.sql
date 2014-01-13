
			create table t_pi_template ( 
				id_template number(10) not null,
				id_template_parent number(10),
				id_pi number(10) not null,
                                constraint t_pi_template_PK primary key (id_template))
	 