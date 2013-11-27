
	create table t_adjustment_type (
	id_prop int not null,
	tx_guid VARBINARY(16) null,
	id_pi_type int not null,
	n_adjustmentType int not null, -- adjustment enumerated type
	b_supportBulk char(1) not null,
	id_formula INT NOT NULL,
	tx_default_desc ntext null,
	constraint pk_t_adjustment_type primary key(id_prop),
	n_composite_adjustment int NOT NULL CONSTRAINT 
	DF_t_adjustment_type_t_composite_adjustment DEFAULT (0),
	CONSTRAINT adj_bulkcheck CHECK 	(b_supportBulk = 'Y' or b_supportBulk = 'N')
	)
		