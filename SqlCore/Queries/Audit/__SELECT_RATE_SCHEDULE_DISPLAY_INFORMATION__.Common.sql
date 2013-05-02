
        select rs.id_pt ParamTableId, 
				bp.nm_display_name ParamTableDisplayName, 
				bp.nm_name ParamTableName, 
				rs.id_pricelist PriceListId,
				bp2.nm_name PriceListName from t_rsched rs
        inner join  t_vw_base_props bp on rs.id_pt = bp.id_prop
        inner join  t_vw_base_props bp2 on rs.id_pricelist = bp2.id_prop
        inner join t_language lang on bp.id_lang_code=lang.id_lang_code and bp2.id_lang_code=lang.id_lang_code
        where id_sched= %%RS_ID%% and %%%UPPER%%%(lang.tx_lang_code)=%%%UPPER%%%('%%TX_LANG_CODE%%')
        