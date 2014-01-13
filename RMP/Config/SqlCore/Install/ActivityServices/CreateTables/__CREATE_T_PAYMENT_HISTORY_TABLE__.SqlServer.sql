
			      CREATE TABLE t_payment_history (
	              id_payment_transaction nvarchar(72)NOT NULL,
	              id_acct int NOT NULL,
	              dt_transaction datetime NOT NULL,
	              n_payment_method_type int NOT NULL,
	              nm_truncd_acct_num nvarchar(20) NOT NULL,
	              id_creditcard_type int NULL,
	              n_account_type int NULL,
	              nm_description nvarchar(100) NOT NULL,
	              n_currency nvarchar(10) NOT NULL,
	              n_amount numeric(22,10) NOT NULL,
				        n_transaction_type nvarchar(20) NOT NULL,
				        n_state nvarchar(30) NOT NULL,
				        n_gateway_response nvarchar(400) NULL,
				        dt_last_updated datetime NOT NULL,
				        n_operator_notes nvarchar(500) NULL,
				        id_payment_instrument nvarchar(72) NULL,
				        payment_info varbinary(max) NULL,
                linked_transaction nvarchar(72) NULL,
	              CONSTRAINT PK_t_payment_history PRIMARY KEY CLUSTERED 
	              (
		              id_payment_transaction
	              )
              )
				