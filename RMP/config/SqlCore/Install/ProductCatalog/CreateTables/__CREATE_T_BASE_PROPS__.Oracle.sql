
			create table T_BASE_PROPS (
				ID_PROP NUMBER(10) not null,
				N_KIND NUMBER(10) not null,
				N_NAME NUMBER(10) ,
				N_DESC NUMBER(10) ,
                                NM_NAME NVARCHAR2(255),
                                NM_DESC NVARCHAR2(2000),
				B_APPROVED CHAR(1) ,
				B_ARCHIVE CHAR(1) ,
				N_DISPLAY_NAME NUMBER(10) ,
				NM_DISPLAY_NAME NVARCHAR2(255) ,
				 constraint T_BASE_PROPS_PK primary key (ID_PROP) )
		
	 