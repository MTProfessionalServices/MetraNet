
CREATE OR REPLACE PROCEDURE MTSP_GENERATE_CHARGES_QUOTING
(   v_id_interval  INT ,
    v_id_billgroup INT ,
    v_id_run       INT ,
    v_id_accounts VARCHAR2,
	v_id_poid VARCHAR2,
    v_id_batch VARCHAR2 ,
    v_n_batch_size INT ,
    v_run_date DATE ,
	v_is_group_sub INT,
	v_dt_start    DATE,
	v_dt_end      DATE,
    p_count OUT INT)
AS
  v_total_rcs  INT;
  v_total_flat INT;
  v_total_udrc INT;
  v_n_batches  INT;
  v_id_flat    INT;
  v_id_udrc    INT;
  v_id_message INT;
  v_id_ss      INT;
  v_tx_batch   VARCHAR2(256);
  v_id_nonrec  INT;   
  v_total_nrcs INT;      
  
BEGIN
  
   DELETE FROM TMP_RC_ACCOUNTS_FOR_RUN;
   INSERT INTO TMP_RC_ACCOUNTS_FOR_RUN ( ID_ACC )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_accounts) as  tab_id_instance));
		
   DELETE FROM TMP_RC_POS_FOR_RUN;
   INSERT INTO TMP_RC_POS_FOR_RUN ( ID_PO )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_poid) as  tab_id_instance));

   DELETE FROM TMP_RCS;
   DELETE FROM TMP_NRC;
   
   v_tx_batch := v_id_batch;

   -- prepare TMP_RCS
   INSERT INTO TMP_RCS
   (
      idSourceSess,
      c_RCActionType,
      c_RCIntervalStart,
      c_RCIntervalEnd,
      c_BillingIntervalStart,
      c_BillingIntervalEnd,
      c_RCIntervalSubscriptionStart,
      c_RCIntervalSubscriptionEnd, 
      c_SubscriptionStart,
      c_SubscriptionEnd,
      c_Advance,
      c_ProrateOnSubscription,
      c_ProrateInstantly,
      c_ProrateOnUnsubscription,
      c_ProrationCycleLength,
      c__AccountID,
      c__PayingAccount,
      c__PriceableItemInstanceID,
      c__PriceableItemTemplateID,
      c__ProductOfferingID,
      c_BilledRateDate,
      c__SubscriptionID,
      c_payerstart,
      c_payerend,
      c_unitvaluestart,
      c_unitvalueend,
      c_unitvalue,
      c_RatingType
    )
      SELECT
        ID_SOURCE_SESS AS idSourceSess,
        c_RCActionType,
        c_RCIntervalStart,
        c_RCIntervalEnd,
        c_BillingIntervalStart,
        c_BillingIntervalEnd,
        c_RCIntervalSubscriptionStart,
        c_RCIntervalSubscriptionEnd,
        c_SubscriptionStart,
        c_SubscriptionEnd,
        c_Advance,
        c_ProrateOnSubscription,
        c_ProrateInstantly,
        c_ProrateOnUnsubscription,
        c_ProrationCycleLength,
        c_AccountID,
        c_PayingAccount,
        c_PriceableItemInstanceID,
        c_PriceableItemTemplateID,
        c_ProductOfferingID,
        c_BilledRateDate,
        c_SubscriptionID,
        c_payerstart,
        c_payerend,
        c_unitvaluestart,
        c_unitvalueend,
        c_unitvalue,
        c_ratingtype
        FROM
        ( SELECT SYS_GUID() AS ID_SOURCE_SESS,
          'Arrears' AS c_RCActionType,
          pci.dt_start AS c_RCIntervalStart,
          pci.dt_end AS c_RCIntervalEnd,
          ui.dt_start AS c_BillingIntervalStart,
          ui.dt_end AS c_BillingIntervalEnd,
          dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart) AS c_RCIntervalSubscriptionStart,
          dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd) AS c_RCIntervalSubscriptionEnd,
          rw.c_SubscriptionStart AS c_SubscriptionStart,
          rw.c_SubscriptionEnd AS c_SubscriptionEnd,
          case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance,
		  case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription,
		  case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly ,
		  case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription,
		  CASE
			WHEN rcr.b_fixed_proration_length = 'Y'
			THEN fxd.n_proration_length
			ELSE 0
		  END                           AS c_ProrationCycleLength ,
		  rw.c__accountid AS c_AccountID,
          rw.C__PAYINGACCOUNT AS c_PayingAccount,
          rw.c__priceableiteminstanceid AS c_PriceableItemInstanceID,
          rw.c__priceableitemtemplateid AS c_PriceableItemTemplateID,
          rw.c__productofferingid AS c_ProductOfferingID,
          pci.dt_end AS c_BilledRateDate,
          rw.c__subscriptionid AS c_SubscriptionID,
          rw.c_payerstart,
          rw.c_payerend,
          CASE
            WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            ELSE rw.c_unitvaluestart
          END AS c_unitvaluestart,
          rw.c_unitvalueend,
          rw.c_unitvalue,
          rcr.n_rating_type AS c_RatingType
        /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
         INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
   /* interval overlaps with UDRC */
   /* rc overlaps with this subscription */
        FROM t_usage_interval ui
          LEFT JOIN TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1 = 1
          JOIN t_recur_window rw ON bgm.id_acc = rw.C__PAYINGACCOUNT
			AND rw.c_payerstart < ui.dt_end  AND rw.c_payerend > ui.dt_start
          /* interval overlaps with payer */
		    AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start
          /* interval overlaps with cycle */
            AND rw.c_membershipstart < ui.dt_end AND rw.c_membershipend > ui.dt_start
          /* interval overlaps with membership */
		    AND rw.c_subscriptionstart < ui.dt_end AND rw.c_subscriptionend > ui.dt_start
          /* interval overlaps with subscription */
			AND rw.c_unitvaluestart < ui.dt_end AND rw.c_unitvalueend > ui.dt_start
		  JOIN TMP_RC_POS_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
          JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
          JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
            CASE
                WHEN rcr.tx_cycle_mode = 'Fixed'
                    THEN rcr.id_usage_cycle
                WHEN rcr.tx_cycle_mode LIKE 'BCR%'
                    THEN ui.id_usage_cycle
                WHEN rcr.tx_cycle_mode = 'EBCR'
                    THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                ELSE NULL
            END
                      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
          JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
			  AND pci.dt_end BETWEEN ui.dt_start AND ui.dt_end
			  /* rc end falls in this interval */
			  AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend
			  /* rc end goes to this payer */
			  AND rw.c_unitvaluestart < pci.dt_end AND rw.c_unitvalueend > pci.dt_start
			  /* rc overlaps with this UDRC */
			  AND rw.c_membershipstart < pci.dt_end AND rw.c_membershipend > pci.dt_start
			  /* rc overlaps with this membership */
			  AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start
			  /* rc overlaps with this cycle */
			  AND rw.c_SubscriptionStart < pci.dt_end AND rw.c_subscriptionend > pci.dt_start
          JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
          WHERE 1 = 1
          AND ui.id_interval = v_id_interval
          AND rcr.b_advance <> 'Y'
        UNION ALL
               
        SELECT
          SYS_GUID() AS ID_SOURCE_SESS,
          'Advance' AS c_RCActionType,
          pci.dt_start AS c_RCIntervalStart,
          pci.dt_end AS c_RCIntervalEnd,
          ui.dt_start AS c_BillingIntervalStart,
          ui.dt_end AS c_BillingIntervalEnd,
          CASE
              WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
              THEN dbo.MTMaxOfTwoDates(AddSecond(c_cycleEffectiveDate), pci.dt_start)
              ELSE pci.dt_start
          END AS c_RCIntervalSubscriptionStart,
          dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd) AS c_RCIntervalSubscriptionEnd,
          rw.c_SubscriptionStart AS c_SubscriptionStart,
          rw.c_SubscriptionEnd AS c_SubscriptionEnd,
          case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance,
		  case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription,
		  case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly ,
		  case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription,
		  CASE
			WHEN rcr.b_fixed_proration_length = 'Y'
			THEN fxd.n_proration_length
			ELSE 0
		  END                           AS c_ProrationCycleLength ,
          rw.c__accountid AS c_AccountID,
		  rw.c__payingaccount AS c_PayingAccount,
          rw.c__priceableiteminstanceid AS c_PriceableItemInstanceID,
          rw.c__priceableitemtemplateid AS c_PriceableItemTemplateID,
          rw.c__productofferingid AS c_ProductOfferingID,
          pci.dt_start AS c_BilledRateDate,
          rw.c__subscriptionid AS c_SubscriptionID,
          rw.c_payerstart,
          rw.c_payerend,
          CASE
            WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            ELSE rw.c_unitvaluestart
          END AS c_unitvaluestart,
          rw.c_unitvalueend,
          rw.c_unitvalue,
          rcr.n_rating_type AS c_RatingType
   /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
         INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
   /* next interval overlaps with UDRC */
   /* rc overlaps with this subscription */
          FROM t_usage_interval ui JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
              LEFT JOIN TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1 = 1
              JOIN t_recur_window rw ON bgm.id_acc = rw.c__payingaccount
              AND rw.c_payerstart < nui.dt_end AND rw.c_payerend > nui.dt_start
              /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start
              /* next interval overlaps with cycle */
              AND rw.c_membershipstart < nui.dt_end AND rw.c_membershipend > nui.dt_start
              /* next interval overlaps with membership */
              AND rw.c_subscriptionstart < nui.dt_end AND rw.c_subscriptionend > nui.dt_start
              /* next interval overlaps with subscription */
              AND rw.c_unitvaluestart < nui.dt_end AND rw.c_unitvalueend > nui.dt_start
              JOIN TMP_RC_POS_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
			  JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
              JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE
                                            WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
											END
              JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND pci.dt_start BETWEEN nui.dt_start AND nui.dt_end
              /* rc start falls in this interval */
              AND pci.dt_start BETWEEN rw.c_payerstart AND rw.c_payerend
              /* rc start goes to this payer */
              AND rw.c_unitvaluestart < pci.dt_end AND rw.c_unitvalueend > pci.dt_start
              /* rc overlaps with this UDRC */
              AND rw.c_membershipstart < pci.dt_end AND rw.c_membershipend > pci.dt_start
              /* rc overlaps with this membership */
              AND rw.c_cycleeffectiveend > pci.dt_start
              /* rc overlaps with this cycle */
              AND rw.c_subscriptionend > pci.dt_start
              JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
          WHERE 1 = 1
              AND ui.id_interval = v_id_interval
              AND rcr.b_advance = 'Y'
        )  A;

   SELECT COUNT(1) INTO v_total_rcs FROM TMP_RCS ;
   
   -- prepare TMP_NRCS
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
                  JOIN TMP_RC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = mem.id_acc
                  JOIN TMP_RC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
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
                  JOIN TMP_RC_ACCOUNTS_FOR_RUN acc ON acc.id_acc = sub.id_acc
                  JOIN TMP_RC_POS_FOR_RUN po ON po.id_po = sub.id_po
                  JOIN t_po ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm ON sub.id_po = plm.id_po AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp ON bp.id_prop = plm.id_pi_instance AND bp.n_kind = 30
                  JOIN t_nonrecur nrc ON nrc.id_prop = bp.id_prop AND nrc.n_event_type = 1
        ;
  END;
  END IF;

   SELECT COUNT(1) INTO v_total_nrcs FROM TMP_NRC ;
  
   IF v_total_rcs > 0 THEN
   BEGIN
      SELECT COUNT(1) INTO v_total_flat FROM TMP_RCS WHERE c_unitvalue IS NULL;

      SELECT COUNT(1) INTO v_total_udrc FROM TMP_RCS WHERE c_unitvalue IS NOT NULL;
      
      IF v_total_flat > 0 THEN
      BEGIN
         SELECT id_enum_data
           INTO v_id_flat
           FROM t_enum_data ted
            WHERE ted.nm_enum_data = 'metratech.com/flatrecurringcharge';

         v_n_batches := (v_total_flat / v_n_batch_size) + 1;

         GetIdBlock(v_n_batches,'id_dbqueuesch',v_id_message);
         GetIdBlock(v_n_batches,'id_dbqueuess',v_id_ss);

         INSERT INTO t_session
           ( id_ss, id_source_sess )
           SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                  idSourceSess
             FROM TMP_RCS
              WHERE c_unitvalue IS NULL;

         INSERT INTO t_session_set
           ( id_message, id_ss, id_svc, b_root, session_count )
           SELECT id_message,
                  id_ss,
                  id_svc,
                  b_root,
                  COUNT(1) session_count
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message,
                           v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                           v_id_flat id_svc,
                           1 b_root
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NULL ) a
             GROUP BY id_message,id_ss,id_svc,b_root;

         INSERT INTO t_svc_FlatRecurringCharge
            (
              id_source_sess ,
              id_parent_source_sess ,
              id_external ,
              c_RCActionType ,
              c_RCIntervalStart ,
              c_RCIntervalEnd ,
              c_BillingIntervalStart ,
              c_BillingIntervalEnd ,
              c_RCIntervalSubscriptionStart ,
              c_RCIntervalSubscriptionEnd ,
              c_SubscriptionStart ,
              c_SubscriptionEnd ,
              c_Advance ,
              c_ProrateOnSubscription ,
              c_ProrateInstantly ,
              c_ProrateOnUnsubscription ,
              c_ProrationCycleLength ,
              c__AccountID ,
              c__PayingAccount ,
              c__PriceableItemInstanceID ,
              c__PriceableItemTemplateID ,
              c__ProductOfferingID ,
              c_BilledRateDate ,
              c__SubscriptionID ,
              c__IntervalID ,
              c__Resubmit ,
              c__TransactionCookie ,
              c__CollectionID
            )
            SELECT  idSourceSess,
                    NULL AS id_parent_source_sess,
                    NULL AS id_external,
                    c_RCActionType,
                    c_RCIntervalStart,
                    c_RCIntervalEnd,
                    c_BillingIntervalStart,
                    c_BillingIntervalEnd,
                    c_RCIntervalSubscriptionStart,
                    c_RCIntervalSubscriptionEnd,
                    c_SubscriptionStart,
                    c_SubscriptionEnd,
                    c_Advance,
                    c_ProrateOnSubscription,
                    c_ProrateInstantly,
                    c_ProrateOnUnsubscription,
                    c_ProrationCycleLength,
                    c__AccountID,
                    c__PayingAccount,
                    c__PriceableItemInstanceID,
                    c__PriceableItemTemplateID,
                    c__ProductOfferingID,
                    c_BilledRateDate,
                    c__SubscriptionID,
                    v_id_interval AS c__IntervalID,
                    '0' AS c__Resubmit,
                    NULL AS c__TransactionCookie,
                    v_tx_batch AS c__CollectionID
             FROM TMP_RCS
                WHERE c_unitvalue IS NULL ;

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
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NULL ) a
             GROUP BY a.id_message;

      END;
      END IF;

      /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');*/
      IF v_total_udrc > 0 THEN
      BEGIN
         SELECT id_enum_data
           INTO v_id_udrc
           FROM t_enum_data ted
            WHERE ted.nm_enum_data = 'metratech.com/udrecurringcharge';

         v_n_batches := (v_total_udrc / v_n_batch_size) + 1;

         GetIdBlock(v_n_batches, 'id_dbqueuesch', v_id_message);
         GetIdBlock(v_n_batches, 'id_dbqueuess', v_id_ss);

         INSERT INTO t_session
           ( id_ss, id_source_sess )
           SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                  idSourceSess id_source_sess
             FROM TMP_RCS
              WHERE c_unitvalue IS NOT NULL;

         INSERT INTO t_session_set
           ( id_message, id_ss, id_svc, b_root, session_count )
           SELECT id_message,
                  id_ss,
                  id_svc,
                  b_root,
                  COUNT(1) session_count
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message,
                           v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                           v_id_udrc id_svc,
                           1 b_root
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NOT NULL ) a
             GROUP BY id_message,id_ss,id_svc,b_root;

         INSERT INTO t_svc_UDRecurringCharge
           (
          id_source_sess,
          id_parent_source_sess,
          id_external,
          c_RCActionType,
          c_RCIntervalStart,
          c_RCIntervalEnd,
          c_BillingIntervalStart,
          c_BillingIntervalEnd ,
          c_RCIntervalSubscriptionStart ,
          c_RCIntervalSubscriptionEnd ,
          c_SubscriptionStart ,
          c_SubscriptionEnd ,
          c_Advance ,
          c_ProrateOnSubscription ,
          /*    c_ProrateInstantly , */
          c_ProrateOnUnsubscription ,
          c_ProrationCycleLength ,
          c__AccountID ,
          c__PayingAccount ,
          c__PriceableItemInstanceID ,
          c__PriceableItemTemplateID ,
          c__ProductOfferingID ,
          c_BilledRateDate ,
          c__SubscriptionID ,
          c__IntervalID ,
          c__Resubmit ,
          c__TransactionCookie ,
          c__CollectionID ,
          c_unitvaluestart ,
          c_unitvalueend ,
          c_unitvalue ,
          c_ratingtype
        )
         SELECT
            idSourceSess,
            NULL AS id_parent_source_sess,
            NULL AS id_external,
            c_RCActionType,
            c_RCIntervalStart,
            c_RCIntervalEnd,
            c_BillingIntervalStart,
            c_BillingIntervalEnd,
            c_RCIntervalSubscriptionStart,
            c_RCIntervalSubscriptionEnd,
            c_SubscriptionStart,
            c_SubscriptionEnd,
            c_Advance,
            c_ProrateOnSubscription,
            /*    ,c_ProrateInstantly */
            c_ProrateOnUnsubscription,
            c_ProrationCycleLength,
            c__AccountID,
            c__PayingAccount,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c_BilledRateDate,
            c__SubscriptionID,
            v_id_interval AS c__IntervalID,
            '0' AS c__Resubmit,
            NULL AS c__TransactionCookie,
            v_tx_batch c__CollectionID,
            c_unitvaluestart,
            c_unitvalueend,
            c_unitvalue,
            c_ratingtype
        FROM TMP_RCS
        WHERE c_unitvalue IS NOT NULL ;

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
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NOT NULL ) a
             GROUP BY id_message;

      END;
      END IF;

   END;
   END IF;
   
   IF v_total_nrcs > 0 THEN
   BEGIN
   SELECT id_enum_data
     INTO v_id_nonrec
     FROM t_enum_data ted
      WHERE ted.nm_enum_data = 'metratech.com/nonrecurringcharge';

   v_n_batches := (v_total_nrcs / v_n_batch_size) + 1;

   GetIdBlock(v_n_batches, 'id_dbqueuesch', v_id_message);

   GetIdBlock(v_n_batches, 'id_dbqueuess', v_id_ss);

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
	   
    DELETE FROM TMP_NRC;
   END;
   END IF;

   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');*/
   p_count := v_total_rcs + v_total_nrcs;
   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));*/
END;