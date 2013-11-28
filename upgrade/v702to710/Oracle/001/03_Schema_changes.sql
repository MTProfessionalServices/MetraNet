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
/

CREATE OR REPLACE PROCEDURE REMOVEGSUBS_QUOTING (
   p_id_sub             INT,
   p_systemdate         DATE,
   p_status       OUT   INT
)
AS
   v_groupid    INT;
   v_maxdate    DATE;
   v_nmembers   INT;
   v_icbid      INT;
BEGIN
   p_status := 0;

   FOR i IN (SELECT id_group, dbo.mtmaxdate () mtmaxdate
               FROM t_sub
              WHERE id_sub = p_id_sub)
   LOOP
      v_groupid := i.id_group;
      v_maxdate := i.mtmaxdate;
   END LOOP;

   FOR i IN (SELECT DISTINCT id_pricelist
                        FROM t_pl_map
                       WHERE id_sub = p_id_sub)
   LOOP
      v_icbid := i.id_pricelist;
   END LOOP;

   DELETE FROM t_recur_window rw
         WHERE rw.C__SUBSCRIPTIONID = p_id_sub;

   DELETE FROM t_gsub_recur_map
         WHERE id_group = v_groupid;

   DELETE FROM t_recur_value
         WHERE id_sub = p_id_sub;

   /* id_po is overloaded.  If b_group == Y then id_po is */
   /* the group id otherwise id_po is the product offering id. */
   DELETE FROM t_acc_template_subs
         WHERE id_group = v_groupid AND id_po IS NULL;

   /* Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables */
   DELETE FROM t_pl_map
         WHERE id_sub = p_id_sub;

   UPDATE t_recur_value
      SET tt_end = p_systemdate
    WHERE id_sub = p_id_sub AND tt_end = v_maxdate;

   UPDATE t_sub_history
      SET tt_end = p_systemdate
    WHERE tt_end = v_maxdate AND id_sub = p_id_sub;

   DELETE FROM t_sub
         WHERE id_sub = p_id_sub;
         
   DELETE FROM t_char_values
         WHERE id_entity = p_id_sub;

   IF (v_icbid IS NOT NULL)
   THEN
      sp_deletepricelist (v_icbid, p_status);

      IF p_status <> 0
      THEN
         RETURN;
      END IF;
   END IF;

   UPDATE t_group_sub
      SET tx_name =
             CAST ('[DELETED ' || CAST (SYSDATE AS NVARCHAR2 (22)) || ']'
                   || tx_name AS NVARCHAR2 (255)
                  )
    WHERE id_group = v_groupid;
END;
/

ALTER PROCEDURE insertchargesintosvctables COMPILE 
/

CREATE OR REPLACE PROCEDURE METERCreditFROMRECURWINDOW (currentDate date) AS

    enabled varchar2(10);
     
  BEGIN
   SELECT value into enabled FROM t_db_values WHERE parameter = N'InstantRc';
     IF (enabled like 'false')then return;  end if;
     
   INSERT INTO tmp_rc
SELECT DISTINCT
/* First, credit or debit the difference in the ending of the subscription.  If the new one is later, this will be a debit, otherwise a credit.
* There's a weird exception when this is (a) an arrears charge, (b) the old subscription end was after the pci end date, 
* and (c) the new sub end is inside the pci end date.*/
    CASE WHEN new_sub.vt_end > current_sub.vt_end THEN 'Debit' ELSE 'Credit' END AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)) AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, dbo.MTMaxOfTwoDates(new_sub.vt_end, current_sub.vt_end)) AS c_RCIntervalSubscriptionEnd
    ,dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)   AS c_SubscriptionStart
    ,dbo.MTMaxOfTwoDates(new_sub.vt_end, current_sub.vt_end) AS c_SubscriptionEnd
    /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
    ,null as id_source_sess
    FROM tmp_newrw  rw
   INNER JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci
      ON pci.id_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
      AND dbo.MTMinOfTwoDates(pci.dt_end, current_sub.vt_end)!= dbo.MTMinOfTwoDates(pci.dt_end, new_sub.vt_end)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end)
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
      AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
	  and pci.dt_start < currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      INNER JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
           ELSE NULL END
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
   where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  We'll deal with this 
    * elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	AND rw.c__IsAllowGenChargeByTrigger = 1
 UNION
 SELECT DISTINCT
/* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
    CASE WHEN new_sub.vt_start < current_sub.vt_start THEN 'InitialDebit' ELSE 'InitialCredit' END AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, dbo.MTMinOfTwoDates(new_sub.vt_start, current_sub.vt_start)) AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start)) AS c_RCIntervalSubscriptionEnd
    ,dbo.MTMinOfTwoDates(new_sub.vt_start, current_sub.vt_start)   AS c_SubscriptionStart
    ,dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start) AS c_SubscriptionEnd
    /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
    ,null as id_source_sess
    FROM tmp_newrw  rw
    INNER JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci
      ON pci.id_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
      /*Check where the intersection of the pci interval and the subscription is different between the new & the old subs.*/
      AND dbo.MTMaxOfTwoDates(pci.dt_start, current_sub.vt_start) != dbo.MTMaxOfTwoDates(pci.dt_start, new_sub.vt_start)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end)
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
      AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
	  and pci.dt_start < currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
          INNER JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
            and paymentInterval.id_usage_cycle = pci.id_cycle
    INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
           ELSE NULL END
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
  where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  
    * We'll deal with this elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	AND rw.c__IsAllowGenChargeByTrigger = 1
    
 UNION
  SELECT DISTINCT
/* Now, handle the exceptional case above, where (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.
* In this case, issue a debit from the pci start to the subscription end immediately. */
    'Debit' AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, new_sub.vt_start) AS c_RCIntervalSubscriptionStart
    ,new_sub.vt_end AS c_RCIntervalSubscriptionEnd
    ,new_sub.vt_start  AS c_SubscriptionStart
    ,new_sub.vt_end AS c_SubscriptionEnd
    /*Booleans are stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,new_sub.vt_start AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
    ,null as id_source_sess
    FROM tmp_newrw  rw
   INNER JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci
      ON pci.id_cycle =
      CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
      AND dbo.MTMinOfTwoDates(pci.dt_end, current_sub.vt_end)!= dbo.MTMinOfTwoDates(pci.dt_end, new_sub.vt_end)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end)
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
      AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      INNER JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
           ELSE NULL END
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
 where 1=1
    and (rcr.b_prorate_on_deactivate='Y' or pci.dt_start > dbo.mtendofday(rw.c_SubscriptionEnd))
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  We'll deal with this 
    * elsewhere.
    */
    AND (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	AND rw.c__IsAllowGenChargeByTrigger = 1;
	
    update tmp_rc set id_source_sess = sys_guid();
	
    insertChargesIntoSvcTables('%Credit','%Debit');
	
	UPDATE tmp_newrw rw
	SET c_BilledThroughDate = currentDate
	where rw.c__IsAllowGenChargeByTrigger = 1;

	
/*We can get an no data exception if there are no previous subscriptions; just return in this case.*/
   EXCEPTION WHEN NO_DATA_FOUND THEN return;
end METERCreditFROMRECURWINDOW;
/

CREATE OR REPLACE PROCEDURE METERinitialFROMRECURWINDOW (currentDate date) AS

  enabled varchar2(10);
  BEGIN
   SELECT value into enabled FROM t_db_values WHERE parameter = N'InstantRc';
   IF (enabled = 'false')then return;
   end if;
    
   INSERT INTO tmp_rc
 SELECT
    'Initial' AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,ui.dt_start      AS c_BillingIntervalStart
    ,ui.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
    ,rw.c_SubscriptionStart          AS c_SubscriptionStart
    ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
    /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
     ,dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
      ,SYS_GUID () as id_source_sess
     FROM t_usage_interval ui
      INNER JOIN tmp_newrw rw on
        rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
    AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
    AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
    AND rw.c_SubscriptionStart < ui.dt_end AND rw.c_SubscriptionEnd > ui.dt_start
    AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID AND auc.id_usage_cycle = ui.id_usage_cycle
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci
      ON pci.id_cycle = CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
    AND ((rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
                or pci.dt_end BETWEEN ui.dt_start     AND ui.dt_end                           /* or check if the cycle end falls into this interval */
		or (pci.dt_start < ui.dt_start and pci.dt_end > ui.dt_end))                   /* or this interval could be in the middle of the cycle */
    AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
    AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
    AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
    AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
    AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
    INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
where 1=1
/*Only meter new subscriptions as initial -- so select only items that have at most one entry in t_sub_history*/
    AND NOT EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.c__SubscriptionID AND tsh.id_acc = rw.c__AccountID
      AND tsh.tt_end < currentDate)
/*Also no old unit values*/
    AND NOT EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
/* Don't meter in the current interval for initial*/
    AND ui.dt_start < currentDate
	AND rw.c__IsAllowGenChargeByTrigger = 1;

   insertChargesIntoSvcTables('Initial','Initial');

	UPDATE tmp_newrw rw
	SET c_BilledThroughDate = currentDate
	where rw.c__IsAllowGenChargeByTrigger = 1;

end METERinitialFROMRECURWINDOW;
/

CREATE OR REPLACE PROCEDURE MeterPayerChangeFromRecWind (currentDate date) AS

  enabled varchar2(10);
  BEGIN
   SELECT value into enabled FROM t_db_values WHERE parameter = N'InstantRc';
   IF (enabled = 'false')then return;  end if;
    
   INSERT INTO TMP_PAYER_CHANGES
   SELECT DISTINCT
        pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND ui.dt_start <> rw.c_cycleEffectiveDate
        THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(rw.c_cycleEffectiveDate), pci.dt_start)
        ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,rw.c_UnitValueStart AS c_UnitValueStart
      ,rw.c_UnitValueEnd AS c_UnitValueEnd
      ,rw.c_UnitValue AS c_UnitValue
      ,rcr.n_rating_type AS c_RatingType
      ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccountCredit
      ,rwnew.c__payingaccount AS c__PayingAccountDebit
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)  AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
      ,currentui.id_interval AS c__IntervalID
     FROM tmp_oldrw rw  INNER JOIN t_usage_interval ui
         on rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
           AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* next interval overlaps with subscription */
           AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend > ui.dt_start /* next interval overlaps with membership */
    /*Between the new and old values, one contains the other, depending on if we've added a payer in the middle or taken one out.
    * Whichever is smaller is the one we actually have to debit/credit, because it's the part that has changed.
    */
    INNER JOIN tmp_newrw rwnew ON rwnew.c__AccountID = rw.c__AccountID AND rwnew.c__PayingAccount != rw.c__PayingAccount
        and dbo.MTMaxOfTwoDates(rwnew.c_payerstart, rw.c_PayerStart) < ui.dt_end AND dbo.MTMinOfTwoDates(rw.c_PayerEnd,rwnew.c_payerend) > ui.dt_start
        /*we only want the cases where the new payer contains the old payer or vice versa.*/
        AND ((rw.c_PayerStart >= rwnew.c_PayerStart AND rw.c_PayerEnd <= rwnew.c_PayerEnd)
            OR (rw.c_PayerStart <= rwnew.c_PayerStart AND rw.c_PayerEnd >= rwnew.c_PayerEnd))
      INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE
	    WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
		WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
		WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
		ELSE NULL END
      JOIN t_acc_usage_cycle auc on auc.id_acc = rw.c__AccountID and auc.id_usage_cycle = ccl.id_usage_cycle
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start < dbo.MTMinOfTwoDates(rw.c_PayerEnd, rwnew.c_payerend)
                                   AND pci.dt_end > dbo.MTMaxOfTwoDates(rwnew.c_payerstart, rw.c_PayerStart)             /* rc start goes to this payer */
                                   /*Also, RC end needs to be for this payer -- otherwise the other payer gets it.*/
                                   AND pci.dt_end <= dbo.MTMinOfTwoDates(rw.c_PayerEnd, rwnew.c_payerend)
                                   AND rwnew.c_membershipstart     < pci.dt_end AND rwnew.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
								   and pci.dt_start < currentDate /* Don't go into the future*/
      INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
   where 1=1;
	  
	  insert INTO tmp_rc
 		SELECT 'InitialCredit' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c__AccountID
           ,c__PayingAccountDebit AS c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__IntervalID
           ,sys_guid() AS idSourceSess FROM TMP_PAYER_CHANGES
           
           UNION ALL
           		SELECT 'InitialDebit' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c__AccountID
           ,c__PayingAccountCredit AS c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__IntervalID
           ,sys_guid() AS idSourceSess FROM TMP_PAYER_CHANGES ;
          
    InsertChargesIntoSvcTables('InitialCredit','InitialDebit');
	
	UPDATE tmp_newrw rw
	SET c_BilledThroughDate = currentDate
	where rw.c__IsAllowGenChargeByTrigger = 1;

