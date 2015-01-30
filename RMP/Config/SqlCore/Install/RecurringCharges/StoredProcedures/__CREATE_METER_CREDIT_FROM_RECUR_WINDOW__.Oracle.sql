CREATE OR REPLACE PROCEDURE MeterCreditFromRecurWindow (currentDate DATE)
AS
    enabled       varchar2(10);
    v_newSubStart DATE;
    v_newSubEnd   DATE;
    v_curSubStart DATE;
    v_curSubEnd   DATE;  
    /* Borders of updated Sub.End range will stand for internal v_subscriptionStart and v_subscriptionEnd to charge this range. */
    v_subscriptionStart        DATE;
    v_subscriptionEnd          DATE;
    v_rcAction                 VARCHAR2(20);
    v_isEndDateUpdated         CHAR(1 BYTE) := '0';
    /* Borders of updated Sub.Start range will stand for internal v_subscriptionStart2 and v_subscriptionEnd2 to charge this range. */
    v_subscriptionStart2       DATE;
    v_subscriptionEnd2         DATE;
    v_rcAction2                VARCHAR2(20);
    v_isStartDateUpdated       CHAR(1 BYTE) := '0';
    /* Values for full recharge of Arrears if End date update crosses EOP border */
    v_subscriptionStart3       DATE;
    v_subscriptionEnd3         DATE;
    v_rcAction3                VARCHAR2(20);
    
    
