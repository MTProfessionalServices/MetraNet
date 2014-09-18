CREATE PROCEDURE [dbo].[MTSP_GENERATE_CHARGES_QUOTING]
	@v_id_interval  int
	,@v_id_billgroup int
	,@v_id_run       int
	,@v_id_accounts VARCHAR(4000)										   
	,@v_id_poid VARCHAR(4000)
	,@v_id_batch     varchar(256)
	,@v_n_batch_size int
	,@v_run_date   datetime
	,@v_is_group_sub int
	,@dt_start datetime
	,@dt_end datetime,
	@p_count int OUTPUT

AS BEGIN

DECLARE @id_nonrec int,
		@n_batches  int,
		@total_nrcs int,
		@id_message bigint,
		@id_ss int,
		@tx_batch binary(16),
		@total_rcs  int,
        @total_flat int,
        @total_udrc int,
        @id_flat    int,
        @id_udrc    int
        
IF OBJECT_ID('tempdb..#TMP_RC_ACCOUNTS_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_ACCOUNTS_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_RC_POID_FOR_RUN') IS NOT NULL
DROP TABLE #TMP_RC_POID_FOR_RUN

IF OBJECT_ID('tempdb..#TMP_NRC') IS NOT NULL
DROP TABLE #TMP_NRC

IF OBJECT_ID('tempdb..#TMP_RC') IS NOT NULL
DROP TABLE #TMP_RC

CREATE TABLE #TMP_NRC
  (
  id_source_sess uniqueidentifier,
  c_NRCEventType int,
  c_NRCIntervalStart datetime,
  c_NRCIntervalEnd datetime,
  c_NRCIntervalSubscriptionStart datetime,
  c_NRCIntervalSubscriptionEnd datetime,
  c__AccountID int,
  c__PriceableItemInstanceID int,
  c__PriceableItemTemplateID int,
  c__ProductOfferingID int,
  c__SubscriptionID int,
  c__IntervalID int,
  c__Resubmit int,
  c__TransactionCookie int,
  c__CollectionID binary (16)
  )


SELECT * INTO #TMP_RC_ACCOUNTS_FOR_RUN FROM(SELECT value as id_acc FROM CSVToInt(@v_id_accounts)) A;
SELECT * INTO #TMP_RC_POID_FOR_RUN FROM(SELECT value as id_po FROM CSVToInt(@v_id_poid)) A;

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');

SELECT
*
INTO
#TMP_RC
FROM(
SELECT
newid() AS idSourceSess,
      'Arrears' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)          AS c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_end      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' 
      THEN '1970-01-01 00:00:00' 
      ELSE rw.c_unitvaluestart END AS c_unitvaluestart 
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
      FROM t_usage_interval ui
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER JOIN #TMP_RC_POID_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl 
          ON ccl.id_usage_cycle = CASE 
                                        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
                                        WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle 
                                        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
            ELSE NULL
                                  END
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND pci.dt_end BETWEEN rw.c_payerstart    AND rw.c_payerend                         /* rc end goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      	  
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance <> 'Y'
UNION ALL
SELECT
newid() AS idSourceSess,
      'Advance' AS c_RCActionType
      ,pci.dt_start      AS c_RCIntervalStart
      ,pci.dt_end      AS c_RCIntervalEnd
      ,ui.dt_start      AS c_BillingIntervalStart
      ,ui.dt_end          AS c_BillingIntervalEnd
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
       ELSE pci.dt_start END as c_RCIntervalSubscriptionStart
      ,dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)          AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart          AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd          AS c_SubscriptionEnd
      ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
      ,case when rcr.b_prorate_on_deactivate ='Y' then '1' else '0' end       AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
      ,rw.c__accountid AS c__AccountID
      ,rw.c__payingaccount      AS c__PayingAccount
      ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
      ,rw.c__productofferingid      AS c__ProductOfferingID
      ,pci.dt_start      AS c_BilledRateDate
      ,rw.c__subscriptionid      AS c__SubscriptionID
	  ,rw.c_payerstart
	  ,rw.c_payerend
	  ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00' THEN '1970-01-01 00:00:00' ELSE rw.c_unitvaluestart END AS c_unitvaluestart 
	  ,rw.c_unitvalueend
	  ,rw.c_unitvalue
	  ,rcr.n_rating_type AS c_RatingType
     FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
	  LEFT JOIN #TMP_RC_ACCOUNTS_FOR_RUN bgm ON 1=1
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER JOIN #TMP_RC_POID_FOR_RUN po on po.id_po = rw.c__ProductOfferingID
	  INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) ELSE NULL END
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_start BETWEEN nui.dt_start     AND nui.dt_end                            /* rc start falls in this interval */
                                   AND pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      where 1=1
      and ui.id_interval = @v_id_interval
      /*and bg.id_billgroup = @v_id_billgroup*/
      and rcr.b_advance = 'Y'
)A      ;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;


