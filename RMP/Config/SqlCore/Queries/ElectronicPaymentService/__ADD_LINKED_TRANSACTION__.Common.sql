
				update t_payment_history set linked_transaction=@linked_transaction, dt_last_updated=%%%SYSTEMDATE%%%
					where id_payment_transaction=@id_payment_transaction
			