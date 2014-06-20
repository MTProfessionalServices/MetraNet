
CREATE OR REPLACE
PROCEDURE MeterUdrcFromRecurWindow (currentDate date) AS
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
    JOIN t_acc_usage_cycle auc on auc.id_acc = rw_new.c__payingaccount and auc.id_usage_cycle = ccl.id_usage_cycle
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

 