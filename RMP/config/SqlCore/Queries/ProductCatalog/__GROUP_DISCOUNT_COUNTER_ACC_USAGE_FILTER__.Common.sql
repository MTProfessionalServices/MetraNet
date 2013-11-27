
    t_acc_usage.dt_session BETWEEN 
      dbo.MTMaxOfTwoDates(tgs.vt_start, tmp_2.dt_effdisc_start) AND
      dbo.MTMinOfTwoDates(tgs.vt_end, tmp_2.dt_effdisc_end)
