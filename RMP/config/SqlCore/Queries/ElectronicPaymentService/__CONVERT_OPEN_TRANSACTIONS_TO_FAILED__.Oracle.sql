
                    update 
     (select t_payment_history.n_state from  t_payment_history inner join
                     t_open_transactions on t_open_transactions.id_payment_transaction = t_payment_history.id_payment_transaction
                    where t_payment_history.dt_last_updated < :end_time)
                    set n_state='FAILURE'
              