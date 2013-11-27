
            select 
              pv.c_Status Status,
              pv.id_sess SessionId,
              pv.c_SubscriberAccountID AccountId,
              au.am_currency Currency,
              pv.c_EmailNotification EmailNotificaton,
              pv.c_EmailAddress EmailAddress,
              pv.c_Reason Reason,
              pv.c_Other Other,
              pv.c_Description InternalComment, 
              pv.c_ContentionSessionID ContentionSessionID,
              pv.c_CreditAmount CreditAmount,              
              pv.c_GuideIntervalId GuideIntervalId
            from t_pv_AccountCreditRequest pv
            inner join t_acc_usage au on pv.id_sess = au.id_sess 
            where c_Status = 'PENDING' and pv.id_sess in (%%SESSION_IDS%%)          
			