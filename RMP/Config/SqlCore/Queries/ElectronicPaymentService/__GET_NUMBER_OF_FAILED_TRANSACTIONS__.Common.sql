
                    SELECT COUNT(n_state) FROM t_open_transactions inner join
                    t_payment_history on 
                    t_open_transactions.id_payment_transaction = t_payment_history.id_payment_transaction
                    AND t_payment_history.n_state = 'FAILURE'
              