
        SELECT 
          id_prop,
          id_usage_cycle,
          id_cycle_type
        FROM 
          t_aggregate
        WHERE 
          id_prop=%%ID_PROP%%
      