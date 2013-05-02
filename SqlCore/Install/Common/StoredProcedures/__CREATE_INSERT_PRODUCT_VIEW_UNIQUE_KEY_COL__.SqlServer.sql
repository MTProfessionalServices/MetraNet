
			create proc InsertProductViewUniqueKeyCol
				@id_unique_cons int,
				@id_prod_view_prop int,
				@position int
			as
			insert into t_unique_cons_columns
				(id_unique_cons, id_prod_view_prop, position)
			values
				(@id_unique_cons, @id_prod_view_prop, @position)
		