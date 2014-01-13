
			create proc InsertProductView
			@a_id_view int,
			@a_nm_name nvarchar(255),
			@a_dt_modified datetime,
			@a_nm_table_name nvarchar(255),
			@a_b_can_resubmit_from char(1),
			@a_id_prod_view int OUTPUT
			as
      insert into t_prod_view
      (
			id_view,
			dt_modified,
			nm_name,
			nm_table_name,
			b_can_resubmit_from
      )
      values
      (
			@a_id_view,
			@a_dt_modified,
			@a_nm_name,
			@a_nm_table_name,
			@a_b_can_resubmit_from
      )
			select @a_id_prod_view =@@identity
	