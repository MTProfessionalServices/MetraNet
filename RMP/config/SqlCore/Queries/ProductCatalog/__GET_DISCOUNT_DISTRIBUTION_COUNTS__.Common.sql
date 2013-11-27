
SELECT 
/*  __GET_DISCOUNT_DISTRIBUTION_COUNTS__ */
{fn IFNULL(SUM(CASE WHEN d.id_distribution_cpd IS NOT NULL AND cm.id_counter IS NOT NULL THEN 1 ELSE 0 END), 0)} AS NumDistributedDiscounts,
{fn IFNULL(SUM(CASE WHEN d.id_distribution_cpd IS NOT NULL AND cm.id_counter IS NOT NULL THEN 0 ELSE 1 END), 0)} AS NumUndistributedDiscounts
FROM 
t_pl_map plm
inner join t_discount d on plm.id_pi_template=d.id_prop
left outer join t_counter_map cm on cm.id_pi=d.id_prop and d.id_distribution_cpd=cm.id_cpd
WHERE 
plm.id_paramtable is null
AND
plm.id_po = %%ID_PO%%
  