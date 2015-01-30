
			create table t_sub (
			id_sub int not null,
			id_sub_ext varbinary(16) not null,
			id_acc int null,
			id_po int not null,
			dt_crt datetime,
			vt_start datetime not null,
			vt_end datetime not null,
			id_group int null,
      		tx_quoting_batch varbinary(16) NULL,
			CONSTRAINT pk_t_sub  PRIMARY KEY(id_sub),
			CONSTRAINT date_sub_check1 check ( vt_start <= vt_end)
			)
				
