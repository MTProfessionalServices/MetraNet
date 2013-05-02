
      /* __GET_ACCOUNT_TYPE_BYID__ */
 			execute sp_executesql N'
      select at.name as AccountType from t_account_type at
      JOIN t_account ac on at.id_type = ac.id_type
      where ac.id_acc = @id_acc', 
			N'@id_acc integer', %%ACCOUNT_ID%%
			