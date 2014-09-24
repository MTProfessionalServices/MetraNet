CREATE PROCEDURE [dbo].[MeterCreditFromRecurWindow]
  @currentDate DATETIME
AS
BEGIN
  /* SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements. */
  SET NOCOUNT ON;
  IF (( SELECT VALUE FROM t_db_values WHERE parameter = N'InstantRc' ) = 'false' ) RETURN;

  DECLARE @newSubStart DATETIME,
          @newSubEnd   DATETIME,
          @curSubStart DATETIME,
          @curSubEnd   DATETIME,
          /* Borders of updated Sub.End range will stand for internal @subscriptionStart and @subscriptionEnd to charge this range. */
          @subscriptionStart        DATETIME,
          @subscriptionEnd          DATETIME,
          @rcAction                 VARCHAR(20),
          @isEndDateUpdated         BIT = 0,
  /* TODO: Remove duplicated values once 1-st and 2-nd query is executed conditionally */
          /* Borders of updated Sub.Start range will stand for internal @subscriptionStart2 and @subscriptionEnd2 to charge this range. */
          @subscriptionStart2       DATETIME,
          @subscriptionEnd2         DATETIME,
          @rcAction2                VARCHAR(20),
          @isStartDateUpdated       BIT = 0,
          /* Values for full recharge of Arrears if End date update crosses EOP border */
          @subscriptionStart3       DATETIME,
          @subscriptionEnd3         DATETIME,
          @rcAction3                VARCHAR(20)

  SELECT @subscriptionStart = dbo.MTMinDate(), @subscriptionEnd = dbo.MTMinDate();

  /* Assuming only 1 subscription can be changed at a time */
  SELECT TOP 1 /* Using only 1-st PI of RC */
         @newSubStart = new_sub.vt_start, @newSubEnd = new_sub.vt_end,
         @curSubStart = current_sub.vt_start, @curSubEnd = current_sub.vt_end
  FROM #recur_window_holder rw
      INNER LOOP JOIN t_sub_history new_sub ON new_sub.id_acc = rw.c__AccountID
          AND new_sub.id_sub = rw.c__SubscriptionID
          AND new_sub.tt_end = dbo.MTMaxDate()
      INNER LOOP JOIN t_sub_history current_sub ON current_sub.id_acc = rw.c__AccountID
          AND current_sub.id_sub = rw.c__SubscriptionID
          AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start)
  /* Work with RC only. Exclude UDRC. */
  WHERE rw.c_UnitValue IS NULL

  /* It is a new subscription - nothing to recharge */
  IF @curSubStart IS NULL RETURN;
          
  IF (@newSubEnd <> @curSubEnd)
  BEGIN
      /* TODO: Run only 1-st query if condition is true */
      SET @isEndDateUpdated = 1

      SELECT @subscriptionStart = dbo.MTMinOfTwoDates(@newSubEnd, @curSubEnd),
             @subscriptionEnd = dbo.MTMaxOfTwoDates(@newSubEnd, @curSubEnd),
             @rcAction = CASE 
                              WHEN @newSubEnd > @curSubEnd THEN 
                                   'Debit'
                              ELSE 'Credit'
                         END;
      /* Sub. start date has 23:59:59 time. We need next day and 00:00:00 time for the start date */
      SET @subscriptionStart = dbo.AddSecond(@subscriptionStart);

      IF (@newSubEnd > @curSubEnd)
      BEGIN
          SET @subscriptionStart3 = @curSubStart
          SET @subscriptionEnd3   = @curSubEnd
          SET @rcAction3          = 'Credit'
      END
      ELSE
      BEGIN
          SET @subscriptionStart3 = @newSubStart
          SET @subscriptionEnd3   = @newSubEnd
          SET @rcAction3          = 'Debit'
      END
  END;

  IF (@newSubStart <> @curSubStart)
  BEGIN
      /* TODO: Run only 2-nd query if condition is true */
      SET @isStartDateUpdated = 1

      SELECT @subscriptionStart2 = dbo.MTMinOfTwoDates(@newSubStart, @curSubStart),
             @subscriptionEnd2 = dbo.MTMaxOfTwoDates(@newSubStart, @curSubStart),
             @rcAction2 =  CASE 
                                WHEN @newSubStart < @curSubStart THEN 
                                     'InitialDebit'
                                ELSE 'InitialCredit'
                           END;
      /* Sub. end date has 00:00:00 time. We need previous day and 23:59:59 time for the end date */
      SELECT @subscriptionEnd2 = dbo.SubtractSecond(@subscriptionEnd2);
  END;


  SELECT
         /* First, credit or debit the difference in the ending of the subscription.  If the new one is later, this will be a debit, otherwise a credit.
         * TODO: Remove this comment:"There's a weird exception when this is (a) an arrears charge, (b) the old subscription end was after the pci end date, and (c) the new sub end is inside the pci end date." */
         @rcAction                                                                                  AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, @subscriptionStart)                                      AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, @subscriptionEnd)                                          AS c_RCIntervalSubscriptionEnd,
         @subscriptionStart                                                                         AS c_SubscriptionStart,
         @subscriptionEnd                                                                           AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, @subscriptionStart)                                        AS c_BilledRateDate,
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
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId,
         0                                                                                          AS IsArrearsRecalculation
         INTO #tmp_rc_1
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              /* AddSecond() relates to CORE-8443*/
              AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND @subscriptionEnd > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, @subscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND @subscriptionStart       < pci.dt_end AND @subscriptionEnd       > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         ui.dt_start < @currentDate
         /* We're working only with Bill. interval where subscription starts, except future one */
         AND @newSubStart BETWEEN ui.dt_start AND ui.dt_end
         AND @isEndDateUpdated = 1
         AND NOT (rw.c_advance = 'N' AND @newSubEnd > ui.dt_end)
         /* Skip if this is an Arrears AND end date update crosses the EOP border (this case will be handled below) */
         AND NOT (rw.c_advance = 'N' AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < @subscriptionEnd)

  UNION ALL

  SELECT
         /* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
         @rcAction2                                                                                 AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, @subscriptionStart2)                                     AS c_RCIntervalSubscriptionStart,         
         /* If new Subscription Start somewhere in future, after EOP - always use End of RC cycle */
         CASE
              WHEN ui.dt_end <= @subscriptionEnd2 THEN pci.dt_end
              ELSE dbo.mtminoftwodates(pci.dt_end, @subscriptionEnd2)
         END                                                                                        AS c_RCIntervalSubscriptionEnd,
         @subscriptionStart2                                                                        AS c_SubscriptionStart,
         @subscriptionEnd2                                                                          AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, @subscriptionStart2)                                       AS c_BilledRateDate,
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
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId,
         0                                                                                          AS IsArrearsRecalculation
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND @subscriptionStart2      < ui.dt_end AND @subscriptionEnd2      > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, @subscriptionStart2, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND @subscriptionStart2      < pci.dt_end AND @subscriptionEnd2      > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         ui.dt_start < @currentDate
         AND @isStartDateUpdated = 1
         AND NOT (rw.c_advance = 'N' AND @newSubEnd > ui.dt_end)
         /* Skip if this is an Arrears AND end date update crosses the EOP border (this case will be handled below) */
         AND NOT (rw.c_advance = 'N' AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < @subscriptionEnd)

  UNION ALL

  SELECT
         /* Handle the case if this is an Arrears AND end date update crosses the EOP border */
         @rcAction3                                                                                 AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, @subscriptionStart3)                                     AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, @subscriptionEnd3)                                         AS c_RCIntervalSubscriptionEnd,
         @subscriptionStart3                                                                        AS c_SubscriptionStart,
         @subscriptionEnd3                                                                          AS c_SubscriptionEnd,
         dbo.MTMinOfTwoDates(pci.dt_end, @subscriptionStart3)                                       AS c_BilledRateDate,
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
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         currentui.id_interval                                                                      AS c__IntervalID,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId,
         1                                                                                          AS IsArrearsRecalculation
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND @subscriptionStart3      < ui.dt_end AND @subscriptionEnd3      > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER LOOP JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, @subscriptionStart3, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER LOOP JOIN t_pc_interval pci WITH(INDEX(cycle_time_pc_interval_index)) ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND @subscriptionStart3      < pci.dt_end AND @subscriptionEnd3      > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         ui.dt_start < @currentDate
         /* Handle the case if this is an Arrears AND end date update crosses the EOP border */
         AND rw.c_advance = 'N' AND @subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < @subscriptionEnd;

  /* Remove extra charges for RCs with No Proration (CORE-6789) */
  IF (@isEndDateUpdated = 1)
  BEGIN
    /* PIs, that starts outside of End Date Update range, should not be handled here */
    DELETE FROM #tmp_rc_1 WHERE c_ProrateOnUnsubscription = '0'
        AND c_RCIntervalStart < @subscriptionStart
        AND IsArrearsRecalculation = 0;

    /* Turn On "Prorate On Subscription" if this is the 1-st RC Cycle of PI with "Prorate on Unsubscription" */
    UPDATE #tmp_rc_1
    SET c_ProrateOnSubscription = '1'
    WHERE c_ProrateOnUnsubscription = '1' AND @newSubStart BETWEEN c_RCIntervalStart AND c_RCIntervalEnd
  END
  IF (@isStartDateUpdated = 1)
    /* PIs, that ends outside of Start Date Update range, should not be handled here */
    DELETE FROM #tmp_rc_1 WHERE c_ProrateOnSubscription = '0' AND c_RCIntervalEnd > @subscriptionEnd2
      AND @subscriptionEnd2 < c_BillingIntervalEnd
      AND IsArrearsRecalculation = 0; /* If start date was updated To or From "after EOP date" all PIs should be charged. Don't delete anything. */

  SELECT c__SubscriptionID, c__PriceableItemInstanceID, c__PriceableItemTemplateID
         INTO #unbilledPIs
  FROM   #tmp_rc_1
  WHERE
         c_Advance = 0 AND c_BillingIntervalEnd BETWEEN @curSubEnd AND @newSubEnd
  UNION ALL
  SELECT c__SubscriptionID, c__PriceableItemInstanceID, c__PriceableItemTemplateID
  FROM   #tmp_rc_1
  WHERE
         c_Advance = 1 AND c_BillingIntervalEnd BETWEEN @curSubStart AND @newSubStart

  /* Changes related to ESR-6709:"Subscription refunded many times" */
  /* Now determine if the interval and if the RC adapter has run, if no remove those advanced charge credits */
  DECLARE @prev_interval INT, @cur_interval INT, @do_credit INT

  SELECT @prev_interval = pui.id_interval, @cur_interval = cui.id_interval
  FROM   t_usage_interval cui WITH(NOLOCK)
         INNER JOIN #tmp_rc_1 ON #tmp_rc_1.c__IntervalID = cui.id_interval
         INNER JOIN t_usage_cycle uc WITH(NOLOCK) ON cui.id_usage_cycle = uc.id_usage_cycle
         INNER JOIN t_usage_interval pui WITH(NOLOCK) ON pui.dt_end = dbo.SubtractSecond(cui.dt_start)
              AND pui.id_usage_cycle = cui.id_usage_cycle

  SELECT @do_credit = (
             CASE 
                  WHEN ISNULL(rei.id_arg_interval, 0) = 0 THEN 0
                  ELSE CASE 
                            WHEN (rr.tx_type = 'Execute' AND rei.tx_status = 'Succeeded') THEN 
                                 1
                            ELSE 0
                       END
             END
         )
  FROM   t_recevent re
         LEFT OUTER JOIN t_recevent_inst rei
              ON  re.id_event = rei.id_event
              AND rei.id_arg_interval = @prev_interval
         LEFT OUTER JOIN t_recevent_run rr
              ON  rr.id_instance = rei.id_instance
  WHERE  re.dt_deactivated IS NULL
         AND re.tx_name = 'RecurringCharges'
         AND rr.id_run = (
                 SELECT MAX(rr.id_run)
                 FROM   t_recevent re
                        LEFT OUTER JOIN t_recevent_inst rei
                             ON  re.id_event = rei.id_event
                             AND rei.id_arg_interval = @prev_interval
                        LEFT OUTER JOIN t_recevent_run rr
                             ON  rr.id_instance = rei.id_instance
                 WHERE  re.dt_deactivated IS NULL
                        AND re.tx_name = 'RecurringCharges'
             )

  IF @do_credit = 0
  BEGIN
      DELETE rcred
      FROM   #tmp_rc_1 rcred
             INNER JOIN t_usage_interval ui
                  ON  ui.id_interval = @cur_interval
                  AND rcred.c_BillingIntervalStart = ui.dt_start
  END;
  /* End of ESR-6709 */

  SELECT c_RCActionType,
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
         c_UnitValueStart,
         c_UnitValueEnd,
         c_UnitValue,
         c_RatingType,
         c_ProrateOnUnsubscription,
         c_ProrationCycleLength,
         c__AccountID,
         c__PayingAccount,
         c__PriceableItemInstanceID,
         c__PriceableItemTemplateID,
         c__ProductOfferingID,
         c_BilledRateDate,
         c__SubscriptionID,
         c__IntervalID,
         NEWID() AS idSourceSess,
         c__QuoteBatchId
         INTO #tmp_rc
  FROM #tmp_rc_1;

  /* If no charges to meter, return immediately */
  IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;
 
  EXEC InsertChargesIntoSvcTables;

  MERGE
  INTO    #recur_window_holder trw
  USING   (
            SELECT MAX(dbo.mtminoftwodates(c_RCIntervalEnd, @newSubEnd)) AS NewBilledThroughDate,
                   c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__SubscriptionID
            FROM #tmp_rc
            GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__SubscriptionID
          ) trc
  ON      (
            trw.c__AccountID = trc.c__AccountID
            AND trw.c__SubscriptionID = trc.c__SubscriptionID
            AND trw.c__PriceableItemInstanceID = trc.c__PriceableItemInstanceID
            AND trw.c__PriceableItemTemplateID = trc.c__PriceableItemTemplateID
            AND trw.c__ProductOfferingID = trc.c__ProductOfferingID
            AND trw.c__IsAllowGenChargeByTrigger = 1
          )
  WHEN MATCHED THEN
  UPDATE
  SET     trw.c_BilledThroughDate = trc.NewBilledThroughDate;

  UPDATE rw
  SET    c_BilledThroughDate = dbo.mtmindate()
  FROM   #recur_window_holder rw
  WHERE
         rw.c__SubscriptionID IN (SELECT c__SubscriptionID FROM #unbilledPIs)
         AND rw.c__PriceableItemInstanceID IN (SELECT c__PriceableItemInstanceID FROM #unbilledPIs)
         AND rw.c__IsAllowGenChargeByTrigger = 1;

END;
