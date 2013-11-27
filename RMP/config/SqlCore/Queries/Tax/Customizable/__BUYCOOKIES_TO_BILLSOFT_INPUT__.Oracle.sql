declare
id_usage_interval int;
id_bill_group int;
tax_vendor int;

begin
id_usage_interval := %%ID_USAGE_INTERVAL%%;
id_bill_group := %%ID_BILL_GROUP%%;
tax_vendor := %%TAX_VENDOR%%;

insert into t_tax_input_%%ID_TAX_RUN%% (id_tax_charge, id_sess, id_usage_interval,invoice_id, charge_name, amount, orig_pcode,
term_pcode, svc_addr_pcode, customer_type, invoice_date, is_implied_tax, round_alg, round_digits, lines, location, product_code, 
client_resale, inc_code, id_acc, is_regulated, call_duration, telecom_type,svc_class_ind, lifeline_flag, facilities_flag, franchise_flag, bus_class_ind)

select
    seq_t_tax_input_%%ID_TAX_RUN%%.nextval,
	pvc.id_sess,
        pvc.id_usage_interval,       
        pvc.id_usage_interval invoice_id,
        'Cookies Amount',
        au.Amount,
        '0' orig_pcode,
        '0' term_pcode,
        '1248900' svc_addr_pcode,
        'R' customer_type,
        pvc.c_ordertime invoice_date,
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
  inner join t_billgroup_member bgm on bgm.id_acc = au.id_acc and bgm.id_billgroup = %%ID_BILL_GROUP%%
where
  i.c_TaxVendor = %%TAX_VENDOR%%
  and au.id_usage_interval = %%ID_USAGE_INTERVAL%%;
end;  

