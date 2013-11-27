
      select
			id_prod_view_prop,
			id_prod_view,
			nm_name,
			nm_data_type,
			nm_column_name,
			b_required,
			b_composite_idx,
			b_single_idx,
      b_part_of_key,
      b_exportable,
      b_filterable,
      b_user_visible,
			nm_default_value,
			n_prop_type,
			nm_space,
			nm_enum,
      b_core,
	  description
      from t_prod_view_prop where
			id_prod_view_prop = %%ID_PROD_VIEW_PROP%%
			