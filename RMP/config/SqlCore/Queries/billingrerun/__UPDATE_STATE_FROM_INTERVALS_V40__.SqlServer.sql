
      update rr
        set rr.tx_state = 'C' 
        from %%TABLE_NAME%% rr
          inner join t_acc_usage_interval aui 
          on rr.id_interval = aui.id_usage_interval
          and rr.id_payer = aui.id_acc
          where aui.tx_status = 'H'       
   
  