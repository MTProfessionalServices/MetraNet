
        INSERT INTO t_recur_enum (id_prop, enum_value)
          SELECT pl.id_pi_instance, e.enum_value FROM 
          t_pl_map pl 
          INNER JOIN t_recur_enum e ON e.id_prop=pl.id_pi_template
          WHERE
          pl.id_paramtable IS NULL
          AND
          pl.id_pi_template = %%ID_PROP%%
  