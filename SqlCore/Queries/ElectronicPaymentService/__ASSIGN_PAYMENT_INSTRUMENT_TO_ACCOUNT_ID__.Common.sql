
UPDATE
  t_payment_instrument
SET
  id_acct = %%ACCOUNT_ID%%
WHERE
  id_payment_instrument = N'%%PAYMENT_INSTRUMENT_ID%%'
        