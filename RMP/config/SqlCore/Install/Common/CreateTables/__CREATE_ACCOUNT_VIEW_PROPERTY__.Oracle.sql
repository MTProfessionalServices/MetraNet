
			create table t_account_view_prop (
			id_account_view_prop number(10) not null,
			id_account_view number(10) not null,
			nm_name nvarchar2(255) not null,
			nm_data_type varchar2(255) not null,
			nm_column_name nvarchar2(255) not null,
			b_required char(1) not null,
			b_composite_idx char(1) not null,
			b_single_idx char(1) not null,
      b_part_of_key char(1) not null,
      b_exportable char(1) not null,
      b_filterable char(1) not null,
      b_user_visible char(1) not null,
			nm_default_value nvarchar2(255) null,
			n_prop_type number(10) not null,
			nm_space nvarchar2(255) null,
			nm_enum nvarchar2(255) null,
 			b_core char(1) not null,
			constraint t_account_view_prop_IDX1 unique (id_account_view, nm_name),
			constraint pk_t_account_view_prop primary key(id_account_view_prop)
 			)
	 