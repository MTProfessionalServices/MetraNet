
         create or replace procedure InsertProductViewUniqueKey (
	         p_id_prod_view number,
	         p_constraint_name varchar2,
	         p_nm_table_name varchar2,
	         p_id_unique_cons out varchar2
	         )
         as
         begin
            select seq_t_unique_cons.nextval into p_id_unique_cons from dual;

            insert into t_unique_cons
	            (id_unique_cons, id_prod_view, constraint_name, nm_table_name)
            values
	            (p_id_unique_cons, p_id_prod_view, p_constraint_name, p_nm_table_name);
         end;
	