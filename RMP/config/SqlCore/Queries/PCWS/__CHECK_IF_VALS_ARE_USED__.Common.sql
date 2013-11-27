
                  select COUNT(*) NumVals from t_sub s
                  inner join t_char_values cv on s.id_sub = cv.id_entity
                  inner join t_spec_val_map map on cv.id_scv = map.id_scv 
                  inner join t_entity_specs specs on map.id_spec = specs.id_spec
                  where specs.id_spec = %%ID_SPEC%% and map.id_scv in (%%ID_SCV%%) 
                  %%ENTITY_CLAUSE%%
            