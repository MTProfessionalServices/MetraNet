
				DECLARE @n_disp int
				SELECT @n_disp = n_display_name FROM t_base_props WHERE id_prop = %%ID_PROP%%
				exec UpsertDescription %%LANG_CODE%%, N'%%DISPL_NAME_STR%%', @n_disp, NULL

				update t_base_props
				set nm_name = N'%%NAME_STR%%', nm_desc = N'%%DESC_STR%%', nm_display_name = N'%%DISPL_NAME_STR%%'
				where id_prop = %%ID_PROP%%
			 