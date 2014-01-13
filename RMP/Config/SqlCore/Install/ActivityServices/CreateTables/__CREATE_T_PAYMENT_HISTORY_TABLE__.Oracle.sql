
          		      CREATE TABLE t_payment_history (
	              id_payment_transaction VARCHAR2(40) NOT NULL,
	              id_acct number(10) NOT NULL,
	              dt_transaction timestamp NOT NULL,
	              n_payment_method_type number(10) NOT NULL,
	              nm_truncd_acct_num nvarchar2(20) NOT NULL,
	              id_creditcard_type number(10) NULL,
	              n_account_type number(10) NULL,
	              nm_description nvarchar2(100) NOT NULL,
	              n_currency nvarchar2(10) NOT NULL,
	              n_amount decimal NOT NULL,
				        n_transaction_type nvarchar2(20) NOT NULL,
				        n_state nvarchar2(30) NOT NULL,
				        n_gateway_response nvarchar2(400) NULL,
				        dt_last_updated timestamp NOT NULL,
				        n_operator_notes nvarchar2(500) NULL,
				        id_payment_instrument VARCHAR2(40) NULL,
				        payment_info blob NULL,
                linked_transaction VARCHAR2(40) NULL,
	              PRIMARY KEY (id_payment_transaction))	              
              
				