
      select au.id_sess, au.id_acc, au.id_parent_sess, au.dt_session, au.dt_crt, au.amount, au.am_currency, 
      au.tax_federal, au.tax_state, au.tax_county, au.tax_local, au.tax_other, au.id_usage_interval, 
      au.id_view from t_acc_usage au
      