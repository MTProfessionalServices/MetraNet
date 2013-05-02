
        update t_ps_credit_card set
          n_credit_card_type      = N'%%N_CREDIT_CARD_TYPE%%',
          nm_expirationdt         = N'%%EXP_DATE%%',
          nm_expirationdt_format  = N'%%EXP_DATE_FORMAT%%',
          nm_startdate            = N'%%START_DATE%%',
          nm_issuernumber         = N'%%ISSUER_NUMBER%%'
        WHERE 
          id_payment_instrument  = N'%%PAYMENT_INSTRUMENT_ID%%'
	  