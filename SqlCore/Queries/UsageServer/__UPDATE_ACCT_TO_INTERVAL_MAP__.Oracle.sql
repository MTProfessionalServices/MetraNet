
						insert into t_acc_usage_interval values (%%ACCOUNT_ID%%, %%INTERVAL_ID%%, 
				  		'O', TO_DATE('%%END_DATE%%' || ' 23:59:59', 'MM/DD/YY HH24:MI:SS')) 
			