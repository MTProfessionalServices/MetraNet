
			create table t_calc_formula(
			id_formula int identity(1, 1) not null,
			tx_formula ntext not null,
			id_engine INT NOT NULL,
			constraint pk_t_calc_formula primary key(id_formula)
			)
		