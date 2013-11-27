
update t_payment_instrument set id_priority = id_priority + 1
from t_payment_instrument
where 
	id_priority >= %%PRIORITY_ID%% and
	id_acct = %%ACCOUNT_ID%%

INSERT INTO t_payment_instrument
(
  id_payment_instrument,
  id_acct,
  n_payment_method_type,
  nm_truncd_acct_num,
  tx_hash,
  id_creditcard_type,
  n_account_type,
  nm_exp_date,
  nm_exp_date_format,
  nm_first_name,
  nm_middle_name,
  nm_last_name,
  nm_address1,
  nm_address2,
  nm_city,
  nm_state,
  nm_zip,
  id_country,
  id_priority,
  n_max_charge_per_cycle,
  dt_created
)
VALUES
(
  N'%%PAYMENT_INSTRUMENT_ID%%',
  %%ACCOUNT_ID%%,
  %%PAYMENT_METHOD_TYPE%%,
  N'%%ACCOUNT_NUMBER%%',
  N'%%HASH%%',
  %%CREDITCARD_TYPE%%,
	%%ACCOUNT_TYPE%%,
  N'%%EXP_DATE%%',
  %%EXP_DATE_FORMAT%%,
  N'%%FIRST_NAME%%',
  N'%%MIDDLE_NAME%%',
  N'%%LAST_NAME%%',
  N'%%ADDRESS1%%',
  N'%%ADDRESS2%%',
  N'%%CITY%%',
  N'%%STATE%%',
  N'%%ZIP%%',
  %%COUNTRY%%,
  %%PRIORITY_ID%%,
  %%MAX_CHARGE_PER_CYCLE%%,
  %%TIMESTAMP%%
)

update t_payment_instrument set id_priority = tmpId
from
	(select id_payment_instrument, id_priority, ROW_NUMBER() over (order by id_priority) as tmpId 
	   from t_payment_instrument where id_acct = %%ACCOUNT_ID%%) t
where
	t_payment_instrument.id_payment_instrument = t.id_payment_instrument
and
	id_acct = %%ACCOUNT_ID%%
        