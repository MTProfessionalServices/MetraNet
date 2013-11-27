
          update t_pending_ach_trans set n_days = n_days + 1 where id_payment_transaction = N'%%PAYMENT_TX_ID%%'          
        