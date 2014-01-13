
		      
SELECT 
  id_payment_instrument,
  id_acct,
  n_payment_method_type,
  nm_truncd_acct_num,
  tx_hash,
  id_creditcard_type,
  n_account_type,
  nm_exp_date,
  nm_exp_date_format,
  nm_first_name,
  nm_middle_name,
  nm_last_name,
  nm_address1,
  nm_address2,
  nm_city,
  nm_state,
  nm_zip,
  id_country,
  id_priority,
  n_max_charge_per_cycle,
  dt_created
FROM
	t_payment_instrument
WHERE
  id_acct = %%ACCOUNT_ID%%
  
        