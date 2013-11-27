
      select au.id_sess, au.id_acc, au.id_view, au.id_parent_sess, au.dt_session, au.dt_crt, au.amount, au.am_currency, 
      au.tax_federal, au.tax_state, au.tax_county, au.tax_local, au.tax_other, au.id_usage_interval, 
      %%SELECT_CLAUSE%% from t_acc_usage au, 
      %%TABLE_NAME%% pv where au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
      