IF @v_is_group_sub > 0
BEGIN

	INSERT INTO #TMP_NRC
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
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	
	SELECT
			newid() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			mem.vt_start AS	c_NRCIntervalSubscriptionStart,
			mem.vt_end AS	c_NRCIntervalSubscriptionEnd,
			mem.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			inner join t_gsubmember mem on mem.id_group = sub.id_group
			inner join #TMP_RC_ACCOUNTS_FOR_RUN acc on acc.id_acc = mem.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	;

END
ELSE
BEGIN

	INSERT INTO #TMP_NRC
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
		c__Resubmit,
		c__TransactionCookie,
		c__CollectionID
	)
	SELECT
			newid() AS id_source_sess,
			nrc.n_event_type AS	c_NRCEventType,
			@dt_start AS c_NRCIntervalStart,
			@dt_end AS 	c_NRCIntervalEnd,
			sub.vt_start AS	c_NRCIntervalSubscriptionStart,
			sub.vt_end AS	c_NRCIntervalSubscriptionEnd,
			sub.id_acc AS	c__AccountID,
			plm.id_pi_instance AS	c__PriceableItemInstanceID,
			plm.id_pi_template AS	c__PriceableItemTemplateID,
			sub.id_po AS c__ProductOfferingID,
			sub.id_sub AS	c__SubscriptionID,
			@v_id_interval AS c__IntervalID,
			'0' AS c__Resubmit,
			NULL AS c__TransactionCookie,
			@tx_batch AS c__CollectionID
	FROM	t_sub sub
			inner join #TMP_RC_ACCOUNTS_FOR_RUN acc on acc.id_acc = sub.id_acc
			inner join #TMP_RC_POID_FOR_RUN po on po.id_po = sub.id_po
			inner join t_po on sub.id_po = t_po.id_po
			inner join t_pl_map plm on sub.id_po = plm.id_po and plm.id_paramtable IS NULL
			inner join t_base_props bp on bp.id_prop = plm.id_pi_instance and bp.n_kind = 30
			inner join t_nonrecur nrc on nrc.id_prop = bp.id_prop and nrc.n_event_type = 1
	;

END

SELECT @total_nrcs = count(1) from #tmp_nrc;

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

if @total_flat > 0
begin

    
set @id_flat = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/flatrecurringcharge');
    
