/*UPDATE_PROVIDER_INFO*/
		begin
          update t_payment_history_details set nm_provider_info = @provider_info
					  where id_payment_transaction=@id_payment_transaction;
		end;
          