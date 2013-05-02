
			create table t_param_table_prop (
			id_param_table_prop int identity not null,
			id_param_table int not null,
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
      			b_columnoperator char(1) not null,
	  		nm_operatorval varchar(50) null,
			constraint t_param_table_prop_view_name_IDX unique (id_param_table, nm_name)

      			)
      			alter table t_param_table_prop add constraint pk_t_param_table_prop
      			 primary key(id_param_table_prop)
	 