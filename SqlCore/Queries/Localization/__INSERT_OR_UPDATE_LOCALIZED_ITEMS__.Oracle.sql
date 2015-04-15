DECLARE 
v_is_exist integer;
/* __INSERT_OR_UPDATE_LOCALIZED_ITEMS__ */
BEGIN
SELECT COUNT(1) INTO v_is_exist FROM t_localized_items WHERE id_local_type = %%LOCALIZED_TYPE%% 
					AND id_item = %%ID_PARENT%% 
					AND id_item_second_key = %%ID_ITEM_SECOND_KEY%% 
					AND id_lang_code=%%ID_LANG%%
					AND rownum = 1; 

IF v_is_exist = 1 THEN
BEGIN
	UPDATE t_localized_items 
	SET tx_name = N'%%LOCALIZE_DISPLAY_NAME%%',
		tx_desc = N'%%LOCALIZE_DESCRIPTION%%'
	WHERE id_local_type = %%LOCALIZED_TYPE%% 
			AND id_item = %%ID_PARENT%% 
			AND id_item_second_key = %%ID_ITEM_SECOND_KEY%%
			AND id_lang_code=%%ID_LANG%%;
END;
ELSE
BEGIN
	INSERT INTO t_localized_items
           (id_local_type
		   ,id_item
		   ,id_item_second_key
           ,id_lang_code
           ,tx_name
           ,tx_desc)
	VALUES
           (%%LOCALIZED_TYPE%% 
		   ,%%ID_PARENT%%
		   ,%%ID_ITEM_SECOND_KEY%%
           ,%%ID_LANG%%
           ,'%%LOCALIZE_DISPLAY_NAME%%'
           ,'%%LOCALIZE_DESCRIPTION%%');
END;
END IF;

END;