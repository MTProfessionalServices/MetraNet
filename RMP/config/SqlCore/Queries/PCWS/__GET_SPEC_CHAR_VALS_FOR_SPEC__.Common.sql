
                  select 
                    vals.id_scv ID,
                    vals.c_is_default IsDefault,
                    vals.n_value ValueId,
                    vals.nm_value Value
                  from t_spec_val_map map
                  inner join t_spec_char_values vals on map.id_scv = vals.id_scv
                  where id_spec = %%ID_SPEC%%
            