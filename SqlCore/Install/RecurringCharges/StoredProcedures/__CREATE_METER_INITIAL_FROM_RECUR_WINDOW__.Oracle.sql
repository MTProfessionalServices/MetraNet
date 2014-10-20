CREATE OR REPLACE
PROCEDURE MeterInitialFromRecurWindow (currentDate date) AS
  enabled varchar2(10);
BEGIN
  SELECT value INTO enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled = 'false') THEN RETURN; END IF;

  INSERT INTO tmp_rc
  SELECT
    'Initial'                                                                           AS c_RCActionType,
    pci.dt_start                                                                        AS c_RCIntervalStart,
    pci.dt_end                                                                          AS c_RCIntervalEnd,
    ui.dt_start                                                                         AS c_BillingIntervalStart,
    ui.dt_end                                                                           AS c_BillingIntervalEnd,
    dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart)                           AS c_RCIntervalSubscriptionStart,
    dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd)                               AS c_RCIntervalSubscriptionEnd,
    rw.c_SubscriptionStart                                                              AS c_SubscriptionStart,
    rw.c_SubscriptionEnd                                                                AS c_SubscriptionEnd,
    CASE WHEN rw.c_advance  ='Y' THEN '1' ELSE '0' END                                  AS c_Advance,
    CASE WHEN rcr.b_prorate_on_activate ='Y' THEN '1' ELSE '0' END                      AS c_ProrateOnSubscription,
    CASE WHEN rcr.b_prorate_instantly  ='Y' THEN '1' ELSE '0' END                       AS c_ProrateInstantly,
    rw.c_UnitValueStart                                                                 AS c_UnitValueStart,
    rw.c_UnitValueEnd                                                                   AS c_UnitValueEnd,
    rw.c_UnitValue                                                                      AS c_UnitValue,
    rcr.n_rating_type                                                                   AS c_RatingType,
    CASE WHEN rcr.b_prorate_on_deactivate  ='Y' THEN '1' ELSE '0' END                   AS c_ProrateOnUnsubscription,
    CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END AS c_ProrationCycleLength,
    rw.c__accountid                                                                     AS c__AccountID,
    rw.c__payingaccount                                                                 AS c__PayingAccount,
    rw.c__priceableiteminstanceid                                                       AS c__PriceableItemInstanceID,
    rw.c__priceableitemtemplateid                                                       AS c__PriceableItemTemplateID,
    rw.c__productofferingid                                                             AS c__ProductOfferingID,
    dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)                                AS c_BilledRateDate,
    rw.c__subscriptionid                                                                AS c__SubscriptionID,
    currentui.id_interval                                                               AS c__IntervalID,
    SYS_GUID()                                                                          AS id_source_sess,
    rw.c__QuoteBatchId                                                                  AS c__QuoteBatchId 
  FROM t_usage_interval ui
    INNER JOIN tmp_newrw rw
      ON  rw.c_payerstart           < ui.dt_end AND rw.c_payerend          > ui.dt_start /* next interval overlaps with payer */
      AND rw.c_cycleeffectivestart  < ui.dt_end AND rw.c_cycleeffectiveend > ui.dt_start /* next interval overlaps with cycle */
      AND rw.c_membershipstart      < ui.dt_end AND rw.c_membershipend     > ui.dt_start /* next interval overlaps with membership */
      AND rw.c_SubscriptionStart    < ui.dt_end AND rw.c_SubscriptionEnd   > ui.dt_start
      AND rw.c_unitvaluestart       < ui.dt_end AND rw.c_unitvalueend      > ui.dt_start /* next interval overlaps with UDRC */
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount AND auc.id_usage_cycle = ui.id_usage_cycle
    INNER JOIN t_usage_cycle ccl
      ON  ccl.id_usage_cycle = CASE 
                            WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
                            WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN ui.id_usage_cycle 
                            WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
                            ELSE NULL
                        END
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    INNER JOIN t_pc_interval pci ON pci.id_cycle = ccl.id_usage_cycle
      AND (
            pci.dt_start  BETWEEN ui.dt_start AND ui.dt_end                               /* Check if rc start falls in this interval */
            OR pci.dt_end BETWEEN ui.dt_start AND ui.dt_end                               /* or check if the cycle end falls into this interval */
            OR (pci.dt_start < ui.dt_start and pci.dt_end > ui.dt_end)                    /* or this interval could be in the middle of the cycle */
          )
      AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend                            /* rc start goes to this payer */
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      AND rw.c_cycleeffectivestart < pci.dt_end AND rw.c_cycleeffectiveend > pci.dt_start /* rc overlaps with this cycle */
      AND rw.c_SubscriptionStart   < pci.dt_end AND rw.c_subscriptionend   > pci.dt_start /* rc overlaps with this subscription */
    INNER JOIN t_usage_interval currentui ON rw.c_SubscriptionStart BETWEEN currentui.dt_start AND currentui.dt_end
      AND currentui.id_usage_cycle = ui.id_usage_cycle
  WHERE
    /*Only meter new subscriptions as initial -- so select only items that have at most one entry in t_sub_history*/
    NOT EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.c__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /*Also no old unit values*/
    AND NOT EXISTS (SELECT 1 FROM t_recur_value trv WHERE trv.id_sub = rw.c__SubscriptionID AND trv.tt_end < dbo.MTMaxDate())
    /* Don't meter in the current interval for initial*/
    AND ui.dt_start <= rw.c_SubscriptionStart
    AND ui.dt_start < currentDate
    AND rw.c__IsAllowGenChargeByTrigger = 1;

  MERGE
  INTO    tmp_newrw trw
  USING   (
            SELECT MAX(c_RCIntervalSubscriptionEnd) AS NewBilledThroughDate, c__AccountID, c__ProductOfferingID, c__PriceableItemInstanceID, c__PriceableItemTemplateID, c_RCActionType, c__SubscriptionID
            FROM tmp_rc
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

  insertChargesIntoSvcTables('Initial','Initial');

END MeterInitialFromRecurWindow;