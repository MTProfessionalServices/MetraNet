select %%VIEW_ID%% ViewID, '%%VIEW_NAME%%' ViewName, 
      '%%VIEW_TYPE%%' ViewType, %%DESC_ID%% DescriptionID, sum(pv.c_DiscountAmount) 'Amount', 
      au.am_currency 'Currency', count(1) 'Count', sum(isnull((pv.c_DiscountTaxAmount), 0.0)) 'TaxAmount', 
      sum(pv.c_DiscountAmount + isnull((pv.c_DiscountTaxAmount), 0.0)) 'AmountWithTax', %%ACCOUNT_ID%% AccountID, %%INTERVAL_ID%% IntervalID from 
      t_acc_usage au, %%TABLE_NAME%% pv where 
      au.id_acc = %%ACCOUNT_ID%% and au.id_usage_interval = %%INTERVAL_ID%% and 
      au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval %%EXT%% group by au.am_currency
      