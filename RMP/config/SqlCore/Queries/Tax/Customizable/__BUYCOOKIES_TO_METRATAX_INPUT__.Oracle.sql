
        declare
  id_usage_interval int;
  id_bill_group     int;
  tax_vendor        int;

begin
  id_usage_interval := %%ID_USAGE_INTERVAL%%;
  id_bill_group := %%ID_BILL_GROUP%%;
  tax_vendor := %%TAX_VENDOR%%;

  insert into t_tax_input_%%ID_TAX_RUN%% (id_tax_charge, id_sess, id_usage_interval, charge_name, 
                                          round_alg, round_digits, 
                                          id_acc, amount, invoice_date, product_code, is_implied_tax, tax_informational)
    select 
      seq_t_tax_input_%%ID_TAX_RUN%%.nextval,
      pvc.id_sess, 
      pvc.id_usage_interval,
      'Cookies Amount',
      'BANK',
      '0',
      au.id_acc,
      au.Amount,
      pvc.c_ordertime,
      'MT100' ProductCode,
	  au.is_implied_tax,
	  au.tax_informational
    from 
      t_pv_OrderCookies pvc 
      inner join t_acc_usage au on au.id_sess = pvc.id_sess and 
                 au.id_usage_interval = pvc.id_usage_interval
          inner join t_av_internal i on au.id_acc = i.id_acc
          inner join t_billgroup_member bgm on bgm.id_acc = au.id_acc and bgm.id_billgroup = %%ID_BILL_GROUP%% 
        where
          i.c_TaxVendor = %%TAX_VENDOR%%
          and au.id_usage_interval = %%ID_USAGE_INTERVAL%%;
end;

  
      