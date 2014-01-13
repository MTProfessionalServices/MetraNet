
          SELECT 
            cpd.id_prop, cpd.id_pi, bp.nm_name, bp.nm_display_name,
            cpd.nm_servicedefprop, cpd.nm_preferredcountertype, cpd.n_order
          FROM t_counterpropdef cpd, t_vw_base_props bp
          WHERE 
            cpd.id_prop = %%ID_PROP%% AND
            cpd.id_prop = bp.id_prop AND bp.id_lang_code = %%ID_LANG%%
       