
              update t_ps_audit
              set n_state = :n_state, dt_last_update = %%%SYSTEMDATE%%%, n_gateway_response=:n_gateway_response
              where id_transaction_session_id = :id_transaction