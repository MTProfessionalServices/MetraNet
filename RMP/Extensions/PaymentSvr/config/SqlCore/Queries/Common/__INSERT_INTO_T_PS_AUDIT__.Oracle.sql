
        insert into t_ps_audit
          (
          id_audit,
          id_request_type,
          id_transaction,
          dt_transaction,
          n_payment_method_type,
          nm_truncd_acct_num,
          n_creditcard_type,
          n_account_type,
          nm_description,
          n_currency,
          n_amount,
          id_transaction_session_id,
          n_state,
          n_gateway_response,
          dt_last_update
          ) 
			  values
          (
          :id_audit,
          :id_request_type,
          :id_transaction,
          :dt_transaction,
          :n_payment_method_type,
          :nm_truncd_acct_num,
          :n_creditcard_type,
          :n_account_type,
          :nm_description,
          :n_currency,
          :n_amount,
          :id_transaction_session_id,
          :n_state,
          NULL,
          %%%SYSTEMDATE%%%
          )       
        