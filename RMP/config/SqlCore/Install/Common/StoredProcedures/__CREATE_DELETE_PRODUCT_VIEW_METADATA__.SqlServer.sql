

			/*
				DeleteProductViewMetadata

				Deletes all metadata for a product view.  Removes all
				unique key and propduct view property metadata.

				@tabname - name of product view

			*/
			create proc DeleteProductViewMetadata(
				@tabname varchar(200)
				)
			as

			declare @err int
			declare @rc int
			declare @id_prod_view int
			declare @nm_name varchar(2000)

			print 'Deleting prod view metadata for ' + @tabname

			-- Get prod view id and table name
			select @id_prod_view = id_prod_view, @nm_name = nm_name
			from t_prod_view
			where nm_table_name = @tabname

			if (@id_prod_view is null) begin
				raiserror('Product view [%s] does not exist.', 0, 1, @tabname)
				return 1
			end

			delete t_product_view_log
			where nm_product_view = @nm_name

			delete t_unique_cons_columns
			where id_unique_cons in
				(select id_unique_cons from t_unique_cons
				where id_prod_view = @id_prod_view)

			delete t_unique_cons
			where id_prod_view = @id_prod_view

			delete t_prod_view_prop
			where id_prod_view = @id_prod_view

			delete t_prod_view
			where id_prod_view = @id_prod_view

		