
SELECT 
/*  __GET_NUMBER_OF_CYCLE_RELATIVE_PI__ */
{fn IFNULL(SUM(CASE WHEN d.id_prop IS NOT NULL AND d.id_usage_cycle IS NULL THEN 1 ELSE 0 END), 0)} as NumDiscounts,
{fn IFNULL(SUM(CASE WHEN a.id_prop IS NOT NULL AND a.id_usage_cycle IS NULL THEN 1 ELSE 0 END), 0)} as NumAggregates,
{fn IFNULL(SUM(CASE WHEN r.id_prop IS NOT NULL AND r.tx_cycle_mode IN ('BCR', 'BCR Constrained') THEN 1 ELSE 0 END), 0)} as NumRCs
FROM 
t_pl_map plm
inner join t_base_props p on plm.id_pi_template=p.id_prop
left outer join t_discount d on plm.id_pi_instance=d.id_prop
left outer join t_aggregate a on plm.id_pi_instance=a.id_prop
left outer join t_recur r on plm.id_pi_instance=r.id_prop
WHERE 
p.n_kind in (15,20,25,40)
and
plm.id_paramtable is null
AND
plm.id_po = %%ID_PO%%
  