CREATE PROCEDURE [dbo].[MeterUdrcFromRecurWindow]
  @currentDate DATETIME,
  @actionType NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @id_run INT
	declare @idMessage BIGINT
	DECLARE @idService INT
	DECLARE @numBlocks INT

  IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;

  SELECT 
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                                  AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_RCIntervalSubscriptionEnd,
         rw.c_SubscriptionStart                                                                     AS c_SubscriptionStart,
         rw.c_SubscriptionEnd                                                                       AS c_SubscriptionEnd,        
         dbo.MTMinOfTwoDates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_BilledRateDate,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,         
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,         
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         trv.vt_start                                                                               AS c_UnitValueStart,
         trv.vt_end                                                                                 AS c_UnitValueEnd,
         trv.n_value                                                                                AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       as c__QuoteBatchId
        INTO #tmp_udrc_1
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND rw.c_SubscriptionStart   < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER JOIN #tmp_changed_units trv ON trv.id_sub = rw.C__SubscriptionID AND trv.id_prop = rw.c__PriceableItemInstanceID
              AND trv.vt_start < rw.c_UnitValueEnd AND trv.vt_end > rw.c_UnitValueStart
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      (rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
              AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE 
        /* Only issue corrections if there's a previous iteration. */
        EXISTS (SELECT 1 FROM t_recur_value rv WHERE rv.id_sub = rw.c__SubscriptionID AND rv.tt_end < dbo.MTMaxDate())
        /* Don't meter in the current interval for initial */
        AND ui.dt_start < @currentDate
        AND rw.c__IsAllowGenChargeByTrigger = 1; 

  SELECT @actionType AS c_RCActionType,
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
         'N' AS c_ProrateInstantly,
         c_UnitValueStart,
         c_UnitValueEnd,
         c_UnitValue,
         c_RatingType,
         c_ProrateOnUnsubscription,
         c_ProrationCycleLength,
         c_BilledRateDate,
         c__SubscriptionID,
         c__AccountID,
         c__PayingAccount,
         c__PriceableItemInstanceID,
         c__PriceableItemTemplateID,
         c__ProductOfferingID,
         c__IntervalID,
         NEWID() AS idSourceSess,
         c__QuoteBatchId INTO #tmp_rc
  FROM   #tmp_udrc_1;

  /* If no charges to meter, return immediately */
  IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;

  EXEC InsertChargesIntoSvcTables;

  UPDATE rw
  SET    c_BilledThroughDate = @currentDate
  FROM   #recur_window_holder rw
  WHERE  rw.c__IsAllowGenChargeByTrigger = 1;
 END;