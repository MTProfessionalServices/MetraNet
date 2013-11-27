
declare @newPriority int
select @newPriority = case when (%%PRIORITY%% > id_priority) then (%%PRIORITY%% + 1) 
							 else %%PRIORITY%% end
 from t_payment_instrument with(updlock) where id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'

update t_payment_instrument set id_priority = id_priority + 1
from t_payment_instrument
where 
	id_priority >= @newPriority and
	id_acct = %%ACCOUNT_ID%%

UPDATE t_payment_instrument
SET
  id_priority = @newPriority
WHERE
  id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'

update t_payment_instrument set id_priority = tmpId
from
	(select id_payment_instrument, id_priority, ROW_NUMBER() over (order by id_priority) as tmpId 
	   from t_payment_instrument where id_acct = %%ACCOUNT_ID%%) t
where
	t_payment_instrument.id_payment_instrument = t.id_payment_instrument
	   and
	id_acct = %%ACCOUNT_ID%%
