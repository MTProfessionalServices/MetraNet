
        select 
          count (distinct au.id_acc) as "Distinct Payers", 
          count (distinct au.id_payee) as "Distinct Payees" 
        from t_acc_usage au 
 				where au.tx_batch=hextoraw(ltrim('%%ID_BATCH%%', '0Xx'))
			 