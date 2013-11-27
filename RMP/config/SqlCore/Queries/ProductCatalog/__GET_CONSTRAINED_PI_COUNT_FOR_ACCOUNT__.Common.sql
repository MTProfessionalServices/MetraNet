
SELECT COUNT(*) pi_count  
	FROM t_sub,
	t_pl_map, t_po,
	t_base_props tb,
/*  create a pseudo table that holds the id_prop and id_cycle type of the three */
/*  tables that could have billing cycle constrained cycles */
	(
		SELECT id_prop, id_cycle_type FROM t_recur
  	UNION ALL SELECT id_prop, id_cycle_type FROM t_discount
	  union all select id_prop, id_cycle_type FROM t_aggregate
	) pi_cycles
WHERE t_sub.id_acc = %%ID_ACC%% AND
  /* verify subscription effective date */
  ((%%%SYSTEMDATE%%% BETWEEN t_sub.vt_start AND t_sub.vt_end) OR %%%SYSTEMDATE%%% <= t_sub.vt_start)
	AND t_pl_map.id_po = t_sub.id_po
  AND t_pl_map.id_pi_instance = pi_cycles.id_prop
  /* use the entry where the param table is not specified (there is one per priceable item) */
  AND t_pl_map.id_paramtable IS NULL
	/* get the kind from t_base_props */
	AND tb.id_prop = t_pl_map.id_pi_template
  /* this is the key: the cycle_type is not null when the cycle is a fixed cycle type */
	/* also, make sure that the subscribed product offerings do not contain any  */
	/* recurring charges */
  AND 
	(pi_cycles.id_cycle_type IS NOT null OR tb.n_kind = 20 OR tb.n_kind = 25)
				