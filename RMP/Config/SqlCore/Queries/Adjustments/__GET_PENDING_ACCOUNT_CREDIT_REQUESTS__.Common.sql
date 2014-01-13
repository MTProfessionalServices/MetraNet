
              select
                pv.c_CreditAmount AdjustmentAmount,
                au.Amount Amount,
                au.am_currency Currency,
                pv.c_Description Description,
                pv.id_sess SessionId,
                pv.c_SubscriberAccountId SubscriberAccountId,
                au.dt_session AdjustmentTime				  
              from t_pv_AccountCreditRequest pv
              inner join t_acc_usage au on au.id_sess = pv.id_sess
              where c_status = 'PENDING'
              and au.id_parent_sess is NULL AND au.id_pi_instance is NULL           
			