
			create table T_EFFECTIVEDATE (
				ID_EFF_DATE NUMBER(10) not null,
				N_BEGINTYPE NUMBER(10) not null,
				DT_START DATE,
                                N_BEGINOFFSET NUMBER(10),
                                N_ENDTYPE NUMBER(10),
				DT_END DATE,
				N_ENDOFFSET NUMBER(10), constraint T_EFFECTIVEDATE_PK primary key (ID_EFF_DATE) ) 
	 