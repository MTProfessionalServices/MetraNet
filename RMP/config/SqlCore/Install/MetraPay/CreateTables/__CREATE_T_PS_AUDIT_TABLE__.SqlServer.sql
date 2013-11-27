
		  CREATE TABLE t_ps_audit (
		  id_audit [nvarchar](72) NOT NULL,
		  id_request_type int NOT NULL,
		  id_transaction nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  dt_transaction datetime NOT NULL,
		  n_payment_method_type int NOT NULL,
		  nm_truncd_acct_num nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  n_creditcard_type int NULL,
		  n_account_type int NULL,
		  nm_description nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  n_currency nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		  n_amount numeric(22,10) NOT NULL,
      id_transaction_session_id [nvarchar](72) NOT NULL,
		  n_state nvarchar(30) NOT NULL,
		  n_gateway_response nvarchar(400) NULL,
		  dt_last_update datetime NOT NULL,
		  CONSTRAINT PK_t_ps_audit PRIMARY KEY CLUSTERED
		  (
		  id_audit
		  ))
	  