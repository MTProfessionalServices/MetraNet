
                select
                  cv.id_scv SpecCharValId,
                  cv.id_entity EntityId,
                  cv.nm_value Value,
                  cv.c_start_date StartDate,
                  cv.c_end_date EndDate,
                  cv.c_spec_name SpecName,
                  cv.c_spec_type SpecType,
                  spec.c_user_visible UserVisible,
                  spec.c_user_editable UserEditable
                from t_char_values cv
                inner join t_spec_val_map map on cv.id_scv = map.id_scv
                inner join t_spec_characteristics spec on map.id_spec = spec.id_spec 
            