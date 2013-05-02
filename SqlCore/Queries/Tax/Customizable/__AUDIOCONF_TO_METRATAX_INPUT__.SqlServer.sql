
/*__AUDIOCONF_TO_METRATAX_INPUT__*/

declare @id_usage_interval int
declare @id_bill_group int;
declare @tax_vendor int;

set @id_usage_interval = %%ID_USAGE_INTERVAL%%
set @id_bill_group = %%ID_BILL_GROUP%%
set @tax_vendor = %%TAX_VENDOR%%

/* Bridge charge */
insert into t_tax_input_%%ID_TAX_RUN%% with (tablock)
(id_sess, id_usage_interval, charge_name, id_acc, amount, invoice_date, product_code)
select 
  pvc.id_sess, 
  pvc.id_usage_interval,
  'Bridge',
  au.id_acc,
  pvc.c_BridgeAmount,
  GetDate() InvoiceDate,
  'MT100' ProductCode
from 
  t_pv_audioconfconnection pvc 
  inner join t_acc_usage au on au.id_sess = pvc.id_sess and au.id_usage_interval = pvc.id_usage_interval
  inner join t_av_internal i on au.id_acc = i.id_acc
  inner join t_billgroup_member bgm on bgm.id_acc = au.id_acc and bgm.id_billgroup = @id_bill_group
where
  i.c_TaxVendor = @tax_vendor
  and au.id_usage_interval = @id_usage_interval


/* Transport charge */
insert into t_tax_input_%%ID_TAX_RUN%% with (tablock)
(id_sess, id_usage_interval, charge_name, id_acc, amount, invoice_date, product_code)
select 
  pvc.id_sess, 
  pvc.id_usage_interval,
  'Transport' ChargeName,
  au.id_acc,
  pvc.c_TransportAmount,
  GetDate() InvoiceDate,
  'MT100' ProductCode
from 
  t_pv_audioconfconnection pvc 
  inner join t_acc_usage au on au.id_sess = pvc.id_sess and au.id_usage_interval = pvc.id_usage_interval
  inner join t_av_internal i on au.id_acc = i.id_acc
  inner join t_billgroup_member bgm on bgm.id_acc = au.id_acc and bgm.id_billgroup = @id_bill_group
where
  i.c_TaxVendor = @tax_vendor
  and au.id_usage_interval = @id_usage_interval

      