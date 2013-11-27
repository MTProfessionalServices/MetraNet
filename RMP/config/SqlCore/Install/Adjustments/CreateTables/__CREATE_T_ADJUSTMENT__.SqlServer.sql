
	create table t_adjustment (
	id_prop int not null,
	tx_guid VARBINARY(16) null,
	id_pi_template int null,
	id_pi_instance int null,
	id_adjustment_type int not null,
	constraint pk_t_adjustment primary key(id_prop),
	CONSTRAINT aj_template_instance1 CHECK 	((id_pi_template IS NOT NULL AND id_pi_instance IS NULL) OR
	(id_pi_template IS NULL AND id_pi_instance IS NOT NULL))
  )
		