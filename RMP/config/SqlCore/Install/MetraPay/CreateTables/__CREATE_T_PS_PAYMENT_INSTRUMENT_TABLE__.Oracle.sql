
		  CREATE TABLE t_ps_payment_instrument (
		  id_payment_instrument VARCHAR2(40) NOT NULL,
		  n_payment_method_type number(10) NOT NULL,
		  nm_account_number varchar2(2048) NULL,
		  nm_first_name nvarchar2(50) NOT NULL,
		  nm_middle_name nvarchar2(50) NOT NULL,
		  nm_last_name nvarchar2(50) NOT NULL,
		  nm_address1 nvarchar2(255) NOT NULL,
		  nm_address2 nvarchar2(255) NULL,
		  nm_city nvarchar2(100) NOT NULL,
		  nm_state nvarchar2(40) NULL,
		  nm_zip nvarchar2(10) NULL,
		  id_country number(10) NOT NULL,
		  PRIMARY KEY (id_payment_instrument))
	  