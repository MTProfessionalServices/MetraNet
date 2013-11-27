
				CREATE TABLE t_payment_instrument(
				id_payment_instrument nvarchar2(36) NOT NULL,
				id_acct number(10) NULL,
				n_payment_method_type int NOT NULL,
				nm_truncd_acct_num nvarchar2(50) NOT NULL,
				tx_hash nvarchar2(255) NOT NULL,
				id_creditcard_type number(10) NULL,
				n_account_type number(10) NULL,
				nm_exp_date nvarchar2(10) NULL,
				nm_exp_date_format number(10) NULL,
				nm_first_name nvarchar2(50) NOT NULL,
				nm_middle_name nvarchar2(50) NULL,
				nm_last_name nvarchar2(50) NOT NULL,
				nm_address1 nvarchar2(255) NOT NULL,
				nm_address2 nvarchar2(255) NULL,
				nm_city nvarchar2(100) NOT NULL,
				nm_state nvarchar2(40) NULL,
				nm_zip nvarchar2(10) NULL,
				id_country number(10) NOT NULL,
				id_priority number(10) NULL,
				n_max_charge_per_cycle number(22,10) NULL,
				dt_created date NOT NULL,
				CONSTRAINT PK_t_payment_instrument PRIMARY KEY
				(
				id_payment_instrument
				)
				)
			