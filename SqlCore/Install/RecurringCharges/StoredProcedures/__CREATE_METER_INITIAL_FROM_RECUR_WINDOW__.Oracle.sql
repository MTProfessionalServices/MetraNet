CREATE OR REPLACE
PROCEDURE METERinitialFROMRECURWINDOW (currentDate date) AS

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
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS  c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMinOfTwoDates(pci.dt_end,rw.c_SubscriptionEnd)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID 
    ,SYS_GUID () as id_source_sess
    ,sub.tx_quoting_batch as c__QuoteBatchId
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
  INNER JOIN t_sub sub on sub.id_sub = rw.c__SubscriptionID
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
