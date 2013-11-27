
        select 
          id_sess SessionID, id_view ViewID, amount Amount, id_usage_interval IntervalID
			  from t_acc_usage
          where tx_UID = HEXTORAW (ltrim('%%VARBIN_ID%%', '0x'))
      