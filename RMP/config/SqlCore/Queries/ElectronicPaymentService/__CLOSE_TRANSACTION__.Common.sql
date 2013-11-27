
		begin
          update t_payment_history set n_state=@n_state, n_gateway_response=@n_gateway_response, dt_last_updated=%%%SYSTEMDATE%%%
					  where id_payment_transaction=@id_payment_transaction;
          delete from t_open_transactions where id_payment_transaction=@id_payment_transaction;
		end;
          