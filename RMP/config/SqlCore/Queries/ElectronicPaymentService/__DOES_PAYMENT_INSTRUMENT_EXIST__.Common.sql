
            select id_payment_instrument from t_payment_instrument
            where tx_hash = N'%%HASH%%' and
              id_acct = %%ID_ACCT%%
	  