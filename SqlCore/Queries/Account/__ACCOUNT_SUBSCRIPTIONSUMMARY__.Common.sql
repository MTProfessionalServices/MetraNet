select
'GroupSubscription' AS 'SubscriptionType',
tb_po.nm_name AS 'ProductOfferingName',
tb_po.nm_desc AS 'ProductOfferingDescription',
tmp.vt_start AS 'SubscriptionStart',
tmp.vt_end AS 'SubscriptionEnd',
tmp.id_po AS 'ProductOfferingId',
tmp.id_sub AS 'SubscriptionId',
1234.99 AS 'RecurringCharge',
plist.nm_currency_code AS 'RecurringChargeCurrency',
 null AS 'PromoCode',
tg.tx_name AS 'GroupSubscriptionName',
tg.tx_desc AS 'GroupSubscriptionDescription'

/*,
sub.id_sub_ext,
tmp.id_acc,
tmp.vt_start dt_start,
tmp.vt_end dt_end,
tb_po.n_name po_n_name,
tb_po.nm_name po_nm_name,
tb_po.n_display_name po_n_display_name,
tb_po.nm_display_name po_nm_display_name,
case when tmp.num_recurring > 0 then 'Y' else 'N' end as b_RecurringCharge,
case when tmp.num_discount > 0 then 'Y' else 'N' end as b_Discount,
case when tmp.num_icbs > 0 then 'Y' else 'N' end as b_PersonalRate,
t_po.b_user_unsubscribe b_user_unsubscribe,
tg.id_group id_group,
tg.tx_name tx_name,
tg.tx_desc tx_desc,
tg.b_visable b_visable,
tg.id_usage_cycle id_usage_cycle,
tg.id_usage_cycle usage_cycle,
tg.b_proportional b_proportional,
tg.id_corporate_account id_corporate_Account,
tg.id_discountaccount id_discountaccount,
tg.b_supportgroupops b_supportgroupops */
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
gsm.id_acc=%%ACCOUNT_ID%%
group by s.id_sub, p.id_po,gsm.id_acc,gsm.vt_start,gsm.vt_end
) tmp
inner join t_sub sub on sub.id_sub=tmp.id_sub
left JOIN t_vw_base_props tb_po on tb_po.id_prop = sub.id_po and tb_po.id_lang_code = 840
INNER JOIN t_group_sub tg on sub.id_group = tg.id_group
inner join t_po on t_po.id_po = tmp.id_po
inner join t_pricelist plist on plist.id_pricelist  = t_po.id_nonshared_pl

UNION

SELECT 
'Subscription' AS 'SubscriptionType',
tb_po.nm_name AS 'ProductOfferingName',
tb_po.nm_desc AS 'ProductOfferingDescription',
sub.vt_start AS 'SubscriptionStart',
sub.vt_end AS 'SubscriptionEnd',
sub.id_po AS 'ProductOfferingId',
sub.id_sub AS 'SubscriptionId',
34.99 AS 'RecurringCharge',
plist.nm_currency_code AS 'RecurringChargeCurrency',
null AS 'PromoCode',
null AS 'GroupSubscriptionName',
null AS 'GroupSubscriptionDescription'
FROM t_sub sub
LEFT JOIN t_vw_base_props tb_po on tb_po.id_prop = sub.id_po and tb_po.id_lang_code = 840
inner join t_po on t_po.id_po = sub.id_po
inner join t_pricelist plist on plist.id_pricelist  = t_po.id_nonshared_pl		
WHERE sub.id_acc = %%ACCOUNT_ID%% and sub.id_group is null

