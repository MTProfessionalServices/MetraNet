
			  begin
                 INSERT INTO t_payment_history
                  (
                    id_payment_transaction,
                    id_acct,
                    dt_transaction,
                    n_payment_method_type,
                    nm_truncd_acct_num,
                    id_creditcard_type,
                    n_account_type,
                    nm_description,
                    n_currency,
                    n_amount,
                    n_transaction_type,
				            n_state,
				            dt_last_updated,
				            id_payment_instrument,
				            payment_info
                  )
                  VALUES
                  (
                    @id_payment_transaction,
                    @id_acct,
                    @dt_transaction,
                    @n_payment_method_type,
                    @nm_truncd_acct_num,
                    @id_creditcard_type,
                    @n_account_type,
                    @nm_description,
                    @n_currency,
                    @n_amount,
                    @n_transaction_type,
				    @n_state,
				    %%%SYSTEMDATE%%%,
				    @id_payment_instrument,
				    @payment_info
                  );
					
				  insert into t_open_transactions(id_payment_transaction) 
				            select id_payment_transaction from t_payment_history 
                    where id_payment_transaction = @id_payment_transaction;
			 end;

        