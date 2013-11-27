
			create table t_prod_view (
				id_prod_view int identity not null,
				id_view int not null,
				dt_modified datetime,
				nm_name nvarchar(255),
				nm_table_name varchar(255),
				b_can_resubmit_from char(1) not null,
				CONSTRAINT PK_t_prod_view PRIMARY KEY CLUSTERED (id_prod_view),
				constraint t_prod_view_view_IDX unique (id_view))
		