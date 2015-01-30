
select sub.id_po,
/*  __GET_ALL_SUBSCRIPTIONS__ */
sub.id_sub_ext,
sub.id_sub,
sub.id_acc,
sub.vt_start dt_start,
sub.vt_end dt_end,
sub.vt_start,
sub.vt_end,
COALESCE(tb_po.n_name, tbp.n_name) po_n_name,
COALESCE(tb_po.nm_name, tbp.nm_name) po_nm_name,
COALESCE(tb_po.n_display_name, tbp.n_display_name) po_n_display_name,
COALESCE(tb_po.nm_display_name, tbp.nm_display_name) po_nm_display_name,
case when tmp.num_recurring > 0 then 'Y' else 'N' end as b_RecurringCharge,
case when tmp.num_discount > 0 then 'Y' else 'N' end as b_Discount,
case when tmp.num_icbs > 0 then 'Y' else 'N' end as b_PersonalRate,
t_po.b_user_unsubscribe b_user_unsubscribe
%%COLUMNS%%
from 
(
select s.id_sub,
sum(case when (bp.n_kind = 20 or bp.n_kind = 25) and plm.id_paramtable is null then 1 else 0 end) as num_recurring,
sum(case when bp.n_kind = 40 and plm.id_paramtable is null then 1 else 0 end) as num_discount,
sum(case when plm.id_sub is not null then 1 else 0 end) as num_icbs
from
t_sub s with(index(fk1idx_T_SUB)) 
inner join t_po p on s.id_po=p.id_po
inner join t_pl_map plm on plm.id_po=p.id_po
inner join t_base_props bp on bp.id_prop=plm.id_pi_type
where
(plm.id_paramtable is null or plm.id_sub=s.id_sub)
and
s.id_acc=%%ID_ACC%%
group by s.id_sub
) tmp
INNER JOIN t_sub sub ON sub.id_sub=tmp.id_sub
/*  Need this because of PO extended properties in JOINS will refer to this table */
INNER JOIN t_po ON t_po.id_po = sub.id_po
INNER JOIN t_base_props tbp ON tbp.id_prop = t_po.id_po
LEFT OUTER JOIN t_vw_base_props tb_po ON tb_po.id_prop = t_po.id_po AND tb_po.id_lang_code = %%ID_LANG%%
%%JOINS%%
				