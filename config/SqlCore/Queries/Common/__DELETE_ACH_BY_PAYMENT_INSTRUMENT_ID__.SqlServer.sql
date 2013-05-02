
            
           DELETE FROM
	          t_ps_ach
	        WHERE 
	          id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
	        
          DELETE FROM
	          t_ps_payment_instrument
	        WHERE 
	          id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
        
	  