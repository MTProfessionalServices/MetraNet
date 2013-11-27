
            select id_payment_instrument, payment_info, n_transaction_type, n_state from t_payment_history
            where id_payment_transaction=@id_payment_transaction
	  