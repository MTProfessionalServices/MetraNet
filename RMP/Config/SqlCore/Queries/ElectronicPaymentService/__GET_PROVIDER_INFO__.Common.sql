/*GET_PROVIDER_INFO*/
		begin
          select nm_provider_info from t_payment_history_details
					  where id_payment_transaction=@id_payment_transaction;
		end;