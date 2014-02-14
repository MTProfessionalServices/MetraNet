
CREATE OR REPLACE PROCEDURE MTSP_GENERATE_ST_NRCS_QUOTING
(
  v_dt_start    DATE,
  v_dt_end      DATE,
  v_id_accounts VARCHAR2,
  v_id_poid VARCHAR2,
  v_id_interval INT,
  v_id_batch    VARCHAR2,
  v_n_batch_size INT,
  v_run_date    DATE,
  v_is_group_sub INT,
  p_count OUT INT
)
AS
   v_id_nonrec  INT;
   v_n_batches  INT;
   v_total_nrcs INT;
   v_id_message INT;
   v_id_ss      INT;
   v_tx_batch   VARCHAR2(256);
BEGIN

   DELETE FROM TMP_NRC_ACCOUNTS_FOR_RUN;
   INSERT INTO TMP_NRC_ACCOUNTS_FOR_RUN ( ID_ACC )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_accounts) as  tab_id_instance));
        
   DELETE FROM TMP_NRC_POS_FOR_RUN;
   INSERT INTO TMP_NRC_POS_FOR_RUN ( ID_PO )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_poid) as  tab_id_instance));

   DELETE FROM TMP_NRC;

   v_tx_batch := v_id_batch;

   IF v_is_group_sub > 0 THEN
   BEGIN
   INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit            
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              mem.vt_start AS c_NRCIntervalSubscriptionStart,
              mem.vt_end AS c_NRCIntervalSubscriptionEnd,
              mem.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit               
            FROM t_sub sub
                  JOIN t_gsubmember mem ON mem.id_group = sub.id_group
                  JOIN TMP_NRC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = mem.id_acc
                  JOIN TMP_NRC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
            WHERE sub.vt_start >= v_dt_start
                  AND sub.vt_start < v_dt_end
        ;

   END;
   ELSE
   BEGIN

       INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit            
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              sub.vt_start AS c_NRCIntervalSubscriptionStart,
              sub.vt_end AS c_NRCIntervalSubscriptionEnd,
              sub.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit
            FROM t_sub sub 
                  JOIN TMP_NRC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = sub.id_acc
                  JOIN TMP_NRC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
            WHERE sub.vt_start >= v_dt_start
                  AND sub.vt_start < v_dt_end
        ;
  END;
  END IF;

   SELECT COUNT(*)
     INTO v_total_nrcs
     FROM TMP_NRC ;

   SELECT id_enum_data
     INTO v_id_nonrec
     FROM t_enum_data ted
      WHERE ted.nm_enum_data = 'metratech.com/nonrecurringcharge';

   v_n_batches := (v_total_nrcs / v_n_batch_size) + 1;

   GetIdBlock(v_n_batches, 'id_dbqueuesch', v_id_message);

   GetIdBlock(v_n_batches, 'id_dbqueuess', v_id_ss);

   INSERT INTO t_message
     ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
     SELECT id_message,
            NULL,
            v_run_date,
            v_run_date,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            '127.0.0.1'
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message
              FROM tmp_nrc  ) a
       GROUP BY id_message;

   INSERT INTO t_session
     ( id_ss, id_source_sess )
     SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
            id_source_sess
       FROM tmp_nrc ;

   INSERT INTO t_session_set
     ( id_message, id_ss, id_svc, b_root, session_count )
     SELECT id_message,
            id_ss,
            v_id_nonrec,
            b_root,
            COUNT(1) session_count
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message,
                     v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
                     1 b_root
              FROM tmp_nrc  ) a
       GROUP BY id_message,id_ss,b_root;

   INSERT INTO t_svc_nonrecurringcharge
     (  id_source_sess,
        id_parent_source_sess,
        id_external,
        c_NRCEventType,
        c_NRCIntervalStart,
        c_NRCIntervalEnd,
        c_NRCIntervalSubscriptionStart,
        c_NRCIntervalSubscriptionEnd,
        c__AccountID,
        c__PriceableItemInstanceID,
        c__PriceableItemTemplateID,
        c__ProductOfferingID,
        c__SubscriptionID,
        c__IntervalID,
        c__Resubmit,
        c__TransactionCookie,
        c__CollectionID )
     ( SELECT
          id_source_sess,
          NULL id_parent_source_sess,
          NULL id_external,
          c_NRCEventType,
          c_NRCIntervalStart,
          c_NRCIntervalEnd,
          c_NRCIntervalSubscriptionStart,
          c_NRCIntervalSubscriptionEnd,
          c__AccountID,
          c__PriceableItemInstanceID,
          c__PriceableItemTemplateID,
          c__ProductOfferingID,
          c__SubscriptionID,
          c__IntervalID,
          c__Resubmit,
          NULL as c__TransactionCookie,
          v_tx_batch as c__CollectionID
       FROM tmp_nrc  );

    DELETE FROM TMP_NRC;

   p_count := v_total_nrcs;

END;