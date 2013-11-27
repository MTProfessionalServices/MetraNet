
        update t_ps_creditcard set
          nm_primary             = '%%PRIMARY%%'
        WHERE 
          id_acc                 = %%ACCOUNT_ID%% and 
          id_creditcardtype      = %%CREDIT_CARD_TYPE%% and
          nm_lastfourdigits      = N'%%LAST_FOUR_DIGITS%%'
	  