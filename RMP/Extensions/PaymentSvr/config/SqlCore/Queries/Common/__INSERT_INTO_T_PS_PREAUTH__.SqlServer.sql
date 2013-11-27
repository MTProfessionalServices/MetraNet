
        insert into t_ps_preauth
          (
	          id_preauth_tx_id,
	          id_pymt_instrument,
	          dt_transaction,
	          nm_description,
	          n_currency,
	          n_amount,
			  n_request_params,
			  nm_ar_request_id
          ) 
			  values
          (
           N'%%ID_PREAUTH_TX_ID%%',
           N'%%ID_PYMT_INTRUMENT%%',
           %%DT_TRANSACTION%%,
           SUBSTRING(N'%%NM_DESCRIPTION%%', 1, 10),
           N'%%N_CURRENCY%%',
           %%N_AMOUNT%%,
           N'%%N_REQUEST_PARAMS%%',
		   N'%%NM_AR_REQUEST_ID%%'
          )         
        