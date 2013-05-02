
			create table t_effectivedate ( 
				id_eff_date int not null,
				n_begintype int not null,
				dt_start datetime null,
				n_beginoffset int null,
				n_endtype int null,
				dt_end datetime null,
				n_endoffset int null,
				constraint t_effectivedate_PK primary key (id_eff_date))
		