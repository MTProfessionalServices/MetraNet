CREATE OR REPLACE PROCEDURE MeterPayerChangeFromRecWind (currentDate date)
AS
  enabled VARCHAR2(10);
  BEGIN
  SELECT value INTO enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled = 'false') THEN RETURN; END IF;
    
  INSERT INTO TMP_RC(
        C_RCACTIONTYPE,
        C_RCINTERVALSTART,
        C_RCINTERVALEND,
        C_BILLINGINTERVALSTART,
        C_BILLINGINTERVALEND,
        C_RCINTERVALSUBSCRIPTIONSTART, 
        C_RCINTERVALSUBSCRIPTIONEND, 
        C_SUBSCRIPTIONSTART, 
        C_SUBSCRIPTIONEND, 
        C_ADVANCE, 
        C_PRORATEONSUBSCRIPTION, 
        C_PRORATEINSTANTLY, 
        C_UNITVALUESTART,
        C_UNITVALUEEND,
        C_UNITVALUE,
        c_RatingType, 
        C_PRORATEONUNSUBSCRIPTION,
        C_PRORATIONCYCLELENGTH,
        C__ACCOUNTID,
        C__PAYINGACCOUNT,
        C__PRICEABLEITEMINSTANCEID,
        C__PRICEABLEITEMTEMPLATEID,
        C__PRODUCTOFFERINGID,
        C_BILLEDRATEDATE,
        C__SUBSCRIPTIONID, 
        C__INTERVALID,
        ID_SOURCE_SESS,
        c__QuoteBatchId
  )
  SELECT 'InitialDebit'                                                                             AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.MTMaxOfThreeDates(BillRangeStart, pci.dt_start, rw.c_SubscriptionStart)                AS c_RCIntervalSubscriptionStart,
         dbo.MTMinOfThreeDates(BillRangeEnd, pci.dt_end, rw.c_SubscriptionEnd)                      AS c_RCIntervalSubscriptionEnd,
         rw.c_SubscriptionStart                                                                     AS c_SubscriptionStart,
         rw.c_SubscriptionEnd                                                                       AS c_SubscriptionEnd,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         '1'                                                                                        AS c_ProrateOnSubscription,
         '1'                                                                                        AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         rcr.n_rating_type                                                                          AS c_RatingType,
         '1'                                                                                        AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__PayingAccount_New                                                                    AS c__PayingAccount,         
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         dbo.MTMinOfTwoDates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_BilledRateDate,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         ui.id_interval                                                                             AS c__IntervalID,
         SYS_GUID()                                                                                 AS idSourceSess,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId
  FROM   t_usage_interval ui
         INNER JOIN TMP_NEW_RW_PAYER rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND rw.c_SubscriptionStart   < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__PayingAccount_New AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                                        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle 
                                        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
                                        ELSE NULL
                                       END
         INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
         INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend                            /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
              AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON rw.c_SubscriptionStart BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         currentDate BETWEEN ui.dt_start AND ui.dt_end /* TODO: Support Backdated subscriptions. Works only with current interval for now. */
         AND rw.c__IsAllowGenChargeByTrigger = 1 /* TODO: Remove this */

  UNION ALL

  SELECT 'InitialCredit'                                                                            AS c_RCActionType,
         pci.dt_start                                                                               AS c_RCIntervalStart,
         pci.dt_end                                                                                 AS c_RCIntervalEnd,
         ui.dt_start                                                                                AS c_BillingIntervalStart,
         ui.dt_end                                                                                  AS c_BillingIntervalEnd,
         dbo.MTMaxOfThreeDates(BillRangeStart, pci.dt_start, rw.c_SubscriptionStart)                AS c_RCIntervalSubscriptionStart,
         dbo.MTMinOfThreeDates(BillRangeEnd, pci.dt_end, rw.c_SubscriptionEnd)                      AS c_RCIntervalSubscriptionEnd,
         rw.c_SubscriptionStart                                                                     AS c_SubscriptionStart,
         rw.c_SubscriptionEnd                                                                       AS c_SubscriptionEnd,
         CASE WHEN rw.c_advance = 'Y' THEN '1' ELSE '0' END                                         AS c_Advance,
         '1'                                                                                        AS c_ProrateOnSubscription,
         '1'                                                                                        AS c_ProrateInstantly, /* NOTE: c_ProrateInstantly - No longer used */
         rw.c_UnitValueStart                                                                        AS c_UnitValueStart,
         rw.c_UnitValueEnd                                                                          AS c_UnitValueEnd,
         rw.c_UnitValue                                                                             AS c_UnitValue,
         rcr.n_rating_type                                                                          AS c_RatingType,
         '1'                                                                                        AS c_ProrateOnUnsubscription,
         CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END        AS c_ProrationCycleLength,
         rw.c__accountid                                                                            AS c__AccountID,
         rw.c__PayingAccount_Old                                                                    AS c__PayingAccount,         
         rw.c__priceableiteminstanceid                                                              AS c__PriceableItemInstanceID,
         rw.c__priceableitemtemplateid                                                              AS c__PriceableItemTemplateID,
         rw.c__productofferingid                                                                    AS c__ProductOfferingID,
         dbo.MTMinOfTwoDates(pci.dt_end, rw.c_SubscriptionEnd)                                      AS c_BilledRateDate,
         rw.c__subscriptionid                                                                       AS c__SubscriptionID,
         ui.id_interval                                                                             AS c__IntervalID,
         SYS_GUID()                                                                                 AS idSourceSess,
         sub.tx_quoting_batch                                                                       AS c__QuoteBatchId
  FROM   t_usage_interval ui
         INNER JOIN TMP_NEW_RW_PAYER rw
              ON  rw.c_payerstart          < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
              AND rw.c_membershipstart     < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
              AND rw.c_SubscriptionStart   < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
              AND rw.c_unitvaluestart      < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
         INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop         
         INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__PayingAccount_Old AND auc.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_usage_cycle ccl
              ON  ccl.id_usage_cycle = CASE 
                                        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                                        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle 
                                        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
                                        ELSE NULL
                                       END
         INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
         /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
         INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
              AND (
                      pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                          /* Check if rc start falls in this interval */
                      OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                          /* or check if the cycle end falls into this interval */
                      OR (pci.dt_start < ui.dt_start AND pci.dt_end > ui.dt_end)               /* or this interval could be in the middle of the cycle */
                  )
              AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend                            /* rc start goes to this payer */              
              AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
              AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
              AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
              AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
         INNER JOIN t_usage_interval currentui ON rw.c_SubscriptionStart BETWEEN currentui.dt_start AND currentui.dt_end
              AND currentui.id_usage_cycle = ui.id_usage_cycle
         INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
  WHERE
         currentDate BETWEEN ui.dt_start AND ui.dt_end /* TODO: Support Backdated subscriptions. Works only with current interval for now. */
         AND rw.c__IsAllowGenChargeByTrigger = 1; /* TODO: Remove this */

  /* Clean-up charges, that are out of BillRange */
  DELETE FROM TMP_RC WHERE c_RCIntervalSubscriptionEnd < c_RCIntervalSubscriptionStart;

  InsertChargesIntoSvcTables('InitialCredit','InitialDebit');

/* BilledThroughDates should be left the same after payer change. */
/* BUT we might need it on payer change to diff. cycle. */
/*
  MERGE
  INTO    TMP_NEW_RW_PAYER trw
  USING   (
            SELECT MAX(c_RCIntervalSubscriptionEnd) AS NewBilledThroughDate, c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
            FROM tmp_rc
            WHERE c_RCActionType = 'InitialDebit'
            GROUP BY c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
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
*/

  DELETE FROM TMP_RC;
END MeterPayerChangeFromRecWind;
