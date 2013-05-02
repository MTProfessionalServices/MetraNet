
				/* Note that the column b_shareable has been replaced by n_type in the t_pricelist table. */
				/* The mapping is: b_shareable = 'N', n_type = 0 */
				/* 								 b_shareable = 'Y', n_type = 1 */
				/* Additionally, there is now a third type of pricelists for the product offering internal pricelist  */
      
        select t_rsched.id_sched, t_rsched.id_pt, t_rsched.id_eff_date, t_rsched.id_pricelist, t_rsched.id_pi_template,
        t_vw_base_props.n_desc, t_vw_base_props.nm_name, t_vw_base_props.nm_desc,
        te.n_begintype, te.dt_start, te.n_beginoffset,
        te.n_endtype, te.dt_end, te.n_endoffset,
        ts.id_sub,ts.id_acc,
        /* corresponds to MTPriceListMappingType */
        case when ts.id_sub is NULL then 0 /* normal */
	        else case when ts.id_acc is not NULL then 1 /* individual icB */
		        else 2 /* group IcB */
	        end
        end as type
        from t_rsched
        JOIN t_vw_base_props ON t_rsched.id_sched = t_vw_base_props.id_prop and t_vw_base_props.id_lang_code = %%ID_LANG%%
        JOIN t_effectivedate te ON t_rsched.id_eff_date = te.id_eff_date
        JOIN t_pricelist tp on tp.id_pricelist = t_rsched.id_pricelist
        LEFT OUTER JOIN t_pl_map map on map.id_pricelist = tp.id_pricelist AND tp.n_type = 1 AND map.id_sub is not NULL
        LEFT OUTER JOIN t_sub ts on ts.id_sub = map.id_sub
        where t_rsched.id_sched = %%ID%%
      