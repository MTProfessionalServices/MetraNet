
        SELECT 
		  *
        FROM 
		  t_preauthorizationlist
        WHERE 
		  id_acc = %%ACCOUNT_ID%% and
          nm_intxactionid = N'%%INT_XACTION_ID%%'
	  