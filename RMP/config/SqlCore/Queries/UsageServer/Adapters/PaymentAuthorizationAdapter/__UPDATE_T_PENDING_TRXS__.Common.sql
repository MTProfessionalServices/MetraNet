
                  update t_pending_payment_trans
                    set
                  id_authorization = N'%%ID_AUTH%%'
                  where
                      id_pending_payment = %%PENDING_PAYMENT_ID%%
        