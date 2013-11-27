
			CREATE nonclustered INDEX idx_payee_ind ON
                          t_acc_usage(id_payee, dt_session)
                