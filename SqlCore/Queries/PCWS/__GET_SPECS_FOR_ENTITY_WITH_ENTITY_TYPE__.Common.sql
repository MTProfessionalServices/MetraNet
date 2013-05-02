
                  select
                    specs.id_spec ID,
                    specs.c_spec_type SpecType,
                    specs.c_category Category,
                    specs.c_is_required IsRequired,
                    specs.nm_description Description,
                    specs.nm_name Name,
                    specs.c_user_visible UserVisible,
                    specs.c_user_editable UserEditable,
                    specs.c_min_value MinValue,
                    specs.c_max_value MaxValue,
                    es.c_display_order DisplayOrder
                  from t_entity_specs es
                  inner join t_spec_characteristics specs on es.id_spec = specs.id_spec
                  where id_entity = %%ENTITY_ID%%
				  and entity_type = %%ENTITY_TYPE%%