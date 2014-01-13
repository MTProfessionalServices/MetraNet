
                  select
                    id_spec ID,
                    c_spec_type SpecType,
                    id_category CategoryId,
                    c_category Category,
                    c_is_required IsRequired,
                    n_description DescId,
                    nm_description Description,
                    n_name NameId,
                    nm_name Name,
                    c_user_visible UserVisible,
                    c_user_editable UserEditable,
                    c_min_value MinValue,
                    c_max_value MaxValue
                  from t_spec_characteristics 
                  where id_spec = %%ID_SPEC%%
            