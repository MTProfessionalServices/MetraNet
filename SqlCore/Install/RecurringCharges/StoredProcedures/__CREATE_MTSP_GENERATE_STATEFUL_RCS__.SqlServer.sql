CREATE PROCEDURE [dbo].[mtsp_generate_stateful_rcs]
                                            @v_id_interval  int
                                           ,@v_id_billgroup int
                                           ,@v_id_run       int
                                           ,@v_id_batch     varchar(256)
                                           ,@v_n_batch_size int
                                                               ,@v_run_date   datetime
                                           ,@p_count      int OUTPUT
AS
BEGIN
      /* SET NOCOUNT ON added to prevent extra result sets from
         interfering with SELECT statements. */
      SET NOCOUNT ON;
	  SET XACT_ABORT ON;
  DECLARE @total_rcs  int,
          @total_flat int,
          @total_udrc int,
          @n_batches  int,
          @id_flat    int,
          @id_udrc    int,
          @id_message bigint,
          @id_ss      int,
          @tx_batch   binary(16);
          
  IF OBJECT_ID (N't_rec_win_bcp_for_reverse', N'U') IS NOT NULL
    DROP TABLE t_rec_win_bcp_for_reverse

  SELECT c_BilledThroughDate, c_CycleEffectiveDate, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__ProductOfferingID, c__SubscriptionID
  INTO t_rec_win_bcp_for_reverse FROM t_recur_window

  
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Retrieving RC candidates');
SELECT
*
INTO
#TMP_RC
FROM(
	SELECT
      'Arrears'                                                                            AS c_RCActionType
      ,pci.dt_start                                                                        AS c_RCIntervalStart
      ,pci.dt_end                                                                          AS c_RCIntervalEnd
      ,ui.dt_start                                                                         AS c_BillingIntervalStart
      ,ui.dt_end                                                                           AS c_BillingIntervalEnd
      ,dbo.MTMaxOfThreeDates(rw.c_payerstart, pci.dt_start, rw.c_SubscriptionStart)        AS c_RCIntervalSubscriptionStart
      ,dbo.MTMinOfThreeDates(rw.c_payerend, pci.dt_end, rw.c_SubscriptionEnd)              AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart                                                              AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd                                                                AS c_SubscriptionEnd
      ,pci.dt_end                                                                          AS c_BilledRateDate
      ,rcr.n_rating_type                                                                   AS c_RatingType
      ,case when rw.c_advance  ='Y' then '1' else '0' end                                  AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y'
                 or (rw.c_payerstart BETWEEN ui.dt_start AND ui.dt_end AND rw.c_payerstart > rw.c_SubscriptionStart)
            then '1'
            else '0' end                                                                   AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end                       AS c_ProrateInstantly /* NOTE: c_ProrateInstantly - No longer used */
      ,case when rcr.b_prorate_on_deactivate ='Y'
                 or (rw.c_payerend BETWEEN ui.dt_start AND ui.dt_end AND rw.c_payerend < rw.c_SubscriptionEnd)
            then '1'
            else '0' end                                                                   AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END AS c_ProrationCycleLength
      ,rw.c__accountid                                                                     AS c__AccountID
      ,rw.c__payingaccount                                                                 AS c__PayingAccount
      ,rw.c__priceableiteminstanceid                                                       AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid                                                       AS c__PriceableItemTemplateID
      ,rw.c__productofferingid                                                             AS c__ProductOfferingID
      ,rw.c_payerstart                                                                     AS c_payerstart
      ,rw.c_payerend                                                                       AS c_payerend
      ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00'
         THEN '1970-01-01 00:00:00'
         ELSE rw.c_unitvaluestart END                                                      AS c_unitvaluestart 
      ,rw.c_unitvalueend                                                                   AS c_unitvalueend
      ,rw.c_unitvalue                                                                      AS c_unitvalue
      ,rw.c__subscriptionid                                                                AS c__SubscriptionID
      ,newid()                                                                             AS idSourceSess
      FROM t_usage_interval ui      
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup      
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount 
                                   AND rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* interval overlaps with cycle */
                                   AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < ui.dt_end AND rw.c_subscriptionend   > ui.dt_start /* interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop      
      INNER LOOP JOIN t_usage_cycle ccl
           ON ccl.id_usage_cycle = CASE
                                         WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                         ELSE NULL
                                   END
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND pci.dt_end BETWEEN ui.dt_start        AND ui.dt_end                             /* rc end falls in this interval */
                                   AND (
                                      pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend	/* rc start goes to this payer */
                                      OR ( /* rc end or overlaps this payer */
                                          pci.dt_end >= rw.c_payerstart
                                          AND pci.dt_start < rw.c_payerend
                                        )
                                   )
                                   AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
      WHERE
        ui.id_interval = @v_id_interval
        AND bg.id_billgroup = @v_id_billgroup
        AND rcr.b_advance <> 'Y'
 /* Exclude any accounts which have been billed through the charge range.
	     This is because they will have been billed through to the end of last period (advanced charged)
		 OR they will have ended their subscription in which case all of the charging has been done.
		 ONLY subscriptions which are scheduled to end this period which have not been ended by subscription change will be caught 
		 in these queries
		 */
      AND rw.c_BilledThroughDate < dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)
      /* CORE-8365. If Subscription started and ended in this Bill.cycle, than this is an exception case, when Arrears are generated by trigger.
      Do not charge them here, in EOP. */
      AND NOT (rw.c_SubscriptionStart >= ui.dt_start AND rw.c_SubscriptionEnd <= ui.dt_end)
