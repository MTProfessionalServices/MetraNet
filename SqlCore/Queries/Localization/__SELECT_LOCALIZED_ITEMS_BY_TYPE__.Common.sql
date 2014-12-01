SELECT id_lang_code
      , tx_name
      , tx_desc
  FROM t_localized_items
  WHERE	id_local_type = %%LOCALIZED_TYPE%%
		AND id_item = %%ID_PARENT%% %%ADD_WHERE%%;
		

      