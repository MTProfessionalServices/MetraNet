
			create table T_PI (
				ID_PI NUMBER(10) not null,
				ID_PARENT NUMBER(10) ,
				NM_SERVICEDEF VARCHAR2(100) not null,NM_PRODUCTVIEW VARCHAR2(100),
				N_SERVICEDEF NUMBER(10), N_PRODUCTVIEW NUMBER(10),
				b_constrain_cycle char(1),
                                constraint T_PI_PK primary key (ID_PI) ) 
		
	 