
				create table t_acc_template (
				id_acc_template NUMBER(10,0) not null,
				id_folder NUMBER(10,0) not null,
				id_acc_type NUMBER(10) not null,
				dt_crt date not null,
				tx_name nvarchar2(255) null,
				tx_desc nvarchar2(255) null,
				b_ApplyDefaultPolicy char(1) not NULL,
        CONSTRAINT pk_acctemplate PRIMARY KEY (id_folder,id_acc_type),
        CONSTRAINT pk_acctemplateUnique UNIQUE (id_acc_template),
				CONSTRAINT t_acc_template_check1 CHECk (b_ApplyDefaultPolicy = 'Y' OR b_applyDefaultPolicy = 'N')
				)
			 