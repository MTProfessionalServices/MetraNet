
				create table t_acc_template (
				id_acc_template int identity (1,1), 
				id_folder int not null,
				id_acc_type int not null,
				dt_crt datetime not null,
				tx_name nvarchar(255) null,
				tx_desc nvarchar(255) null,
				b_ApplyDefaultPolicy char(1) not NULL,
				constraint pk_t_acc_template PRIMARY KEY(id_folder, id_acc_type),
				CONSTRAINT constraint_acctemplateUnique UNIQUE (id_acc_template),
				CONSTRAINT t_acc_template_check1 CHECk (b_ApplyDefaultPolicy = 'Y' OR b_applyDefaultPolicy = 'N')
				)
			 