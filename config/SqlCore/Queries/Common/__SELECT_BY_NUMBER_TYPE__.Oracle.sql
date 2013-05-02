
        SELECT
          id_acc,
          nm_expdate
        FROM 
          t_ps_creditcard
        WHERE 
          nm_ccnum          = N'%%CREDIT_CARD_NUMBER%%' and 
          id_creditcardtype = %%CREDIT_CARD_TYPE%%
	  