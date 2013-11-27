
  
		DELETE FROM t_payment_instrument
		WHERE
		id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
			
		update t_payment_instrument set id_priority = tmpId
		from
			(select id_payment_instrument, id_priority, ROW_NUMBER() over (order by id_priority) as tmpId 
			   from t_payment_instrument where id_acct = %%ACCOUNT_ID%%) t
		where
			t_payment_instrument.id_payment_instrument = t.id_payment_instrument

        