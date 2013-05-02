
        insert into t_ps_credit_card
          (
            id_payment_instrument,
            n_credit_card_type,
            nm_expirationdt,
            nm_expirationdt_format,
            nm_startdate,
            nm_issuernumber
        ) 
        values
        (
          CAST('%%PAYMENT_INSTRUMENT_ID%%' as UNIQUEIDENTIFIER),
          %%N_CREDIT_CARD_TYPE%%,
          N'%%NM_EXPIRATIONDT%%',
          N'%%NM_EXPIRATIONDT_FORMAT%%',
          N'%%NM_START_DATE%%',
          N'%%NM_ISSUER_NUMBER%%'
	   )
	  