
		     select id_acc from t_account acc
		     inner join t_account_type atype
		     on acc.id_type = atype.id_type
		     where %%%UPPER%%%(atype.name) = %%%UPPER%%%('%%ACCTYPENAME%%')
			