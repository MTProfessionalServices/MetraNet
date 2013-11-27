
        select 
          id_sess SessionID, id_view ViewID, id_usage_interval IntervalID
			  from t_acc_usage
          where tx_UID = %%VARBIN_ID%%
      