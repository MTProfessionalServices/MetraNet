
declare pPriority int;

BEGIN

select case when (%%PRIORITY%% > id_priority) then (%%PRIORITY%% + 1) else %%PRIORITY%% end newPriority
into pPriority from t_payment_instrument 
 where id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%';


update t_payment_instrument set id_priority = id_priority + 1
where 
	id_priority >= pPriority and
	id_acct = %%ACCOUNT_ID%%;

UPDATE t_payment_instrument
SET
  id_priority = pPriority
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
