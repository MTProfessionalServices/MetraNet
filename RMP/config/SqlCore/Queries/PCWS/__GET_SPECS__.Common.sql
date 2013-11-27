
	           select
               id_spec ID,
               c_spec_type SpecType,
               c_category Category,
               c_is_required IsRequired,
               nm_description Description,
               nm_name Name,
               c_user_visible UserVisible,
               c_user_editable UserEditable
             from t_spec_characteristics
             