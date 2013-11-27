
        SELECT
          nm_lastfourdigits,
          id_creditcardtype
        FROM 
          t_ps_creditcard
        WHERE 
          id_acc            =  %%ACCOUNT_ID%% and 
          nm_lastfourdigits = N'%%LAST_FOUR_DIGITS%%' and
          id_creditcardtype = %%CREDIT_CARD_TYPE%% and
          nm_primary        =  N'%%PRIMARY%%'
	  