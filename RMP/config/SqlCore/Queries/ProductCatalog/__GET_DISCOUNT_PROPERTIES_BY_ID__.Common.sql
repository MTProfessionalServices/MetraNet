
        SELECT 
          id_prop,
          n_value_type,
          id_usage_cycle,
          id_cycle_type,
          id_distribution_cpd
        FROM 
          t_discount
        WHERE 
          id_prop=%%ID_PROP%%
      