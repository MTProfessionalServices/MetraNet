
        SELECT bp.id_prop AS id_template
        FROM t_base_props bp, t_pi_template pit
        WHERE
        bp.id_prop = pit.id_template AND
        bp.n_kind = %%KIND%% AND 
        pit.id_template_parent is NULL
      