
          update t_payment_history set n_state='MANUALLY_REVERSED', n_operator_notes=@n_operator_notes, dt_last_updated=%%%SYSTEMDATE%%%
          where id_payment_transaction=@id_payment_transaction;
        