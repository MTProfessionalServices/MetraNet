
        select
	        id_payment_instrument,
          nm_routing_number,
          nm_bank_name,
          nm_bank_address,
          nm_bank_city,
          nm_bank_state,
          nm_bank_zip,
          id_country
        from t_ps_ach
        WHERE 
          id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
	  