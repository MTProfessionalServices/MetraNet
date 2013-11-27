
        SELECT
          nm_lastfourdigits,
          id_creditcardtype
        FROM 
          t_ps_creditcard
        WHERE 
          id_acc            =  %%ACCOUNT_ID%% and 
          nm_primary        =  N'%%PRIMARY%%'
	  