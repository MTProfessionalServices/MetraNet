
			create table t_service_def_prop (
			id_service_def_prop int identity not null,
			id_service_def int not null,
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
			constraint t_service_def_prop_view_name_IDX unique (id_service_def, nm_name)

      )
      alter table t_service_def_prop add constraint pk_t_service_def_prop
       primary key(id_service_def_prop)
	 