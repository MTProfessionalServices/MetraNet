
			create table T_PO (
				ID_PO NUMBER(10) not null,
				ID_EFF_DATE NUMBER(10) not null,
				ID_AVAIL NUMBER(10) not null,
				B_USER_SUBSCRIBE CHAR(1) not null,
        B_USER_UNSUBSCRIBE CHAR(1) not null,
        ID_NONSHARED_PL NUMBER(10) not null,
        B_HIDDEN CHAR(1)  default 'N' not null,
        c_POPartitionId int default 1 not null,
        constraint T_PO_PK primary key (ID_PO)
		) 
	 