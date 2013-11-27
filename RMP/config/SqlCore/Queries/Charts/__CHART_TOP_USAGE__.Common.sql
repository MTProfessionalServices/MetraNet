
				select top %%NUMBER_OF_ACCOUNTS%% au.id_acc as accountId, am.nm_login as category,
         sum(au.amount) as total
         from t_acc_usage au with(nolock) 
         inner join t_account_mapper am
         on am.id_acc = au.id_acc
         group by au.id_acc, am.nm_login
         order by total
			