
                select 
	                id_spec Spec,
	                id_entity Entity,
	                c_spec_type SpecType,
	                c_category Category,
	                c_is_required Required,
	                nm_description Description,
	                nm_name Name
                from t_spec_characteristics sc
                where id_entity = %%ID_PO%%

                select 
	                id_spec_detail ID,
	                id_spec SpecId,
	                c_is_default IsDefault,
	                nm_value Value	
                from t_spec_char_details where id_spec = %%ID_SPEC%%
               