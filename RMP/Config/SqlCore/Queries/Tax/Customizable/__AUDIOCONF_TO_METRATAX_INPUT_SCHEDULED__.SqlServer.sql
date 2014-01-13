
/*__AUDIOCONF_TO_METRATAX_INPUT_SCHEDULED__*/

declare @dt_start datetime
declare @dt_end datetime
declare @tax_vendor int;

set @dt_start = %%START_DATE%%
set @dt_end = %%END_DATE%%
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
where
  i.c_TaxVendor = @tax_vendor
  and au.dt_session >= @dt_start
  and au.dt_session <@dt_end


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
where
  i.c_TaxVendor = @tax_vendor
  and au.dt_session >= @dt_start
  and au.dt_session <@dt_end

      