UNION ALL
SELECT
      'Advance'                                                                            AS c_RCActionType
      ,pci.dt_start		                                                                     AS c_RCIntervalStart		/* Start date of Next RC Interval - the one we'll pay for In Advance in current interval */
      ,pci.dt_end		                                                                       AS c_RCIntervalEnd			/* End date of Next RC Interval - the one we'll pay for In Advance in current interval */
      ,ui.dt_start		                                                                     AS c_BillingIntervalStart	/* Start date of Current Billing Interval */
      ,ui.dt_end	                                                                      	 AS c_BillingIntervalEnd		/* End date of Current Billing Interval */
      ,CASE WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate 
         THEN dbo.MTMaxOfThreeDates(rw.c_payerstart, dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start)
         ELSE dbo.MTMaxOfThreeDates(rw.c_payerstart, pci.dt_start, rw.c_SubscriptionStart)
       END                                                                                 AS c_RCIntervalSubscriptionStart
      ,dbo.MTMinOfThreeDates(rw.c_payerend, pci.dt_end, rw.c_SubscriptionEnd)              AS c_RCIntervalSubscriptionEnd
      ,rw.c_SubscriptionStart                                                              AS c_SubscriptionStart
      ,rw.c_SubscriptionEnd                                                                AS c_SubscriptionEnd
      ,pci.dt_start                                                                        AS c_BilledRateDate
      ,rcr.n_rating_type                                                                   AS c_RatingType
      ,case when rw.c_advance  ='Y' then '1' else '0' end                                  AS c_Advance
      ,case when rcr.b_prorate_on_activate ='Y'
                 or rw.c_payerstart BETWEEN nui.dt_start AND nui.dt_end
            then '1'
            else '0' end                                                                   AS c_ProrateOnSubscription
      ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end                       AS c_ProrateInstantly /* NOTE: c_ProrateInstantly - No longer used */
      ,case when rcr.b_prorate_on_deactivate ='Y'
                 or rw.c_payerend BETWEEN nui.dt_start AND nui.dt_end
            then '1'
            else '0' end                                                                   AS c_ProrateOnUnsubscription
      ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END AS c_ProrationCycleLength
      ,rw.c__accountid                                                                     AS c__AccountID
      ,rw.c__payingaccount                                                                 AS c__PayingAccount
      ,rw.c__priceableiteminstanceid                                                       AS c__PriceableItemInstanceID
      ,rw.c__priceableitemtemplateid                                                       AS c__PriceableItemTemplateID
      ,rw.c__productofferingid                                                             AS c__ProductOfferingID
      ,rw.c_payerstart                                                                     AS c_payerstart
      ,rw.c_payerend                                                                       AS c_payerend
      ,case when rw.c_unitvaluestart < '1970-01-01 00:00:00'
         THEN '1970-01-01 00:00:00'
         ELSE rw.c_unitvaluestart END                                                      AS c_unitvaluestart 
      ,rw.c_unitvalueend                                                                   AS c_unitvalueend
      ,rw.c_unitvalue                                                                      AS c_unitvalue
      ,rw.c__subscriptionid                                                                AS c__SubscriptionID
      ,newid()                                                                             AS idSourceSess
      FROM t_usage_interval ui
      INNER LOOP JOIN t_usage_interval nui ON ui.id_usage_cycle = nui.id_usage_cycle AND dbo.AddSecond(ui.dt_end) = nui.dt_start
      INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
      INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup      
      INNER LOOP JOIN t_recur_window rw WITH(INDEX(rc_window_time_idx)) ON bgm.id_acc = rw.c__payingaccount 
                                   AND rw.c_payerstart          < nui.dt_end AND rw.c_payerend          > nui.dt_start /* next interval overlaps with payer */
                                   AND rw.c_cycleeffectivestart < nui.dt_end AND rw.c_cycleeffectiveend > nui.dt_start /* next interval overlaps with cycle */
                                   AND rw.c_membershipstart     < nui.dt_end AND rw.c_membershipend     > nui.dt_start /* next interval overlaps with membership */
                                   AND rw.c_subscriptionstart   < nui.dt_end AND rw.c_subscriptionend   > nui.dt_start /* next interval overlaps with subscription */
                                   AND rw.c_unitvaluestart      < nui.dt_end AND rw.c_unitvalueend      > nui.dt_start /* next interval overlaps with UDRC */
      INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop      
      INNER LOOP JOIN t_usage_cycle ccl
           ON ccl.id_usage_cycle = CASE
                                         WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                         WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                         ELSE NULL
                                   END
      INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
      INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
                                   AND (
                                      pci.dt_start BETWEEN nui.dt_start AND nui.dt_end /* RCs that starts in Next Account's Billing Cycle */
                                      
                                      /* Fix for CORE-7060:
                                      In case subscription starts after current EOP we should also charge:
                                      RCs that ends in Next Account's Billing Cycle
                                      and if Next Account's Billing Cycle in the middle of RCs interval.
                                      As in this case, they haven't been charged as Instant RC (by trigger) */
                                      OR (
                                          rw.c_SubscriptionStart >= nui.dt_start
                                          AND pci.dt_end >= nui.dt_start
                                          AND pci.dt_start < nui.dt_end
                                        )
                                   )
                                   AND (
                                      pci.dt_start BETWEEN rw.c_payerstart  AND rw.c_payerend	/* rc start goes to this payer */
                                      
                                      /* Fix for CORE-7273:
                                      Logic above, that relates to Account Billing Cycle, should be duplicated for Payer's Billing Cycle.
                                      
                                      CORE-7273 related case: If Now = EOP = Subscription Start then:
                                      1. Not only RC's that starts in this payer's cycle should be charged, but also the one, that ends and overlaps it;
                                      2. Proration wasn't calculated by trigger and should be done by EOP. */
                                      OR (
                                          pci.dt_end >= rw.c_payerstart
                                          AND pci.dt_start < rw.c_payerend
                                        )
                                   )                                   
                                   AND rw.c_unitvaluestart		< pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
                                   AND rw.c_membershipstart		< pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
                                   AND rw.c_cycleeffectiveend	> pci.dt_start /* rc overlaps with this cycle */
                                   AND rw.c_subscriptionend		> pci.dt_start /* rc overlaps with this subscription */
      WHERE
        ui.id_interval = @v_id_interval
        AND bg.id_billgroup = @v_id_billgroup
        AND rcr.b_advance = 'Y'
 /* Exclude any accounts which have been billed through the charge range.
	     This is because they will have been billed through to the end of last period (advanced charged)
		 OR they will have ended their subscription in which case all of the charging has been done.
		 ONLY subscriptions which are scheduled to end this period which have not been ended by subscription change will be caught 
		 in these queries
		 */
        AND rw.c_BilledThroughDate < dbo.mtmaxoftwodates(
                   (
                       CASE 
                           WHEN rcr.tx_cycle_mode <> 'Fixed' AND nui.dt_start <> c_cycleEffectiveDate 
                           THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(c_cycleEffectiveDate), pci.dt_start) 
                           ELSE pci.dt_start END
                   ),
                   rw.c_SubscriptionStart
               )
)A;

