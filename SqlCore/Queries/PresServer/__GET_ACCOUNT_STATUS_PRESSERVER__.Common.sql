
				/* 	select 418;   */
				select 'METRATECH.COM/ACCOUNTCREATION/ACCOUNTSTATUS/ACTIVE' tx_status,
				N'%%LOGIN_ID%%',N'%%NAME_SPACE%%' %%%FROMDUAL%%%
				/*
				select ed.nm_enum_data tx_status from t_account a, t_account_mapper am, t_enum_data ed
				where am.nm_login = '%%LOGIN_ID%%' and am.nm_space = %%%UPPER%%%('%%NAME_SPACE%%')
				and am.id_acc = a.id_acc and a.id_status = ed.id_enum_data
				*/
			