
      /* ES2698  */           
      /*  Create the TMP table view that exposes all the original columns  */
      /*  hides the identifier column */ 
      /*  and enforces that only the proper subset of rows will be accessed. */
      CREATE VIEW tmp_subscribe_batch AS
        SELECT id_acc, id_po, id_group, vt_start, vt_end, uncorrected_vt_start,
          uncorrected_vt_end, tt_now, id_gsub_corp_account, status, id_audit,
          id_event, id_userid, id_entitytype, id_sub, nm_display_name
        FROM ttt_subscribe_batch
        WHERE tx_id = mt_ttt.get_tx_id();

