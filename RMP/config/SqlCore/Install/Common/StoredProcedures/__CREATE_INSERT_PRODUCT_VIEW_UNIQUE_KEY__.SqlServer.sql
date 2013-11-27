
			create proc InsertProductViewUniqueKey
				@id_prod_view int,
				@constraint_name varchar(100),
				@nm_table_name varchar(100),
				@id_unique_cons int OUTPUT
			as
			insert into t_unique_cons
				(id_prod_view, constraint_name, nm_table_name)
			values
				(@id_prod_view, @constraint_name, @nm_table_name)

			select @id_unique_cons = @@identity
	