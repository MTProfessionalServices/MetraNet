
BEGIN
update %%NETMETER%%.t_pending_payment_trans ppt set
(n_amount,  nm_currency, dt_execute, b_scheduled, b_try_dunning, dt_create) =
	( select amtToCharge,  invoice_currency, %%DT_EXECUTE%%, %%B_SCHEDULED%%, %%B_TRYDUNNING%%, %%DT_CREATE%%
		from %%STAGINGDB%%.%1% tmp_payments
		where 
			tmp_payments.id_acc = ppt.id_acc and
			tmp_payments.id_interval = ppt.id_interval and
			tmp_payments.id_payment_instrument = ppt.id_payment_instrument
	)
Where 
    Exists( select amtToCharge,  invoice_currency,invoice_date,invoice_string
		from %%STAGINGDB%%.%1% tmp_payments
		where 
			tmp_payments.id_acc = ppt.id_acc and
			tmp_payments.id_interval = ppt.id_interval and
			tmp_payments.id_payment_instrument = ppt.id_payment_instrument
	);
	  
insert into %%NETMETER%%.t_pending_payment_trans( id_pending_payment, id_interval, id_acc, id_payment_instrument,  nm_currency, n_amount, b_captured, b_Scheduled, dt_execute, b_try_dunning, dt_create)
select seq_t_pending_payment.nextval, id_interval, id_acc, tmp_payments.id_payment_instrument, invoice_currency, amtToCharge, '0', %%B_SCHEDULED%%, %%DT_EXECUTE%%, %%B_TRYDUNNING%%, %%DT_CREATE%%
from %%STAGINGDB%%.%1% tmp_payments
where not exists	
	(select id_interval, id_acc from %%NETMETER%%.t_pending_payment_trans t where tmp_payments.id_acc = t.id_acc and 
	tmp_payments.id_interval = t.id_interval and tmp_payments.id_payment_instrument = t.id_payment_instrument);
	
update %%NETMETER%%.t_pending_payment_trans_dtl pptd set
(n_amount, dt_invoice, nm_invoice_num, nm_po_number) =
	( select tmp_payments.amtToCharge,  tmp_payments.invoice_date, tmp_payments.invoice_string, ''
		from %%STAGINGDB%%.%1% tmp_payments INNER JOIN %%NETMETER%%.t_pending_payment_trans PPT ON 
  		 (tmp_payments.id_acc = ppt.id_acc and
			tmp_payments.id_interval = ppt.id_interval and
			tmp_payments.id_payment_instrument = ppt.id_payment_instrument)
	)
Where 
    Exists( select 1
		from %%STAGINGDB%%.%1% tmp_payments INNER JOIN %%NETMETER%%.t_pending_payment_trans ppt1
		ON ( 
			tmp_payments.id_acc = ppt1.id_acc and
			tmp_payments.id_interval = ppt1.id_interval and
			tmp_payments.id_payment_instrument = ppt1.id_payment_instrument
			) 
		WHERE ppt1.id_pending_payment = pptd.id_pending_payment
	);

insert into %%NETMETER%%.t_pending_payment_trans_dtl(id_detail, id_pending_payment, nm_invoice_num, dt_invoice, n_amount, nm_po_number)
select seq_t_pending_payment_dtl.nextval, ppt.id_pending_payment, tmp_payments.invoice_string, tmp_payments.invoice_date, tmp_payments.amtToCharge, ''
from %%STAGINGDB%%.%1% tmp_payments inner join %%NETMETER%%.t_pending_payment_trans PPT ON (tmp_payments.id_acc = PPT.id_acc 
																							AND tmp_payments.id_interval = PPT.id_interval
																							AND tmp_payments.id_payment_instrument = PPT.id_payment_instrument)
where not exists	
	(select t.id_interval, t.id_acc from %%NETMETER%%.t_pending_payment_trans_dtl pptd 
	 inner join %%NETMETER%%.t_pending_payment_trans t ON (t.id_pending_payment = pptd.id_pending_payment) 
	 where tmp_payments.id_acc = t.id_acc and tmp_payments.id_interval = t.id_interval and tmp_payments.id_payment_instrument = t.id_payment_instrument);
	
	
	
	
	
END;
	   