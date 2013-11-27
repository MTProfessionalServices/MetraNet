
      /* __GET_ACCOUNT_TYPE_BYID__ */
      select at.name as AccountType from t_account_type at
      JOIN t_account ac on at.id_type = ac.id_type
      where ac.id_acc = %%ACCOUNT_ID%%
			