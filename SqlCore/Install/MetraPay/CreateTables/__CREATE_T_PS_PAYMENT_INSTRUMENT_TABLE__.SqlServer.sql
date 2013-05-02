
		  CREATE TABLE t_ps_payment_instrument (
		  id_payment_instrument [nvarchar](72) NOT NULL,
		  n_payment_method_type int NOT NULL,
		  nm_account_number varchar(2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  nm_first_name nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  nm_middle_name nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  nm_last_name nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  nm_address1 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  nm_address2 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  nm_city nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  nm_state nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  nm_zip nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  id_country int NOT NULL,
		  CONSTRAINT PK_t_ps_payment_instrument PRIMARY KEY CLUSTERED
		  (
		  id_payment_instrument
		  ))
	  