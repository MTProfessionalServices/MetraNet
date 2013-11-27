
				create proc %%PROC_NAME%% @id_instance as int, @id_template as int
				as
				select
				%%SELECT_LIST%%
				from t_pl_map map
				%%EXTRA_FROM_LIST%%
				where
				map.id_pi_instance = @id_instance AND map.id_pi_template = @id_template
				%%EXTRA_WHERE_CLAUSES%%
			