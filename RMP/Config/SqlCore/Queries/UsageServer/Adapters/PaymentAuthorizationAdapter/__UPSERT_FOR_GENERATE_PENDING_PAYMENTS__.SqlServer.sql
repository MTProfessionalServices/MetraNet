


update %%NETMETER%%..t_pending_payment_trans set
	n_amount = amtToCharge,  nm_currency = invoice_currency,
	dt_execute = %%DT_EXECUTE%%, b_scheduled = %%B_SCHEDULED%%, b_try_dunning = %%B_TRYDUNNING%%, dt_create = %%DT_CREATE%%
from %%STAGINGDB%%..%1% tmp_payments
where 
	tmp_payments.id_acc = %%NETMETER%%..t_pending_payment_trans.id_acc and
	tmp_payments.id_interval = %%NETMETER%%..t_pending_payment_trans.id_interval and
	tmp_payments.id_payment_instrument = %%NETMETER%%..t_pending_payment_trans.id_payment_instrument

insert into %%NETMETER%%..t_pending_payment_trans( id_interval, id_acc, id_payment_instrument, nm_currency, n_amount, b_captured, b_Scheduled, dt_execute, b_try_dunning, dt_create)
select id_interval, id_acc, tmp_payments.id_payment_instrument, invoice_currency, amtToCharge, '0', %%B_SCHEDULED%%, %%DT_EXECUTE%%, %%B_TRYDUNNING%%, %%DT_CREATE%%
from %%STAGINGDB%%..%1% tmp_payments
where not exists	
	(select id_interval, id_acc from %%NETMETER%%..t_pending_payment_trans t where tmp_payments.id_acc = t.id_acc and 
	tmp_payments.id_interval = t.id_interval and tmp_payments.id_payment_instrument = t.id_payment_instrument)
	
update %%NETMETER%%..t_pending_payment_trans_dtl set
	n_amount = tmp_payments.amtToCharge, 
	nm_invoice_num = tmp_payments.invoice_string,
	dt_invoice = tmp_payments.invoice_date
from %%STAGINGDB%%..%1% tmp_payments 
INNER JOIN %%NETMETER%%..t_pending_payment_trans ON (tmp_payments.id_acc = %%NETMETER%%..t_pending_payment_trans.id_acc AND
														tmp_payments.id_interval = %%NETMETER%%..t_pending_payment_trans.id_interval and
														tmp_payments.id_payment_instrument = %%NETMETER%%..t_pending_payment_trans.id_payment_instrument)
where %%NETMETER%%..t_pending_payment_trans_dtl.id_pending_payment = %%NETMETER%%..t_pending_payment_trans.id_pending_payment

INSERT INTO %%NETMETER%%..t_pending_payment_trans_dtl (id_pending_payment, nm_invoice_num, dt_invoice, nm_po_number, n_amount)
select PMT.id_pending_payment, TMP.invoice_string, TMP.invoice_date, '', TMP.amtToCharge
from %%STAGINGDB%%..%1% TMP INNER JOIN %%NETMETER%%..t_pending_payment_trans PMT ON ( PMT.id_acc = TMP.id_acc AND PMT.id_interval = TMP.id_interval AND PMT.id_payment_instrument = TMP.id_payment_instrument)
where not exists	
	(select t.id_interval, t.id_acc from %%NETMETER%%..t_pending_payment_trans_dtl pptd 
	 inner join %%NETMETER%%..t_pending_payment_trans t ON (t.id_pending_payment = pptd.id_pending_payment) 
	 where TMP.id_acc = t.id_acc and TMP.id_interval = t.id_interval and TMP.id_payment_instrument = t.id_payment_instrument)
				  
			  
	   