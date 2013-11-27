
			  CREATE TABLE t_pending_payment_trans(
			  id_pending_payment int NOT NULL,
			  id_interval int NULL,
			  id_acc int NOT NULL,
			  id_payment_instrument nvarchar2(36) NOT NULL,
			  nm_description nvarchar2(100) NULL,
			  nm_currency nvarchar2(10) NOT NULL,
			  n_amount number(22,10) NOT NULL,
			  id_authorization nvarchar2(36) NULL,
			  b_captured char(1) NOT NULL,
			  b_try_dunning char(1) NOT NULL,
			  b_scheduled char(1) NOT NULL,
			  dt_create date NOT NULL,
			  dt_execute date NULL,
			  CONSTRAINT PK_t_pending_payment_trans PRIMARY KEY
			  (
				id_pending_payment
			  )
			  )
		  