end MeterPayerChangeFromRecWind;
/

CREATE OR REPLACE PROCEDURE MeterUdrcFromRecurWindow (currentDate date) AS
  enabled       VARCHAR2(10);
BEGIN
  SELECT value INTO enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled = 'false')THEN
    RETURN;
  END IF;
  
  INSERT INTO tmp_udrc
	SELECT      DISTINCT
      pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND ui.dt_start <> rw_new.c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(rw_new.c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw_new.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw_new.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw_new.c_SubscriptionEnd          AS c_SubscriptionEnd
      /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
      ,case when rw_new.c_advance  ='Y' then '1' else '0'end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0'end         AS c_ProrateOnSubscription
	  ,dbo.MTMaxOfTwoDates(rw_new.c_UnitValueStart, trv.vt_start) AS c_UnitValueStart
      ,dbo.MTMinOfTwoDates(rw_new.c_UnitValueEnd, trv.vt_end) AS c_UnitValueEnd
      ,tou.n_value AS c_UnitValueAdvanceCorrection
      ,rw_new.c_UnitValue AS c_UnitValueDebitCorrection
      ,rcr.n_rating_type AS c_RatingType
      ,case when rcr.b_prorate_on_deactivate = 'Y' then '1' else '0'end AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw_new.c__accountid AS c__AccountID
      ,rw_new.c__payingaccount      AS c__PayingAccount
      ,rw_new.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw_new.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw_new.c__productofferingid      AS c__ProductOfferingID
      ,dbo.MTMinOfTwoDates(pci.dt_end,rw_new.c_SubscriptionEnd)  AS c_BilledRateDate
      ,rw_new.c__subscriptionid      AS c__SubscriptionID
      ,currentui.id_interval AS c__IntervalID
  FROM tmp_newrw rw_new
	INNER JOIN t_recur_window trw ON rw_new.c__AccountID = trw.c__AccountID AND rw_new.c__SubscriptionID = trw.c__SubscriptionID
    INNER JOIN t_recur_value trv on trv.id_sub = rw_new.C__SubscriptionID AND trv.tt_end = dbo.MTMaxDate()
	  and trv.vt_start < rw_new.c_UnitValueEnd AND trv.vt_end > rw_new.c_UnitValueStart
    INNER JOIN t_usage_interval ui ON
	    rw_new.c_UnitValueStart < ui.dt_end and rw_new.c_UnitValueEnd > ui.dt_start
    INNER JOIN t_recur rcr ON rw_new.c__priceableiteminstanceid = rcr.id_prop
    INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle =
        CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw_new.c_SubscriptionStart, rcr.id_cycle_type)
        ELSE NULL END
    JOIN t_acc_usage_cycle auc on auc.id_acc = rw_new.c__AccountID and auc.id_usage_cycle = ccl.id_usage_cycle
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN ui.dt_start     AND ui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start < dbo.MTMinOfTwoDates(rw_new.c_PayerEnd, rw_new.c_payerend)
                                   AND pci.dt_end > dbo.MTMaxOfTwoDates(rw_new.c_payerstart, rw_new.c_PayerStart)             /* rc start goes to this payer */
                                   AND rw_new.c_membershipstart     < pci.dt_end AND rw_new.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw_new.c_cycleeffectivestart < pci.dt_end AND rw_new.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw_new.c_SubscriptionStart   < pci.dt_end AND rw_new.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	INNER JOIN tmp_old_units tou ON tou.n_value IS NOT NULL
    inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = ui.id_usage_cycle
   where
      /*Don't issue corrections for old values that are going to stay the same.*/
      NOT EXISTS (SELECT 1 FROM tmp_old_units tou WHERE rw_new.c_UnitValueStart = tou.vt_start OR rw_new.c_UnitValueEnd = tou.vt_end)
      /*Only issue corrections if there's a previous iteration.*/
      AND EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw_new.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
	  AND rw_new.c__IsAllowGenChargeByTrigger = 1;
	  
    insert INTO tmp_rc
    SELECT 'AdvanceCorrection' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,'N' AS c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValueAdvanceCorrection AS c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c__AccountID
           ,c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__IntervalID
           ,sys_guid() AS idSourceSess FROM tmp_udrc
           
    UNION ALL
           
    SELECT 'DebitCorrection' AS c_RCActionType
           ,c_RCIntervalStart
           ,c_RCIntervalEnd
           ,c_BillingIntervalStart
           ,c_BillingIntervalEnd
           ,c_RCIntervalSubscriptionStart
           ,c_RCIntervalSubscriptionEnd
           ,c_SubscriptionStart
           ,c_SubscriptionEnd
           ,c_Advance
           ,c_ProrateOnSubscription
           ,'N' AS c_ProrateInstantly
           ,c_UnitValueStart
           ,c_UnitValueEnd
           ,c_UnitValueDebitCorrection AS c_UnitValue
           ,c_RatingType
           ,c_ProrateOnUnsubscription
           ,c_ProrationCycleLength
           ,c__AccountID
           ,c__PayingAccount
           ,c__PriceableItemInstanceID
           ,c__PriceableItemTemplateID
           ,c__ProductOfferingID
           ,c_BilledRateDate
           ,c__SubscriptionID
           ,c__IntervalID
           ,sys_guid() AS idSourceSess FROM tmp_udrc;
    
	insertChargesIntoSvcTables('AdvanceCorrection','DebitCorrection');
	
	UPDATE tmp_newrw rw
	SET c_BilledThroughDate = currentDate
	where rw.c__IsAllowGenChargeByTrigger = 1;
	
