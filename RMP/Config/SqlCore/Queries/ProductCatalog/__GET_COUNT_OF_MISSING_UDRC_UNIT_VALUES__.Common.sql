
/*  counts the number of UDRCs for this group sub that do not have unit values assigned */
SELECT COUNT(*)
FROM t_group_sub gs
INNER JOIN t_sub sub ON sub.id_group = gs.id_group
INNER JOIN t_pl_map typemap ON typemap.id_po = sub.id_po
INNER JOIN t_base_props type_bp ON type_bp.id_prop = typemap.id_pi_type
INNER JOIN t_recur rc ON rc.id_prop = typemap.id_pi_instance
LEFT OUTER JOIN t_recur_value uv ON uv.id_prop = rc.id_prop AND
                                    uv.id_sub = sub.id_sub
WHERE 
  typemap.id_paramtable IS NULL AND
  type_bp.nm_name = 'Unit Dependent Recurring Charge' AND
  uv.id_prop IS NULL AND 
  gs.id_group = %%ID_GROUP%%
