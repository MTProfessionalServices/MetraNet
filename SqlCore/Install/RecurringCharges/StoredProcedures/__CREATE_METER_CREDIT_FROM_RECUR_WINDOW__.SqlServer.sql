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
          @rcActionForEndDateUpdate nvarchar(20),
          @subscriptionStart        DATETIME,
          @subscriptionEnd          DATETIME,
          @isEndDateUpdated         BIT = 0,
  /* TODO: Remove duplicated values once 1-st and 2-nd query is executed conditionally */
          @rcActionForEndDateUpdate2 nvarchar(20),
          @subscriptionStart2        DATETIME,
          @subscriptionEnd2          DATETIME,
          @isStartDateUpdated        BIT = 0

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
             @rcActionForEndDateUpdate = CASE 
                                              WHEN @newSubEnd > @curSubEnd THEN 
                                                   'Debit'
                                              ELSE 'Credit'
                                         END;
      /* Sub. start date has 23:59:59 time. We need next day and 00:00:00 time for the start date */
      SET @subscriptionStart = dbo.AddSecond(@subscriptionStart);   
  END;

  IF (@newSubStart <> @curSubStart)
  BEGIN
      /* TODO: Run only 2-nd query if condition is true */
      SET @isStartDateUpdated = 1

      SELECT @subscriptionStart2 = dbo.MTMinOfTwoDates(@newSubStart, @curSubStart),
             @subscriptionEnd2 = dbo.MTMaxOfTwoDates(@newSubStart, @curSubStart),
             @rcActionForEndDateUpdate2 = CASE 
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
         @rcActionForEndDateUpdate                                                                  AS c_RCActionType,
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
         rw.c__subscriptionid                                                                       AS c__SubscriptionID
         INTO #tmp_rc_1
  FROM   t_usage_interval ui
         INNER JOIN #recur_window_holder rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO @subscriptionStart , rw.c_cycleeffectiveend EQUAL TO @subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND @subscriptionStart       < ui.dt_end AND @subscriptionEnd       > ui.dt_start
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
                      (rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
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
  WHERE
         ui.dt_start < @currentDate
         AND rw.c__IsAllowGenChargeByTrigger = 1
         AND @isEndDateUpdated = 1

  UNION ALL

  SELECT
         /* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
         @rcActionForEndDateUpdate2                                                                 AS c_RCActionType,
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
         rw.c__subscriptionid                                                                       AS c__SubscriptionID
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
                      (rcr.b_advance = 'Y' AND pci.dt_start BETWEEN ui.dt_start AND ui.dt_end) /* If this is in advance, check if rc start falls in this interval */
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
  WHERE
         ui.dt_start < @currentDate
         AND rw.c__IsAllowGenChargeByTrigger = 1
         AND @isStartDateUpdated = 1

 UNION

	SELECT DISTINCT 
	/* Now, handle the exceptional case above, where (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.
	* In this case, issue a debit from the pci start to the subscription end immediately. */
         'Debit'                                                                                    AS c_RCActionType,
	       pci.dt_start                                                                               AS c_RCIntervalStart,
	       pci.dt_end                                                                                 AS c_RCIntervalEnd,
	       paymentInterval.dt_start                                                                   AS c_BillingIntervalStart,
	       paymentInterval.dt_end                                                                     AS c_BillingIntervalEnd,
	       dbo.mtmaxoftwodates(pci.dt_start, new_sub.vt_start)                                        AS c_RCIntervalSubscriptionStart,
	       new_sub.vt_end                                                                             AS c_RCIntervalSubscriptionEnd,
	       new_sub.vt_start                                                                           AS c_SubscriptionStart,
	       new_sub.vt_end                                                                             AS c_SubscriptionEnd,
	       new_sub.vt_start                                                                           AS c_BilledRateDate,
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
	       rw.c__subscriptionid                                                                       AS c__SubscriptionID
	FROM   #recur_window_holder rw
	       INNER LOOP JOIN t_sub_history new_sub ON new_sub.id_acc = rw.c__AccountID AND new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
	       INNER LOOP JOIN t_sub_history current_sub ON current_sub.id_acc = rw.c__AccountID AND current_sub.id_sub = rw.c__SubscriptionID
                                                   AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start)
	       INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
	       INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount 
	       /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
	       INNER LOOP JOIN t_pc_interval pci WITH(INDEX(pci_cycle_dt_idx))
	            ON pci.id_cycle = CASE 
	                                    WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
	                                    WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
	                                    WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle,rw.c_SubscriptionStart,rcr.id_cycle_type)
	                                    ELSE NULL
	                               END
	            AND dbo.MTMinOfTwoDates(pci.dt_end, current_sub.vt_end) != dbo.MTMinOfTwoDates(pci.dt_end, new_sub.vt_end)
	            AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end)
              AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
	            AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend /* rc start goes to this payer */
	            AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
	            AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
	       INNER LOOP JOIN t_usage_interval paymentInterval ON pci.dt_start BETWEEN paymentInterval.dt_start AND paymentInterval.dt_end
	            AND paymentInterval.id_usage_cycle = pci.id_cycle
	       INNER LOOP JOIN t_usage_cycle ccl
	            ON  ccl.id_usage_cycle = CASE 
	                                          WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
	                                          WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle
	                                          WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
	                                          ELSE NULL
	                                     END
	       INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	       INNER JOIN t_usage_interval currentui ON @currentDate BETWEEN currentui.dt_start AND currentui.dt_end AND currentui.id_usage_cycle = paymentInterval.id_usage_cycle
	WHERE
	       EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate()) 
	       AND (rcr.b_prorate_on_deactivate='Y' OR pci.dt_start > dbo.mtendofday(rw.c_SubscriptionEnd))
	       /* Deal with the above-mentioned exceptional case here.
	       */
	       AND (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	       AND rw.c__IsAllowGenChargeByTrigger = 1;

	
 /* Now determine if th interval and if the RC adapter has run, if no remove those adavanced charge credits */
    DECLARE @prev_interval INT, @cur_interval INT, @do_credit INT

select @prev_interval = pui.id_interval, @cur_interval = cui.id_interval
from t_usage_interval cui WITH(NOLOCK)
inner join #tmp_rc_1 on #tmp_rc_1.c__IntervalID = cui.id_interval
inner join t_usage_cycle uc WITH(NOLOCK) on cui.id_usage_cycle = uc.id_usage_cycle
inner join t_usage_interval pui WITH(NOLOCK) ON pui.dt_end = dbo.SubtractSecond( cui.dt_start ) AND pui.id_usage_cycle = cui.id_usage_cycle
select @do_credit = (CASE WHEN ISNULL(rei.id_arg_interval, 0) = 0 THEN 0
ELSE
CASE WHEN (rr.tx_type = 'Execute' AND rei.tx_status = 'Succeeded') THEN 1 ELSE 0 END
END)
from t_recevent re
left outer join t_recevent_inst rei on re.id_event = rei.id_event and rei.id_arg_interval = @prev_interval
left outer join t_recevent_run rr on rr.id_instance = rei.id_instance
where 1=1
and re.dt_deactivated is null
and re.tx_name = 'RecurringCharges'
and rr.id_run = (
select MAX(rr.id_run)
from t_recevent re
left outer join t_recevent_inst rei on re.id_event = rei.id_event and rei.id_arg_interval = @prev_interval
left outer join t_recevent_run rr on rr.id_instance = rei.id_instance
where 1=1
and re.dt_deactivated is null
and re.tx_name = 'RecurringCharges'
)

    IF @do_credit = 0
    BEGIN
        delete rcred
        from #tmp_rc_1 rcred
        inner join t_usage_interval ui on ui.id_interval = @cur_interval and rcred.c_BillingIntervalStart = ui.dt_start
    END;
	SELECT *,NEWID() AS idSourceSess INTO #tmp_rc FROM #tmp_rc_1;
--If no charges to meter, return immediately
    IF (NOT EXISTS (SELECT 1 FROM #tmp_rc)) RETURN;
 
   EXEC InsertChargesIntoSvcTables;
	  
	UPDATE rw
	SET c_BilledThroughDate = @currentDate
	FROM #recur_window_holder rw
	where rw.c__IsAllowGenChargeByTrigger = 1;

 END;