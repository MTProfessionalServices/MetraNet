
			create proc UpdateProductViewProperty
			@a_id_prod_view_prop int,
			@a_id_prod_view int,
			@a_nm_name nvarchar(255),
			@a_nm_data_type nvarchar(255),
			@a_nm_column_name nvarchar(255),
			@a_b_required char(1),
			@a_b_composite_idx char(1),
			@a_b_single_idx char(1),
      @a_b_part_of_key char(1),
      @a_b_exportable char(1),
      @a_b_filterable char(1),
      @a_b_user_visible char(1),
			@a_nm_default_value nvarchar(255),
			@a_n_prop_type int,
			@a_nm_space nvarchar(255),
			@a_nm_enum nvarchar(255),
      @a_b_core char(1),
	  @a_description nvarchar(255)
			as
      update t_prod_view_prop
			set
			id_prod_view=@a_id_prod_view,
			nm_name=@a_nm_name,
			nm_data_type=@a_nm_data_type,
			nm_column_name=@a_nm_column_name,
			b_required=@a_b_required,
			b_composite_idx=@a_b_composite_idx,
			b_single_idx=@a_b_single_idx,
      b_part_of_key=@a_b_part_of_key,
      b_exportable=@a_b_exportable,
      b_filterable=@a_b_filterable,
      b_user_visible=@a_b_user_visible,
			nm_default_value=@a_nm_default_value,
			n_prop_type=@a_n_prop_type,
			nm_space=@a_nm_space,
			nm_enum=@a_nm_enum,
      b_core=@a_b_core,
	  description=@a_description
			where
			id_prod_view_prop=@a_id_prod_view_prop
	