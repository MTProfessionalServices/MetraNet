
      INSERT INTO tmp_unsubscribe_batch(id_acc, id_po, id_group, vt_start, vt_end, uncorrected_vt_start, uncorrected_vt_end, tt_now, id_gsub_corp_account, status,
										 id_audit, id_event, id_userid, id_entitytype)
      VALUES (%%ID_ACC%%, %%ID_PO%%, %%ID_GROUP%%, %%VT_START%%, %%VT_END%%, %%VT_START%%, %%VT_END%%, %%TT_NOW%%, %%ID_GSUB_CORP%%, 0,
			  %%ID_AUDIT%%, %%ID_EVENT%%, %%ID_USERID%%, %%ID_ENTITYTYPE%%);
                