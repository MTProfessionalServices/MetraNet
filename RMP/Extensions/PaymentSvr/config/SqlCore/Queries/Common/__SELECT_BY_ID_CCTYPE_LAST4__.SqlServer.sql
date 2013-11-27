
            select ppi.id_payment_instrument from t_ps_credit_card cc
            inner join t_ps_payment_instrument ppi on cc.id_payment_instrument = ppi.id_payment_instrument
            where nm_account_number = N'%%NM_ACCOUNT_NUMBER%%'
	  