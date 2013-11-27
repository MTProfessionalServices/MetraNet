
        /* CR 13075 - do not get gsub name from t_acc_template_subs, but from t_group_sub */
        select tsubs.id_po, tsubs.id_group, tsubs.id_acc_template, 
        (CASE WHEN tsubs.id_group IS NULL THEN 'N' ELSE 'Y' END) AS b_group,
        tsubs.vt_start, tsubs.vt_end, gsub.tx_name as nm_groupsubname,
				CASE WHEN (tsubs.id_group IS NULL) THEN 'N' ELSE 'Y' END AS IsGroupSub,
				CASE WHEN (tsubs.id_group IS NULL) THEN tsubs.id_po ELSE sub.id_po END AS ProductOfferingID,
				CASE WHEN (tsubs.id_group IS NULL) THEN 
					COALESCE(po_vbp.nm_display_name, po_bp.nm_display_name) ELSE 
					COALESCE(gs_vbp.nm_display_name, gs_bp.nm_display_name) END AS PODisplayName
				from t_acc_template_subs tsubs
				/* get group sub info */
				left outer join t_group_sub gsub ON tsubs.id_group = gsub.id_group
				left outer join t_sub sub ON sub.id_group = gsub.id_group
				left outer join t_vw_base_props po_vbp on tsubs.id_po = po_vbp.id_prop and po_vbp.id_lang_code = %%ID_LANG%%
				left outer join t_vw_base_props gs_vbp on sub.id_po = gs_vbp.id_prop and gs_vbp.id_lang_code = %%ID_LANG%%
				left outer join t_base_props po_bp on tsubs.id_po = po_bp.id_prop
				left outer join t_base_props gs_bp on sub.id_po = gs_bp.id_prop
				where id_acc_template=%%TEMPLATEID%%
				