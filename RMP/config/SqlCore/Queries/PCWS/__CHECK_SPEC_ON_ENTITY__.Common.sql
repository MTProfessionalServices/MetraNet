
                  select COUNT(*) NumVals from t_char_values val
                  inner join t_sub sub on val.id_entity = sub.id_sub
                  inner join t_spec_val_map map on val.id_scv = map.id_scv
                  inner join t_entity_specs specs on map.id_spec = specs.id_spec
                  where specs.id_spec = %%ID_SPEC%% and specs.id_entity = %%ID_ENTITY%% and sub.id_po = %%ID_ENTITY%%
            