END MeterUdrcFromRecurWindow;
/

ALTER FUNCTION addsecond COMPILE 
/

CREATE OR REPLACE PROCEDURE MTSP_GENERATE_ST_RCS_QUOTING
(   v_id_interval  INT ,
    v_id_billgroup INT ,
    v_id_run       INT ,
    v_id_accounts VARCHAR2,
	v_id_poid VARCHAR2,
    v_id_batch NVARCHAR2 ,
    v_n_batch_size INT ,
    v_run_date DATE ,
    p_count OUT INT)
AS
  v_total_rcs  INT;
  v_total_flat INT;
  v_total_udrc INT;
  v_n_batches  INT;
  v_id_flat    INT;
  v_id_udrc    INT;
  v_id_message NUMBER;
  v_id_ss      INT;
  v_tx_batch   VARCHAR2(256);
  
BEGIN
  
   DELETE FROM TMP_RC_ACCOUNTS_FOR_RUN;
   INSERT INTO TMP_RC_ACCOUNTS_FOR_RUN ( ID_ACC )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_accounts) as  tab_id_instance));
		
   DELETE FROM TMP_RC_POS_FOR_RUN;
   INSERT INTO TMP_RC_POS_FOR_RUN ( ID_PO )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_poid) as  tab_id_instance));

   DELETE FROM TMP_RCS;
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

   IF v_total_rcs > 0 THEN
   BEGIN
      SELECT COUNT(1) INTO v_total_flat FROM TMP_RCS WHERE c_unitvalue IS NULL;

      SELECT COUNT(1) INTO v_total_udrc FROM TMP_RCS WHERE c_unitvalue IS NOT NULL;

      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));
      v_tx_batch :=  v_id_batch;

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

   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');*/
   p_count := v_total_rcs;
   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));*/
END;
/

ALTER FUNCTION getutcdate COMPILE 
/
