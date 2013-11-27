

			/*
				DeleteProductViewMetadata

				Deletes all metadata for a product view.  Removes all
				unique key and propduct view property metadata.

				tabname - name of product view

			*/
create or replace procedure deleteproductviewmetadata(p_tabname varchar2) as
			p_err int;
			p_rc int;
			p_id_prod_view int;
			p_nm_name varchar2(2000);
			v_sql varchar2(4000);
begin

			begin
			/* Get prod view id and table name */
    select  id_prod_view, nm_name
      into p_id_prod_view, p_nm_name
			from t_prod_view
    where lower(nm_table_name) = lower(p_tabname);

    exception
      /* quit if pv not found */
      when no_data_found then return;
  end;


			delete from t_product_view_log
			where nm_product_view = p_nm_name;

			delete from t_unique_cons_columns
			where id_unique_cons in
    (select id_unique_cons
     from t_unique_cons
				where id_prod_view = p_id_prod_view);

			delete from t_unique_cons
			where id_prod_view = p_id_prod_view;

			delete from t_prod_view_prop
			where id_prod_view = p_id_prod_view;

			delete from t_prod_view
			where id_prod_view = p_id_prod_view;

end deleteproductviewmetadata;
		