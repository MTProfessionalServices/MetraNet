
			create table T_RSCHED (
				ID_SCHED NUMBER(10) not null,
				ID_PT NUMBER(10) not null,
				ID_EFF_DATE NUMBER(10) not null,
				ID_PRICELIST NUMBER(10) not null, 
        DT_MOD DATE NULL,
        ID_PI_TEMPLATE NUMBER(10) NOT NULL,constraint T_RSCHED_PK primary key (ID_SCHED) ) 
	 