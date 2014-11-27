SELECT id_lang_code
      , tx_name
      , tx_desc
  FROM t_localized_items
  WHERE	id_local_type = 1  /*Adapter type*/ 
		AND id_item = %%ID_EVENT%%

      