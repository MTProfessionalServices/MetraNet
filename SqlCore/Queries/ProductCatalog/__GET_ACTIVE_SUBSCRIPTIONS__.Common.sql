
select tmp.id_po,
tmp.id_sub,
tmp.id_acc,
sub.vt_start dt_start,
sub.vt_end dt_end,
/*  For forward compatibility with 3.0 return the same */
/*  columns with two names (the old and the new). */
sub.vt_start vt_start,
sub.vt_end vt_end,
tb_po.n_name po_n_name,
tb_po.nm_name po_nm_name,
tb_po.n_display_name po_n_display_name,
tb_po.nm_display_name po_nm_display_name,
case when tmp.num_recurring > 0 then 'Y' else 'N' end as b_RecurringCharge,
case when tmp.num_discount > 0 then 'Y' else 'N' end as b_Discount,
case when tmp.num_icbs > 0 then 'Y' else 'N' end as b_PersonalRate,
t_po.b_user_unsubscribe b_user_unsubscribe,
sub.id_sub_ext
%%COLUMNS%%
from
(
select s.id_sub, p.id_po,s.id_acc,
sum(case when (bp.n_kind = 20 or bp.n_kind = 25) and plm.id_paramtable is null then 1 else 0 end) as num_recurring,
sum(case when bp.n_kind = 40 and plm.id_paramtable is null then 1 else 0 end) as num_discount,
sum(case when plm.id_sub is not null then 1 else 0 end) as num_icbs
from
t_sub s
inner join t_po p on s.id_po=p.id_po
inner join t_pl_map plm on plm.id_po=s.id_po and p.id_po = plm.id_po
inner join t_base_props bp on bp.id_prop=plm.id_pi_type
where
(plm.id_paramtable is null or plm.id_sub=s.id_sub)
and
s.id_acc=%%ID_ACC%%
group by s.id_sub, p.id_po,s.id_acc
) tmp
inner join t_sub sub on sub.id_sub=tmp.id_sub
INNER JOIN t_vw_base_props tb_po on tb_po.id_prop = sub.id_po and tb_po.id_lang_code = %%ID_LANG%%
inner join t_po on t_po.id_po = tmp.id_po
%%JOINS%%
AND (('%%ACTIVE%%' = 'Y' AND sub.vt_end >= %%%SYSTEMDATE%%%) or
('%%ACTIVE%%' = 'N' AND sub.vt_end < %%%SYSTEMDATE%%%))
        