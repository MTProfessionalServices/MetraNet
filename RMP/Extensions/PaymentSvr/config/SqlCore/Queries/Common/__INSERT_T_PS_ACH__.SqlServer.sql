
        insert into t_ps_ach
          (
            id_payment_instrument,
            nm_routing_number,
            nm_bank_name,
            nm_bank_address,
            nm_bank_city,
            nm_bank_state,
            nm_bank_zip,
            id_country
        ) 
        values
        (
          CAST('%%PAYMENT_INSTRUMENT_ID%%' as UNIQUEIDENTIFIER),
          N'%%NM_ROUTING_NUMBER%%',
          N'%%NM_BANK_NAME%%',
          N'%%NM_BANK_ADDRESS%%',
          N'%%NM_BANK_CITY%%',
          N'%%NM_BANK_STATE%%',
          N'%%NM_BANK_ZIP%%',
          %%NM_COUNTRY%%
	   )
	  