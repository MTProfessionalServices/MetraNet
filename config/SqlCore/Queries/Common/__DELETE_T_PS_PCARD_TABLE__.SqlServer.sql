
        delete
          t_ps_pcard
        WHERE 
          id_acc            = %%ACCOUNT_ID%% and 
          id_creditcardtype = %%CREDIT_CARD_TYPE%% and
          nm_lastfourdigits = N'%%LAST_FOUR_DIGITS%%'
	  