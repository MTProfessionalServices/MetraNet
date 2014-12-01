SELECT count(id_item) count_row FROM t_localized_items 
WHERE id_local_type = %%LOCALIZED_TYPE%%  
		AND id_item = %%ID_PARENT%% %%ADD_WHERE%%;