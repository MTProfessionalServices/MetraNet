
        SELECT
          nm_lastfourdigits,
          nm_bankname,
          id_creditcardtype,
          nm_expdate,
          id_expdatef
        FROM 
          t_ps_credit_card
        WHERE 
          id_acc = %%ACCOUNT_ID%%
	  