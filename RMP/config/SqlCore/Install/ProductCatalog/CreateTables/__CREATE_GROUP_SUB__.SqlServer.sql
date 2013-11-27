
			create table t_group_sub (
			id_group int identity(1,1),
			id_group_ext varbinary(16) not null,
			tx_name nvarchar(255) not null,
			tx_desc nvarchar(255) null,
			b_visable char(1) not null,
			b_supportgroupops char(1) not null,
			id_usage_cycle int not null,
			b_proportional char(1) not null,
			id_corporate_account int not null,
			id_discountAccount int null,
			CONSTRAINT pk_t_group_sub  PRIMARY KEY(id_group),
			CONSTRAINT t_group_sub_check1 CHECK (b_visable = 'Y' OR b_visable = 'N'),
			CONSTRAINT t_group_sub_check2 CHECK (b_proportional = 'Y' or b_proportional = 'N'),
			CONSTRAINT t_group_sub_check3 CHECK (b_supportgroupops = 'Y' or b_supportgroupops = 'N'),
			CONSTRAINT t_group_sub_check4 UNIQUE (tx_name,id_corporate_account)
			)
		 