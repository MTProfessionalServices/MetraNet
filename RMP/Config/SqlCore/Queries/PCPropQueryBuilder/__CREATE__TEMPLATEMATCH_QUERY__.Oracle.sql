
				create or replace procedure %%PROC_NAME%%(temp_id_instance int, temp_id_template int,
				io_cursor in out sys_refcursor)
				is
				begin
				open io_cursor for
             	select
				%%SELECT_LIST%%
				from t_pl_map map
				%%EXTRA_FROM_LIST%%
				where
				map.id_pi_instance = temp_id_instance AND map.id_pi_template = temp_id_template
				%%EXTRA_WHERE_CLAUSES%%;
				end;
			