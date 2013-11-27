
Select
	ppt.id_pending_payment,
	ppt.id_interval, ppt.id_acc, ppt.id_payment_instrument, ppt.b_try_dunning, ppt.id_authorization, 
	1, /*id_interval hard-coded since not applicable to scheduled payments*/ 
  ppt.id_acc, ppt.id_payment_instrument, ppt.b_try_dunning, ppt.id_authorization, 
	pptd.id_detail, pptd.nm_invoice_num, pptd.dt_invoice, pptd.nm_po_number, pptd.n_amount n_invoice_amount,
	ppt.nm_description, ppt.nm_currency, ppt.n_amount,
	pi.n_payment_method_type, pi.id_creditcard_type, pi.nm_truncd_acct_num
from
	t_pending_payment_trans ppt
	left outer join
	t_pending_payment_trans_dtl pptd on ppt.id_pending_payment = pptd.id_pending_payment
	left outer join
	t_billgroup bg on bg.id_usage_interval = ppt.id_interval
	left outer join
	t_billgroup_member bgm on bg.id_billgroup = bgm.id_billgroup and bgm.id_acc = ppt.id_acc
	inner join
	t_payment_instrument pi on ppt.id_payment_instrument = pi.id_payment_instrument
where
	/*ppt.dt_execute between %%DT_START%% and %%DT_END%% and*/
  ppt.dt_execute <= %%DT_END%% and
	ppt.n_amount <> 0 and
	b_captured = 0 and
	b_scheduled = 1
      