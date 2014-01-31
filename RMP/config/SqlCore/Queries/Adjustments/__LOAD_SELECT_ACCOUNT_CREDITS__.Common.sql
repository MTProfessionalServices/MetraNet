
            select 
              *
            from t_pv_AccountCredit pv
            where pv.c_RequestID in (%%SESSION_IDS%%)          
			