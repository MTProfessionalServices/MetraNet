
declare @id_usage_interval int
declare @id_bill_group int;
declare @tax_vendor int;

set @id_usage_interval = %%ID_USAGE_INTERVAL%%
set @id_bill_group = %%ID_BILL_GROUP%%
set @tax_vendor = %%TAX_VENDOR%%


insert into t_tax_input_%%ID_TAX_RUN%% with (tablock)
(id_sess, id_usage_interval, invoice_id, charge_name, amount, orig_pcode, term_pcode, svc_addr_pcode, customer_type, invoice_date, is_implied_tax,
round_alg, round_digits, lines, location, product_code, client_resale, inc_code, id_acc, is_regulated, call_duration, telecom_type,
svc_class_ind, lifeline_flag, facilities_flag, franchise_flag, bus_class_ind)

select
    pvc.id_sess,
        pvc.id_usage_interval,       
        pvc.id_usage_interval invoice_id,
        'Cookies Amount',
        au.Amount,
        '0' orig_pcode,
        '0' term_pcode,
        '1248900' svc_addr_pcode,
        'R' customer_type,
        GetDate() InvoiceDate,
        'N' is_implied_tax,
        'BANK' round_alg,
        '0' round_digits,
        '1' lines,
        '1' location,
        'BSPC0001' product_code,
        'S' client_resale,
        'I' inc_code,
        au.id_acc,
        'R' is_regulated,
        '45.0' call_duration,
        'D' telecom_type,
        'D' svc_class_ind,
        'L' lifeline_flag,
        'F' facilities_flag,
        'F' franchise_flag,
        'C-CLEC' bus_class_ind  
from
  t_pv_OrderCookies pvc
  inner join t_acc_usage au on au.id_sess = pvc.id_sess and au.id_usage_interval = pvc.id_usage_interval
  inner join t_av_internal i on au.id_acc = i.id_acc
  inner join t_billgroup_member bgm on bgm.id_acc = au.id_acc and bgm.id_billgroup = @id_bill_group
where
  i.c_TaxVendor = %%TAX_VENDOR%%
  and au.id_usage_interval = %%ID_USAGE_INTERVAL%% 
      