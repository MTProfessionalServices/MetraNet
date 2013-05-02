
        UPDATE
          t_aggregate
        SET
          id_usage_cycle = %%ID_USAGE_CYCLE%%,
          id_cycle_type = %%ID_CYCLE_TYPE%%
        WHERE
          id_prop=%%ID_PROP%%
      