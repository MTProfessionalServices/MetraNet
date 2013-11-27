
        select t_rsched.id_sched, t_rsched.id_eff_date, 
        t_vw_base_props.n_desc, t_vw_base_props.nm_name, t_vw_base_props.nm_desc,
        te.n_begintype, te.dt_start, te.n_beginoffset,
        te.n_endtype, te.dt_end, te.n_endoffset,
        %%SUMMARY_PROPERTY%% Summary
           from t_rsched
           JOIN t_vw_base_props ON t_rsched.id_sched = t_vw_base_props.id_prop and t_vw_base_props.id_lang_code = %%ID_LANG%%
           JOIN t_effectivedate te ON t_rsched.id_eff_date = te.id_eff_date
           JOIN t_pl_map ON t_rsched.id_pi_template = t_pl_map.id_pi_template and t_pl_map.id_paramtable is null
           %%SUMMARY_JOIN%%
           where t_rsched.id_pricelist=%%PRICELIST%% and t_rsched.id_pt=%%PT%%
           and t_pl_map.id_pi_instance=%%PI_INSTANCE%%
      