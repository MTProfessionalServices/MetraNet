select t_account_mapper.nm_login, t_account_mapper.id_acc from t_account_mapper join 
(select id_acc from t_account join t_account_type on t_account.id_type = t_account_type.id_type where t_account_type.name = 'Partition') tmp 
on t_account_mapper.id_acc = tmp.id_acc 
