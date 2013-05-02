
		  CREATE TABLE t_ps_credit_card (
		  id_payment_instrument [nvarchar](72) NOT NULL,
		  n_credit_card_type int NOT NULL,
		  nm_expirationdt varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  nm_expirationdt_format int NOT NULL,
		  nm_startdate varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  nm_issuernumber varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  CONSTRAINT PK_t_ps_creditcard PRIMARY KEY CLUSTERED
		  (
		  id_payment_instrument
		  ))
	  