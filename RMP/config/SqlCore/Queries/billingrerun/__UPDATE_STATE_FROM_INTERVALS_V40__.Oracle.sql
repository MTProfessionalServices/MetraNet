
          update %%TABLE_NAME%% rr
           set tx_state = 'C' 
          where exists (select tx_status from t_acc_usage_interval aui
                where aui.id_usage_interval  = rr.id_interval
                  and aui.id_acc = rr.id_payer
                  and aui.tx_status = 'H')
  