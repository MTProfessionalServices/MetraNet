
			create table t_base_props ( 
				id_prop int identity not null,
				n_kind int not null,
				n_name int null,
				n_desc int null,
				nm_name nvarchar(255) null,
				nm_desc nvarchar(4000) null,
				b_approved char(1) null,
				b_archive char(1) null,
				n_display_name int null,
				nm_display_name nvarchar(255) null,
				constraint t_base_props_PK primary key (id_prop))
				CREATE NONCLUSTERED INDEX nm_name_idx ON t_base_props (nm_name)
			