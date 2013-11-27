
            select 
              pv.*,
              au.am_currency Currency              
            from t_pv_AccountCreditRequest pv
            inner join t_acc_usage au on pv.id_sess = au.id_sess 
            where c_Status = 'PENDING' and pv.id_sess in (%%SESSION_IDS%%)          
			