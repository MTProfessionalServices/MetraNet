
            select 
              pv.*,
              mapper.nm_login as cn_issuer
            from t_pv_AccountCredit pv
            inner join t_acc_usage au on au.id_sess = pv.c_RequestID
            inner join t_svc_AccountCredit svc on svc.id_source_sess = au.tx_UID          
            inner join t_account_mapper mapper on mapper.id_acc = svc.c_Issuer
            where pv.c_RequestID in (%%SESSION_IDS%%) and pv.c_IssueCreditNote = 1
			