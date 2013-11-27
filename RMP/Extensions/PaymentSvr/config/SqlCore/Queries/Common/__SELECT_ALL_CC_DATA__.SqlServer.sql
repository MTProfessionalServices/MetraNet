
                select    
                  id_payment_instrument,
                  n_credit_card_type,
                  nm_expirationdt,	
                  nm_expirationdt_format,
                  nm_startdate,
                  nm_issuernumber
                from t_ps_credit_card
                where id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
	             