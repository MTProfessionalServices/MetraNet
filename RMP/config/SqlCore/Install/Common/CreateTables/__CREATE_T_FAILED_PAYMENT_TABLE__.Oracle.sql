
			  CREATE TABLE t_failed_payment(
			  id_interval int NOT NULL,
			  id_acc int NOT NULL,
			  id_payment_instrument nvarchar2(36) NOT NULL,
			  dt_original_trans date NOT NULL,
			  nm_description nvarchar2(100) NULL,
			  nm_currency nvarchar2(10) NOT NULL,
			  n_amount number(22,10) NOT NULL,
			  n_retrycount number(10,0) NULL,
			  dt_lastretry date NULL,
			  CONSTRAINT PK_t_failed_payment PRIMARY KEY
			  (
			  id_interval,
			  id_acc,
			  id_payment_instrument
			  )
			  )
		  