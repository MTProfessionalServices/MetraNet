
          update t_payment_history set n_state='MANUALLY_PENDING', n_operator_notes=@n_operator_notes, dt_last_updated=%%%SYSTEMDATE%%% where id_payment_transaction=@id_payment_transaction;
          delete from t_open_transactions where id_payment_transaction=@id_payment_transaction
        