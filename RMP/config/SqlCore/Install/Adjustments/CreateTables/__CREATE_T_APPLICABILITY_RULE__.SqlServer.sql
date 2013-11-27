
	create table t_applicability_rule (
	id_prop int not null,
	tx_guid VARBINARY(16) null,
	id_formula INT NOT NULL,
	constraint pk_t_applicability_rule primary key(id_prop)
)
		