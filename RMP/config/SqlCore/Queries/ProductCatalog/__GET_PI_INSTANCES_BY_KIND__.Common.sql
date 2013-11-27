
        SELECT bp.id_prop AS id_instance
        FROM t_base_props bp, t_pl_map pl
        WHERE
        bp.id_prop = pl.id_pi_instance AND
        bp.n_kind = %%KIND%% AND 
        pl.id_pi_instance_parent is NULL AND 
        pl.id_paramtable is NULL
      