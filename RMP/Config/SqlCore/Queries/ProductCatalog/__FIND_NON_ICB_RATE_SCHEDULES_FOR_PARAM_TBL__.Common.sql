
        select rs.id_sched, bpl.nm_name as pl_nm_name, bpi.nm_name as pi_nm_name, brs.nm_desc as rs_nm_desc,
            ed.n_begintype, ed.dt_start, ed.n_beginoffset, ed.n_endtype, ed.dt_end, ed.n_endoffset, pl.n_type
        from t_rsched rs
        join t_vw_base_props bpi on bpi.id_prop = rs.id_pi_template and bpi.id_lang_code = %%ID_LANG%%
        join t_vw_base_props bpl on bpl.id_prop = rs.id_pricelist and bpl.id_lang_code = %%ID_LANG%%
        join t_vw_base_props brs on brs.id_prop = rs.id_sched and brs.id_lang_code = %%ID_LANG%%
        join t_effectivedate ed on ed.id_eff_date = rs.id_eff_date
        join t_pricelist pl on pl.id_pricelist = rs.id_pricelist
        where pl.n_type = 1 and rs.id_pt = %%PT%% %%EXTRA_FILTERS%%
      