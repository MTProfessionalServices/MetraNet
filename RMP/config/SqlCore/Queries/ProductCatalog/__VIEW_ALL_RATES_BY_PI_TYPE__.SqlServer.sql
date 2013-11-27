
				select 
				DISTINCT(template_props.nm_display_name) template_display_name /* template display name */
				,tb_pl.nm_name pl_name/* pricelist display name, */
				,b_personal_rate = case when t_pricelist.n_type = 0 then 'Y' else 'N' end
				,trule_props.nm_name paramtable_name/* parameter table name */
				,t_rulesetdefinition.nm_instance_tablename param_db_tablename /* parameter table name, */
				,t_rsched.id_sched /* rate schedule ID, */
				,sched_prop.nm_desc sched_desc/* rate schedule description, */
				,te.n_begintype,te.dt_start,te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset
				from t_pi_template tpit,
				t_pi,t_base_props tb,t_base_props template_props
				,t_base_props tb_pl
				,t_rsched
				,t_pricelist
				,t_base_props sched_prop
				,t_effectivedate te
				,t_rulesetdefinition
				,t_base_props trule_props
				,t_pi_rulesetdef_map
				where 
				tb.n_kind = 10 AND t_pi.id_pi = tb.id_prop AND tpit.id_pi = t_pi.id_pi AND
				template_props.id_prop = tpit.id_template 
				AND t_rsched.id_pi_template = tpit.id_template AND t_rsched.id_pt = t_rulesetdefinition.id_paramtable
				AND t_pricelist.id_pricelist = t_rsched.id_pricelist 
				AND tb_pl.id_prop = t_rsched.id_pricelist
				AND sched_prop.id_prop  = t_rsched.id_Sched
				AND te.id_eff_date = t_rsched.id_eff_date AND
				t_pi_rulesetdef_map.id_pi = t_pi.id_pi AND
				t_rulesetdefinition.id_paramtable = t_pi_rulesetdef_map.id_pt AND
				trule_props.id_prop = t_rulesetdefinition.id_paramtable
				order by template_display_name,pl_name,paramtable_name,te.dt_start asc
			