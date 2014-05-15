select
  (select count(*) from t_failed_transaction where State in ('N','I', 'C') AND (id_PossiblePayerID = %%ACCOUNT_ID%% OR id_PossiblePayeeID = %%ACCOUNT_ID%%)) as TotalCount,
  (select count(*) from t_failed_transaction where State in ('N','I', 'C') AND id_PossiblePayerID = %%ACCOUNT_ID%%) as PayerCount,
  (select count(*) from t_failed_transaction where State in ('N','I', 'C') AND id_PossiblePayerID = %%ACCOUNT_ID%%) as PayeeCount
