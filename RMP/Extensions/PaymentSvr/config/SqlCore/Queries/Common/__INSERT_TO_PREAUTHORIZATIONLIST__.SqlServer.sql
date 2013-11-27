
        insert into t_preauthorizationlist
          (id_acc, 
           nm_xactionid, 
           nm_intxactionid,
           nm_lastfourdigits,
           id_creditcardtype) 
        values
          (%%ACCOUNT_ID%%,
           N'%%XACTION_ID%%',
           N'%%INT_XACTION_ID%%',
           N'%%LAST_FOUR_DIGITS%%',
           %%CREDIT_CARD_TYPE%%)
	  