SET @n_batches = (@total_flat / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_flat AS id_svc,
    1 AS b_root
FROM #tmp_rc
 where c_unitvalue is null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_FlatRecurringCharge
(id_source_sess
    ,id_parent_source_sess
    ,id_external
    ,c_RCActionType
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
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
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
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
FROM #tmp_rc
 where c_unitvalue is null;
          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
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
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NULL
              ) a
            GROUP BY a.id_message;

END;
if @total_udrc > 0
begin

set @id_udrc = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/udrecurringcharge');
    
SET @n_batches = (@total_udrc / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    idSourceSess AS id_source_sess
FROM #tmp_rc where c_unitvalue is not null;
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, id_svc, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_ss,
    @id_udrc AS id_svc,
    1 AS b_root
FROM #tmp_rc
 where c_unitvalue is not null) a
GROUP BY a.id_message, a.id_ss, a.id_svc, a.b_root;
 
INSERT INTO t_svc_UDRecurringCharge
(id_source_sess, id_parent_source_sess, id_external, c_RCActionType, c_RCIntervalStart,c_RCIntervalEnd,c_BillingIntervalStart,c_BillingIntervalEnd
    ,c_RCIntervalSubscriptionStart
    ,c_RCIntervalSubscriptionEnd
    ,c_SubscriptionStart
    ,c_SubscriptionEnd
    ,c_Advance
    ,c_ProrateOnSubscription
/*    ,c_ProrateInstantly */
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
    ,c__Resubmit
    ,c__TransactionCookie
    ,c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype)
SELECT
    idSourceSess AS id_source_sess
    ,NULL AS id_parent_source_sess
    ,NULL AS id_external
    ,c_RCActionType
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
/*    ,c_ProrateInstantly */
    ,c_ProrateOnUnsubscription
    ,c_ProrationCycleLength
    ,c__AccountID
    ,c__PayingAccount
    ,c__PriceableItemInstanceID
    ,c__PriceableItemTemplateID
    ,c__ProductOfferingID
    ,c_BilledRateDate
    ,c__SubscriptionID
    ,@v_id_interval AS c__IntervalID
    ,'0' AS c__Resubmit
    ,NULL AS c__TransactionCookie
    ,@tx_batch AS c__CollectionID
	,c_unitvaluestart
	,c_unitvalueend
	,c_unitvalue
	,c_ratingtype
FROM #tmp_rc
 where c_unitvalue is not null;

          INSERT
          INTO t_message
            (
              id_message,
              id_route,
              dt_crt,
              dt_metered,
              dt_assigned,
              id_listener,
              id_pipeline,
              dt_completed,
              id_feedback,
              tx_TransactionID,
              tx_sc_username,
              tx_sc_password,
              tx_sc_namespace,
              tx_sc_serialized,
              tx_ip_address
            )
            SELECT
              id_message,
              NULL,
              @v_run_date,
              @v_run_date,
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
            FROM
              (SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY idSourceSess) % @n_batches) AS id_message
              FROM #tmp_rc
              WHERE c_unitvalue IS NOT NULL
              ) a
            GROUP BY a.id_message;			
END;
 
 END;

if @total_nrcs > 0
BEGIN
set @id_nonrec = (SELECT id_enum_data FROM t_enum_data ted WHERE ted.nm_enum_data =
	'metratech.com/nonrecurringcharge');

SET @n_batches = (@total_nrcs / @v_n_batch_size) + 1;
    EXEC GetIdBlock @n_batches, 'id_dbqueuesch', @id_message OUTPUT;
    EXEC GetIdBlock @n_batches, 'id_dbqueuess',  @id_ss OUTPUT;

INSERT INTO t_session
(id_ss, id_source_sess)
SELECT @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    id_source_sess
FROM #tmp_nrc
         
INSERT INTO t_session_set
(id_message, id_ss, id_svc, b_root, session_count)
SELECT id_message, id_ss, @id_nonrec, b_root, COUNT(1) as session_count
FROM
(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message,
    @id_ss + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_ss,
    1 AS b_root
FROM #tmp_nrc) a
GROUP BY a.id_message, a.id_ss, a.b_root;
 
INSERT INTO t_svc_NonRecurringCharge
(
	id_source_sess,
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
    c__CollectionID
)
SELECT
    id_source_sess,
    NULL AS id_parent_source_sess,
    NULL AS id_external,
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
    c__CollectionID
FROM #tmp_nrc

INSERT 	INTO t_message
(
	id_message,
	id_route,
	dt_crt,
	dt_metered,
	dt_assigned,
	id_listener,
	id_pipeline,
	dt_completed,
	id_feedback,
	tx_TransactionID,
	tx_sc_username,
	tx_sc_password,
	tx_sc_namespace,
	tx_sc_serialized,
	tx_ip_address
)
SELECT
	id_message,
	NULL,
	@v_run_date,
	@v_run_date,
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
FROM
	(SELECT @id_message + (ROW_NUMBER() OVER (ORDER BY id_source_sess) % @n_batches) AS id_message
	FROM #tmp_nrc
	) a
GROUP BY a.id_message;

drop table #tmp_nrc
END

SET @p_count = @total_rcs + @total_nrcs
END