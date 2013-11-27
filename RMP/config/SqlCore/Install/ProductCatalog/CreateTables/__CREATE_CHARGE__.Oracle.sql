
			create table t_charge ( 
        id_charge number(10) not null primary key,
				dt_modified date,
				nm_description nvarchar2(255),
				id_pi number(10) not null,
				id_amt_prop number(10) not null
      )
	 