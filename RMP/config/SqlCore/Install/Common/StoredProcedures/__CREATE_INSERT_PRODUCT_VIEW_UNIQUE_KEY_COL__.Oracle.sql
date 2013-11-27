
			create or replace procedure InsertProductViewUniqueKeyCol (
				p_id_unique_cons int,
				p_id_prod_view_prop int,
				p_position int
				)
			as
			begin
			   insert into t_unique_cons_columns
				   (id_unique_cons, id_prod_view_prop, position)
			   values
				   (p_id_unique_cons, p_id_prod_view_prop, p_position);
         end;
		