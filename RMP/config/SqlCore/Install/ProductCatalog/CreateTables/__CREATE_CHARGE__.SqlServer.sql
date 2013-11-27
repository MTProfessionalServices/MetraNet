
			create table t_charge ( 
				id_charge int not null,
				dt_modified datetime,
				nm_description nvarchar(255),
				id_pi int not null,
				id_amt_prop int not null,
				constraint pk_t_charge primary key(id_charge)
      )
	 