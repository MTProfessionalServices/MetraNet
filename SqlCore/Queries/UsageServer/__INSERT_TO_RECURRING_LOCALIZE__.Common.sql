INSERT INTO t_localized_items
           (id_local_type
		   ,id_item
           ,id_lang_code
           ,tx_name
           ,tx_desc)
VALUES
           (1  /*Adapter type*/ 
		   ,%%ID_EVENT%%
           ,%%ID_LANG%%
           ,'%%LOCALIZE_DISPLAY_NAME%%'
           ,'%%LOCALIZE_DESCRIPTION%%');

      