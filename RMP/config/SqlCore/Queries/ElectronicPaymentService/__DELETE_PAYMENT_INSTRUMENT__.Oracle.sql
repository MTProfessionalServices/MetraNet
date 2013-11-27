
BEGIN  
DELETE FROM t_payment_instrument
WHERE
id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%';
			
update t_payment_instrument pi set (id_priority)= 
	(select tmpId from
        (select id_payment_instrument, rownum as tmpId from 
            (select id_payment_instrument, id_priority from t_payment_instrument
                where id_acct = %%ACCOUNT_ID%% order by id_priority
            ) inner
        )t
        where t.id_payment_instrument = pi.id_payment_instrument
    )
	where id_acct = %%ACCOUNT_ID%%;

END;
        