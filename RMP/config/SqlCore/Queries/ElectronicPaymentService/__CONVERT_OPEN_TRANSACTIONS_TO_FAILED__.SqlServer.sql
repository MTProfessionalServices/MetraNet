
                    update t_payment_history set n_state='FAILURE' FROM t_open_transactions inner join
                    t_payment_history on t_open_transactions.id_payment_transaction = t_payment_history.id_payment_transaction
                    where t_payment_history.dt_last_updated < @end_time;
              