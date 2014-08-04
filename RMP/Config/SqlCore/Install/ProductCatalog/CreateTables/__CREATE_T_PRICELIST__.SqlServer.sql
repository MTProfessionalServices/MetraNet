
			create table t_pricelist ( 
				id_pricelist int not null,
				n_type int not null,
				nm_currency_code nvarchar(10) not null,
				c_PLPartitionId int not null default 1,
				constraint t_pricelist_PK primary key (id_pricelist))   
	 