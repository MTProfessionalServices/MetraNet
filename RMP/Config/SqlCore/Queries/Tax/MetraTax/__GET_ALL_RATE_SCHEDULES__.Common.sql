
           select 
                  t_base_props.nm_name,
		  t_rsched.id_sched,
	       t_effectivedate.n_begintype,
	       t_effectivedate.dt_start,
	       t_effectivedate.n_endtype,
	       t_effectivedate.dt_end
           from t_base_props
           inner join t_rsched on t_rsched.id_pt = t_base_props.id_prop
           inner join t_effectivedate on t_rsched.id_eff_date = t_effectivedate.id_eff_date
      