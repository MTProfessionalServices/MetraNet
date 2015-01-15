select
'GroupSubscription' AS SubscriptionType,
COALESCE(tb_po.nm_name, dtb_po.nm_name) AS ProductOfferingName,
COALESCE(tb_po.nm_desc, dtb_po.nm_desc) AS ProductOfferingDescription,
tmp.vt_start AS SubscriptionStart,
tmp.vt_end AS SubscriptionEnd,
tmp.id_po AS ProductOfferingId,
tmp.id_sub AS SubscriptionId,
1234.99 AS RecurringCharge,
plist.nm_currency_code AS RecurringChargeCurrency,
 null AS PromoCode,
tg.tx_name AS GroupSubscriptionName,
tg.tx_desc AS GroupSubscriptionDescription
from
(
select s.id_sub, p.id_po,gsm.id_acc,gsm.vt_start,gsm.vt_end,
sum(case when (bp.n_kind = 20 or bp.n_kind = 25) and plm.id_paramtable is null then 1 else 0 end) as num_recurring,
sum(case when bp.n_kind = 40 and plm.id_paramtable is null then 1 else 0 end) as num_discount,
sum(case when plm.id_sub is not null then 1 else 0 end) as num_icbs
from
t_gsubmember gsm
inner join t_group_sub gs on gs.id_group=gsm.id_group
inner join t_sub s on s.id_group=gs.id_group
inner join t_po p on s.id_po=p.id_po
inner join t_pl_map plm on plm.id_po=p.id_po
inner join t_base_props bp on bp.id_prop=plm.id_pi_type
where
(plm.id_paramtable is null or plm.id_sub=s.id_sub)
and
gsm.id_acc = %%ACCOUNT_ID%%
group by s.id_sub, p.id_po,gsm.id_acc,gsm.vt_start,gsm.vt_end
) tmp
inner join t_sub sub on sub.id_sub=tmp.id_sub
INNER JOIN t_base_props dtb_po on dtb_po.id_prop = sub.id_po
left JOIN t_vw_base_props tb_po on tb_po.id_prop = sub.id_po and tb_po.id_lang_code = %%LANG_ID%%
INNER JOIN t_group_sub tg on sub.id_group = tg.id_group
inner join t_po on t_po.id_po = tmp.id_po
inner join t_pricelist plist on plist.id_pricelist  = t_po.id_nonshared_pl

UNION

SELECT 
'Subscription' AS SubscriptionType,
COALESCE(tb_po.nm_name, dtb_po.nm_name) AS ProductOfferingName,
COALESCE(tb_po.nm_desc, dtb_po.nm_desc) AS ProductOfferingDescription,
sub.vt_start AS SubscriptionStart,
sub.vt_end AS SubscriptionEnd,
sub.id_po AS ProductOfferingId,
sub.id_sub AS SubscriptionId,
34.99 AS RecurringCharge,
plist.nm_currency_code AS RecurringChargeCurrency,
null AS PromoCode,
null AS GroupSubscriptionName,
null AS GroupSubscriptionDescription
FROM t_sub sub
INNER JOIN t_base_props dtb_po on dtb_po.id_prop = sub.id_po
LEFT JOIN t_vw_base_props tb_po on tb_po.id_prop = sub.id_po and tb_po.id_lang_code = %%LANG_ID%%
inner join t_po on t_po.id_po = sub.id_po
inner join t_pricelist plist on plist.id_pricelist  = t_po.id_nonshared_pl		
WHERE sub.id_acc = %%ACCOUNT_ID%% and sub.id_group is null