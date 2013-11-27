
			create table t_prod_view_prop (
			id_prod_view_prop int identity not null,
			id_prod_view int not null,
			nm_name nvarchar(255) not null,
			nm_data_type varchar(255) not null,
			nm_column_name nvarchar(255) not null,
			b_required char(1) not null,
			b_composite_idx char(1) not null,
			b_single_idx char(1) not null,
      b_part_of_key char(1) not null,
      b_exportable char(1) not null,
      b_filterable char(1) not null,
      b_user_visible char(1) not null,
			nm_default_value nvarchar(255) null,
			n_prop_type int not null,
			nm_space nvarchar(255) null,
			nm_enum nvarchar(255) null,
      b_core char(1) not null,
	  description nvarchar(255) null,
			constraint t_prod_view_prop_view_name_IDX unique (id_prod_view, nm_name)

      )
      alter table t_prod_view_prop add constraint pk_t_prod_view_prop
       primary key(id_prod_view_prop)
	 