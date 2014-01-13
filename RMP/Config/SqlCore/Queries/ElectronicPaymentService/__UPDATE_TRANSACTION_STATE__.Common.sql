
				update t_payment_history set n_state=@n_state, dt_last_updated=%%%SYSTEMDATE%%%, n_operator_notes=@notes
					where id_payment_transaction=@id_payment_transaction
			