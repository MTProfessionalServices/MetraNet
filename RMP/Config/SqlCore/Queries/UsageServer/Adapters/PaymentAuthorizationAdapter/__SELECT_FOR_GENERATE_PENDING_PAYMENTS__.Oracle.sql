
	Select 
		id_interval, bg.id_acc as id_acc, invoice_string, invoice_date, invoice_currency, current_balance, 
		id_payment_instrument, id_priority, 
		n_max_charge_per_cycle, cast(1 as number(10,0)) as id_commit_unit
	From
		t_invoice i
		inner join
		t_billgroup_member bg on i.id_acc = bg.id_acc
		inner join
		t_av_internal av on i.id_acc = av.id_acc
		inner join
		t_enum_data ed on av.c_paymentmethod = ed.id_enum_data
		inner join
		t_payment_instrument pi on bg.id_acc = pi.id_acct
	where
		bg.id_billgroup = %%ID_BILLGROUP%% and i.id_interval = %%ID_INTERVAL%%
		and i.current_balance <> 0 and ed.nm_enum_data = 'metratech.com/accountcreation/PaymentMethod/CreditOrACH'
	order by
		bg.id_acc,
		pi.id_priority
        