
					declare n_disp int;
                    n_dummy int;
                     begin
					SELECT  n_display_name into n_disp 
					FROM	t_base_props
					WHERE	id_prop = %%ID_PROP%%;

					UpsertDescription (%%LANG_CODE%%, '%%DISPL_NAME_STR%%', n_disp, n_dummy);

					update t_base_props
					set nm_name = '%%NAME_STR%%', nm_desc = '%%DESC_STR%%', 
					nm_display_name = '%%DISPL_NAME_STR%%'
					where id_prop = %%ID_PROP%%;
					end;
			