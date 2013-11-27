
        update t_ps_creditcard set
          nm_customer            = N'%%CUSTOMER_NAME%%',
          nm_enabled             = N'%%ENABLED%%',
          nm_authreceived        = N'%%AUTHRECEIVED%%',
          nm_address             = N'%%ADDRESS%%',
		  nm_address2			 = N'%%ADDRESS2%%',
          nm_city                = N'%%CITY%%',
          nm_state               = N'%%STATE%%',
          nm_zip                 = N'%%ZIP%%',
          nm_country             = N'%%COUNTRY%%', 
          nm_expdate             = N'%%EXP_DATE%%',
          id_expdatef            = %%EXP_DATE_FORMAT%%,
          nm_startdate           = %%START_DATE%%,
          nm_issuernumber        = %%ISSUER_NUMBER%%,
          nm_cardid              = N'%%CARDID%%',
          nm_cardverifyvalue     = N'%%CARD_VERIFY_VALUE%%'
        WHERE 
          id_acc                 = %%ACCOUNT_ID%% and 
          id_creditcardtype      = %%CREDIT_CARD_TYPE%% and
          nm_lastfourdigits      = N'%%LAST_FOUR_DIGITS%%'
	  