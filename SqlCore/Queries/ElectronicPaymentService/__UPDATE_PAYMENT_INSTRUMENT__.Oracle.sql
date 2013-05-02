
BEGIN

UPDATE t_payment_instrument
SET
  nm_exp_date = N'%%EXP_DATE%%',
  nm_first_name = N'%%FIRST_NAME%%',
  nm_middle_name = N'%%MIDDLE_NAME%%',
  nm_last_name = N'%%LAST_NAME%%',
  nm_address1 = N'%%ADDRESS1%%',
  nm_address2 = N'%%ADDRESS2%%',
  nm_city = N'%%CITY%%',
  nm_state = N'%%STATE%%',
  nm_zip = N'%%ZIP%%',
  id_country = %%COUNTRY%%,
  n_max_charge_per_cycle = %%MAX_CHARGE_PER_CYCLE%%
WHERE
  id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%';
	   
END;
