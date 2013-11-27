
		select 
			n_payment_method_type,
			nm_account_number,
			nm_first_name,
			nm_middle_name,
			nm_last_name,
			nm_address1,
			nm_address2,
			nm_city,
			nm_state,
			nm_zip,
			id_country      
		from t_ps_payment_instrument
		where id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
		