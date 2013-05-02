
        SELECT t_pi.nm_servicedef, t_pi.id_pi, t_base_props.n_kind
        FROM t_base_props INNER JOIN t_pi ON t_base_props.id_prop = t_pi.id_pi
        WHERE t_base_props.n_kind = 20 or t_base_props.n_kind = 25
      