BEGIN
  SELECT value INTO enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled LIKE 'false') THEN RETURN; END IF;

  SELECT dbo.MTMinDate(), dbo.MTMinDate() INTO v_subscriptionStart, v_subscriptionEnd FROM dual;

  /* Assuming only 1 subscription can be changed at a time */
  BEGIN  
    SELECT new_sub.vt_start, new_sub.vt_end, current_sub.vt_start, current_sub.vt_end
    INTO v_newSubStart,    v_newSubEnd,    v_curSubStart,        v_curSubEnd
    FROM TMP_NEWRW rw
        INNER JOIN t_sub_history new_sub ON new_sub.id_acc = rw.c__AccountID
            AND new_sub.id_sub = rw.c__SubscriptionID
            AND new_sub.tt_end = dbo.MTMaxDate()
        INNER JOIN t_sub_history current_sub ON current_sub.id_acc = rw.c__AccountID
            AND current_sub.id_sub = rw.c__SubscriptionID
            AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start)
    /* Work with RC only. Exclude UDRC. */
    WHERE rw.c_UnitValue IS NULL AND ROWNUM <= 1; /* Select only 1 PI*/
  EXCEPTION
    /* It is a new subscription or UDRC - nothing to recharge */
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  IF (v_newSubEnd <> v_curSubEnd) THEN
      /* TODO: Run only 1-st query if condition is true */
      v_isEndDateUpdated := '1';

      SELECT dbo.MTMinOfTwoDates(v_newSubEnd, v_curSubEnd),
             dbo.MTMaxOfTwoDates(v_newSubEnd, v_curSubEnd),
             CASE 
                  WHEN v_newSubEnd > v_curSubEnd THEN 
                       'Debit'
                  ELSE 'Credit'
             END
      INTO v_subscriptionStart, v_subscriptionEnd, v_rcAction FROM DUAL;
      /* Sub. start date has 23:59:59 time. We need next day and 00:00:00 time for the start date */
      SELECT dbo.AddSecond(v_subscriptionStart) INTO v_subscriptionStart FROM DUAL;

      IF (v_newSubEnd > v_curSubEnd) THEN
          v_subscriptionStart3 := v_curSubStart;
          v_subscriptionEnd3   := v_curSubEnd;
          v_rcAction3          := 'Credit';
      END IF;

      IF (v_newSubEnd < v_curSubEnd) THEN
          v_subscriptionStart3 := v_newSubStart;
          v_subscriptionEnd3   := v_newSubEnd;
          v_rcAction3          := 'Debit';
      END IF;
  END IF;

  IF (v_newSubStart <> v_curSubStart) THEN
      /* TODO: Run only 2-nd query if condition is true */
      v_isStartDateUpdated := '1';

      SELECT dbo.MTMinOfTwoDates(v_newSubStart, v_curSubStart),
             dbo.MTMaxOfTwoDates(v_newSubStart, v_curSubStart),
             CASE 
                  WHEN v_newSubStart < v_curSubStart THEN 
                       'InitialDebit'
                  ELSE 'InitialCredit'
             END
      INTO v_subscriptionStart2, v_subscriptionEnd2, v_rcAction2 FROM DUAL;
      /* Sub. end date has 00:00:00 time. We need previous day and 23:59:59 time for the end date */
      SELECT dbo.SubtractSecond(v_subscriptionEnd2) INTO v_subscriptionEnd2 FROM DUAL;  
  END IF;

  INSERT INTO tmp_rc_1
  SELECT
         /* First, credit or debit the difference in the ending of the subscription.  If the new one is later, this will be a debit, otherwise a credit.
         * TODO: Remove this comment:"There's a weird exception when this is (a) an arrears charge, (b) the old subscription end was after the pci end date, and (c) the new sub end is inside the pci end date." */
         v_rcAction                                                                                 AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, v_subscriptionStart)                                     AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, v_subscriptionEnd)                                         AS c_RCIntervalSubscriptionEnd,
         v_subscriptionStart                                                                        AS c_SubscriptionStart,
         v_subscriptionEnd                                                                          AS c_SubscriptionEnd,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         dbo.MTMinOfTwoDates(pci.dt_end, v_subscriptionStart)                                       AS c_BilledRateDate,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         currentui.id_interval                                                                      AS c__IntervalID,
         SYS_GUID()                                                                                 AS id_source_sess,
         null                                                                                       AS c__QuoteBatchId,
         0                                                                                          AS IsArrearsRecalculation
  FROM   t_usage_interval ui
         INNER JOIN TMP_NEWRW rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              /* AddSecond() relates to CORE-8443*/
              AND v_subscriptionStart <= dbo.AddSecond(ui.dt_end) AND v_subscriptionEnd > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, v_subscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND v_subscriptionStart      < pci.dt_end AND v_subscriptionEnd      > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
         ui.dt_start < currentDate
         /* We're working only with Bill. interval where subscription starts, except future one */
         AND v_newSubStart BETWEEN ui.dt_start AND ui.dt_end
         AND v_isEndDateUpdated = '1'
         AND NOT (rw.c_advance = 'N' AND v_newSubEnd > ui.dt_end)
         /* Skip if this is an Arrears AND end date update crosses the EOP border (this case will be handled below) */
         AND NOT (rw.c_advance = 'N' AND v_subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < v_subscriptionEnd)

  UNION ALL

  SELECT
         /* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
         v_rcAction2                                                                                AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, v_subscriptionStart2)                                    AS c_RCIntervalSubscriptionStart,         
         /* If new Subscription Start somewhere in future, after EOP - always use End of RC cycle */
         CASE
              WHEN ui.dt_end <= v_subscriptionEnd2 THEN pci.dt_end
              ELSE dbo.mtminoftwodates(pci.dt_end, v_subscriptionEnd2)
         END                                                                                        AS c_RCIntervalSubscriptionEnd,
         v_subscriptionStart2                                                                       AS c_SubscriptionStart,
         v_subscriptionEnd2                                                                         AS c_SubscriptionEnd,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         dbo.MTMinOfTwoDates(pci.dt_end, v_subscriptionStart2)                                      AS c_BilledRateDate,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         currentui.id_interval                                                                      AS c__IntervalID,
         SYS_GUID()                                                                                 AS id_source_sess,
         null                                                                                       AS c__QuoteBatchId,
         0                                                                                          AS IsArrearsRecalculation
  FROM   t_usage_interval ui
         INNER JOIN TMP_NEWRW rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND v_subscriptionStart2     < ui.dt_end AND v_subscriptionEnd2     > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, v_subscriptionStart2, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND v_subscriptionStart2     < pci.dt_end AND v_subscriptionEnd2     > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
         ui.dt_start < currentDate
         AND v_isStartDateUpdated = '1'
         AND NOT (rw.c_advance = 'N' AND v_newSubEnd > ui.dt_end)
         /* Skip if this is an Arrears AND end date update crosses the EOP border (this case will be handled below) */
         AND NOT (rw.c_advance = 'N' AND v_subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < v_subscriptionEnd)

  UNION ALL

  SELECT
         /* Handle the case if this is an Arrears AND end date update crosses the EOP border */
         v_rcAction3                                                                                AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.mtmaxoftwodates(pci.dt_start, v_subscriptionStart3)                                    AS c_RCIntervalSubscriptionStart,
         dbo.mtminoftwodates(pci.dt_end, v_subscriptionEnd3)                                        AS c_RCIntervalSubscriptionEnd,
         v_subscriptionStart3                                                                       AS c_SubscriptionStart,
         v_subscriptionEnd3                                                                         AS c_SubscriptionEnd,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         CASE WHEN rcr.b_prorate_on_activate = 'Y' THEN '1' ELSE '0' END                            AS c_ProrateOnSubscription,
         CASE WHEN rcr.b_prorate_instantly = 'Y' THEN '1' ELSE '0' END                              AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         rcr.n_rating_type                                                                          AS c_RatingType,
         CASE WHEN rcr.b_prorate_on_deactivate = 'Y' THEN '1' ELSE '0' END                          AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__payingaccount                                                                        AS c__PayingAccount,
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         dbo.MTMinOfTwoDates(pci.dt_end, v_subscriptionStart3)                                      AS c_BilledRateDate,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         currentui.id_interval                                                                      AS c__IntervalID,
         SYS_GUID()                                                                                 AS id_source_sess,
         null                                                                                       AS c__QuoteBatchId,
         1                                                                                          AS IsArrearsRecalculation
  FROM   t_usage_interval ui
         INNER JOIN TMP_NEWRW rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND v_subscriptionStart3     < ui.dt_end AND v_subscriptionEnd3     > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */  
         INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                            WHEN rcr.tx_cycle_mode = 'Fixed'           THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR'            THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, v_subscriptionStart3, rcr.id_cycle_type)
                                            ELSE NULL
                                       END
         INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN    rw.c_payerstart AND rw.c_payerend                         /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              /* rw.c_cycleeffectivestart EQUAL TO v_subscriptionStart , rw.c_cycleeffectiveend EQUAL TO v_subscriptionEnd */
              AND v_subscriptionStart3      < pci.dt_end AND v_subscriptionEnd3      > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON currentDate BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
         ui.dt_start < currentDate
         /* Handle the case if this is an Arrears AND end date update crosses the EOP border */
         AND rw.c_advance = 'N' AND v_subscriptionStart <= dbo.AddSecond(ui.dt_end) AND ui.dt_end < v_subscriptionEnd;

  /* Remove extra charges for RCs with No Proration (CORE-6789) */
  IF (v_isEndDateUpdated = 1) THEN
    /* PIs, that starts outside of End Date Update range, should not be handled here */
    DELETE FROM tmp_rc_1 WHERE c_ProrateOnUnsubscription = '0'
        AND c_RCIntervalStart < v_subscriptionStart
        AND IsArrearsRecalculation = 0;

    /* Turn On "Prorate On Subscription" if this is the 1-st RC Cycle */
    UPDATE tmp_rc_1
    SET c_ProrateOnSubscription = '1'
    WHERE c_ProrateOnUnsubscription = '1' AND v_newSubStart BETWEEN c_RCIntervalStart AND c_RCIntervalEnd;
  END IF;
  IF (v_isStartDateUpdated = 1) THEN
    /* PIs, that ends outside of Start Date Update range, should not be handled here */
    DELETE FROM tmp_rc_1 WHERE c_ProrateOnSubscription = '0' AND c_RCIntervalEnd > v_subscriptionEnd2
      AND v_subscriptionEnd2 < c_BillingIntervalEnd
      AND IsArrearsRecalculation = 0; /* If start date was updated To or From "after EOP date" all PIs should be charged. Don't delete anything. */
  END IF;

  INSERT INTO tmp_unbilledPIs
  SELECT c__SubscriptionID, c__PriceableItemInstanceID, c__PriceableItemTemplateID         
  FROM   tmp_rc_1
  WHERE
         c_Advance = 0 AND c_BillingIntervalEnd BETWEEN v_curSubEnd AND v_newSubEnd
  UNION ALL
  SELECT c__SubscriptionID, c__PriceableItemInstanceID, c__PriceableItemTemplateID
  FROM   tmp_rc_1
  WHERE
         c_Advance = 1 AND c_BillingIntervalEnd BETWEEN v_curSubStart AND v_newSubStart;

  INSERT INTO tmp_rc
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
         id_source_sess,
         c__QuoteBatchId
  FROM tmp_rc_1;

  MERGE
  INTO    tmp_newrw trw
  USING   (
            SELECT MAX(dbo.mtminoftwodates(c_RCIntervalEnd, v_newSubEnd)) AS NewBilledThroughDate,
                   c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c__SubscriptionID
            FROM tmp_rc
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

  UPDATE tmp_newrw rw
  SET    c_BilledThroughDate = dbo.mtmindate()
  WHERE
         rw.c__SubscriptionID IN (SELECT c__SubscriptionID FROM tmp_unbilledPIs)
         AND rw.c__PriceableItemInstanceID IN (SELECT c__PriceableItemInstanceID FROM tmp_unbilledPIs)
         AND rw.c__IsAllowGenChargeByTrigger = 1;
  
  insertChargesIntoSvcTables('%Credit','%Debit');

  /*We can get an no data exception if there are no previous subscriptions; just return in this case.*/   
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
end MeterCreditFromRecurWindow;