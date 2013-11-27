
      select aui.id_acc AccountID, aui.id_usage_interval IntervalID,
      aui.dt_effective DateEffective from t_acc_usage_interval aui 
      where aui.tx_status = 'O'
        