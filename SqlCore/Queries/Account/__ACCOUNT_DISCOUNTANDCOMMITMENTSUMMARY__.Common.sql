select
'Group' AS 'SubscriptionType',
tb_po.nm_name AS 'ProductOfferingName',
tb_po.nm_desc AS 'ProductOfferingDescription',
null AS 'PromoCode',
tmp.vt_start AS 'SubscriptionStart',
tmp.vt_end AS 'SubscriptionEnd',
tmp.id_po AS 'ProductOfferingId',
tmp.id_sub AS 'SubscriptionId',
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
/*  same column is returned twice with different name because of different code wanting */
/*  different column names */
tg.id_corporate_account id_corporate_Account,
tg.id_corporate_account corporate_Account,
/*  same column is returned twice with different name because of different code wanting */
/*  different column names */
tg.id_discountaccount id_discountaccount,
tg.id_discountaccount discount_account,
tg.b_supportgroupops b_supportgroupops
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

		