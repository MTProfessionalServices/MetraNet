
        SELECT
        nm_account_number,
		    n_credit_card_type
        FROM 
          t_ps_credit_card ps
		  inner join t_ps_payment_instrument ppi on ps.id_payment_instrument = ppi.id_payment_instrument
        WHERE 
          ps.id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
	  