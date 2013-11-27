
        CREATE TABLE t_pending_ach_trans (
        id_payment_transaction varchar2(87) NOT NULL,
        n_days                 number(10) NOT NULL,
		id_payment_instrument  nvarchar2(72) NOT NULL,
		id_acc 				   number(10) NOT NULL,
		n_amount 			   decimal NOT NULL,
		nm_description 		   nvarchar2(100) NULL,
		dt_create 			   timestamp NOT NULL,
		nm_ar_request_id	   nvarchar2(256) NULL,
        PRIMARY KEY (id_payment_transaction))
      