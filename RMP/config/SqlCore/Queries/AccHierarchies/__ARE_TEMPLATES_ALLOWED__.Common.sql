
				select b_canHaveTemplates as areTemplatesAllowed
				from t_account_type atype
				inner join t_account acc
				on atype.id_type = acc.id_type
				where acc.id_acc = %%ACCOUNTID%% 
				