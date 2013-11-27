
        update t_ps_ach set        
          nm_routing_number = N'%%NM_ROUTING_NUMBER%%',
          nm_bank_name      = N'%%NM_BANK_NAME%%',
          nm_bank_address   = N'%%NM_BANK_ADDRESS%%',
          nm_bank_city      = N'%%NM_BANK_CITY%%',
          nm_bank_state     = N'%%NM_BANK_STATE%%',
          nm_bank_zip       = N'%%NM_BANK_ZIP%%',
          id_country        = %%NM_COUNTRY%%
        WHERE 
          id_payment_instrument  = N'%%PAYMENT_INSTRUMENT_ID%%'          
	  