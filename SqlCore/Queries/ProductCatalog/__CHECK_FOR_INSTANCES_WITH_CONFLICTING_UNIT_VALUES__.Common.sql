
SELECT rv.n_value, bp.nm_display_name, rv.id_sub, sub.id_acc, 'Enum' as Failure 
FROM 
t_recur_value rv
INNER JOIN t_base_props bp ON rv.id_prop=bp.id_prop
INNER JOIN t_sub sub ON rv.id_sub=sub.id_sub
INNER JOIN t_pl_map pl ON rv.id_prop=pl.id_pi_instance
WHERE NOT EXISTS (SELECT * FROM t_recur_enum re WHERE rv.id_prop = re.id_prop AND re.enum_value=rv.n_value)
AND
pl.id_paramtable IS NULL
AND
pl.id_pi_template=%%ID_PROP%%
AND
rv.tt_end = %%DT_MAX_DATE%%
AND 
rv.vt_end >= %%DT_CURRRENT_DATE%%
UNION ALL
SELECT rv.n_value, bp.nm_display_name, rv.id_sub, sub.id_acc, 'MinMax' as Failure 
FROM 
t_recur_value rv
INNER JOIN t_recur r ON rv.id_prop=r.id_prop
INNER JOIN t_base_props bp ON rv.id_prop=bp.id_prop
INNER JOIN t_sub sub ON rv.id_sub=sub.id_sub
INNER JOIN t_pl_map pl ON rv.id_prop=pl.id_pi_instance
WHERE 
(rv.n_value < r.min_unit_value OR rv.n_value > r.max_unit_value)
AND
pl.id_paramtable IS NULL
AND
pl.id_pi_template=%%ID_PROP%%
AND
rv.tt_end = %%DT_MAX_DATE%%
AND 
rv.vt_end >= %%DT_CURRRENT_DATE%%
UNION ALL
SELECT rv.n_value, bp.nm_display_name, rv.id_sub, sub.id_acc, 'Integral' as Failure 
FROM 
t_recur_value rv
INNER JOIN t_recur r ON rv.id_prop=r.id_prop
INNER JOIN t_base_props bp ON rv.id_prop=bp.id_prop
INNER JOIN t_sub sub ON rv.id_sub=sub.id_sub
INNER JOIN t_pl_map pl ON rv.id_prop=pl.id_pi_instance
WHERE 
r.b_integral 
AND
rv.n_value <> ROUND(rv.n_value, 0)
AND
pl.id_paramtable IS NULL
AND
pl.id_pi_template=%%ID_PROP%%
AND
rv.tt_end = %%DT_MAX_DATE%%
AND 
rv.vt_end >= %%DT_CURRRENT_DATE%%
  