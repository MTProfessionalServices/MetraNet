
        update t_ps_pcard set
          nm_customerreferenceid = N'%%CUSTOMERREFERENCEID%%',
          nm_customervatnumber   = N'%%CUSTOMERVATNUMBER%%',
          nm_companyaddress      = N'%%COMPANYADDRESS%%',
          nm_companypostalcode   = N'%%COMPANYPOSTALCODE%%',
          nm_companyphone        = N'%%COMPANYPHONE%%',
          nm_reserved1           = N'%%RESERVED1%%',
          nm_reserved2           = N'%%RESERVED2%%'
        WHERE 
          id_acc                 = %%ACCOUNT_ID%% and 
          id_creditcardtype      = %%CREDIT_CARD_TYPE%% and
          nm_lastfourdigits      = N'%%LAST_FOUR_DIGITS%%'
	  