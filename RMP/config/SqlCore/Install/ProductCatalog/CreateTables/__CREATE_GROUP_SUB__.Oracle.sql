
			create table t_group_sub (
			id_group NUMBER(10) not null,
			id_group_ext raw(16) not null,
			tx_name nvarchar2(255) not null,
			tx_desc nvarchar2(255) null,
			b_visable char(1) not null,
      b_supportgroupops char(1) not null,
			id_usage_cycle NUMBER(10) not null,
			b_proportional char(1) not null,
			id_corporate_account number(10) not null,
			id_discountAccount number(10) null,
			constraint T_GSUB_PK primary key (ID_group),
			CONSTRAINT t_group_sub_check1 CHECK (b_visable = 'Y' OR b_visable = 'N'),
			constraint t_group_sub_check2 CHECK (b_proportional = 'Y' or b_proportional = 'N'),
      CONSTRAINT t_group_sub_check3 CHECK (b_supportgroupops = 'Y' or b_supportgroupops = 'N'),
      CONSTRAINT t_group_sub_check4 UNIQUE (tx_name,id_corporate_account)
			)
	 