SELECT @total_rcs  = COUNT(1) FROM #tmp_rc;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'RC Candidate Count: ' + CAST(@total_rcs AS VARCHAR));

if @total_rcs > 0
BEGIN

SELECT @total_flat = COUNT(1) FROM #tmp_rc where c_unitvalue is null;
SELECT @total_udrc = COUNT(1) FROM #tmp_rc where c_unitvalue is not null;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);

SELECT @tx_batch = cast(N'' as xml).value('xs:hexBinary(sql:variable("@v_id_batch"))', 'binary(16)');
INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));

IF (@tx_batch IS NOT NULL)
BEGIN
UPDATE t_batch SET n_metered = @total_rcs, n_expected = @total_rcs WHERE tx_batch = @tx_batch;
END;

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

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');

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

                  INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');

END;
    /** UPDATE THE BILLED THROUGH DATE TO THE END OF THE ADVANCED CHARGE 
			 ** (IN CASE THE END THE SUB BEFORE THE END OF THE MONTH)
			 ** THIS WILL MAKE SURE THE CREDIT IS CORRECT AND MAKE SURE THERE ARE NOT CHARGES 
			 ** REGENERATED FOR ALL THE MONTHS WHERE RC ADAPTER RAN (But forgot to mark)
			 ** Only for advanced charges.
		     **/
    MERGE
    INTO    t_recur_window trw
    USING   (
              SELECT MAX(c_RCIntervalSubscriptionEnd) AS NewBilledThroughDate, c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
              FROM #tmp_rc
              WHERE c_RCActionType = 'Advance'
              GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
            ) trc
    ON      (
              trw.c__AccountID = trc.c__AccountID
              AND trw.c__SubscriptionID = trc.c__SubscriptionID
              AND trw.c__PriceableItemInstanceID = trc.c__PriceableItemInstanceID
              AND trw.c__PriceableItemTemplateID = trc.c__PriceableItemTemplateID
              AND trw.c__ProductOfferingID = trc.c__ProductOfferingID
            )
    WHEN MATCHED THEN
    UPDATE
    SET     trw.c_BilledThroughDate = trc.NewBilledThroughDate;

 END;

 SET @p_count = @total_rcs;

INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));

END;
