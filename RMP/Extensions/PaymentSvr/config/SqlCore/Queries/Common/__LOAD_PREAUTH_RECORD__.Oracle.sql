
            select 
              id_pymt_instrument,
	            n_request_params,
				nm_ar_request_id,
				n_amount
            from t_ps_preauth
            where id_preauth_tx_id = N'%%AUTH_TOKEN%%'
        