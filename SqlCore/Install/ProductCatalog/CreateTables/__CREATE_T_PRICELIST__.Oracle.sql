
			create table T_PRICELIST (
				ID_PRICELIST NUMBER(10) not null,
				n_type number(10) not null,
				NM_CURRENCY_CODE NVARCHAR2(10) not null,
				c_PLPartitionId int null,
        constraint T_PRICELIST_PK primary key (ID_PRICELIST) ) 
	 