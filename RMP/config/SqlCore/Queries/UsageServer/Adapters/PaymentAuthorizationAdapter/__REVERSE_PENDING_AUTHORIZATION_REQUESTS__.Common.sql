
                  update
                    t_pending_payment_trans
                  set
                    n_amount = 0.0
                  where
                    id_interval = %%INTERVAL_ID%%
        