
/*  counts the number of missing charge accounts for group sub */
SELECT COUNT(*)
FROM t_group_sub gs
INNER JOIN t_sub sub ON sub.id_group = gs.id_group
INNER JOIN t_pl_map typemap ON typemap.id_po = sub.id_po
INNER JOIN t_recur rc ON rc.id_prop = typemap.id_pi_instance
LEFT OUTER JOIN t_gsub_recur_map ca ON ca.id_prop = rc.id_prop AND
                                       ca.id_group = gs.id_group
WHERE 
  typemap.id_paramtable IS NULL AND
  ca.id_prop IS NULL AND /* only return joins that failed */
  rc.b_charge_per_participant = 'N' AND /* per subscription */
  gs.id_group = %%ID_GROUP%%
