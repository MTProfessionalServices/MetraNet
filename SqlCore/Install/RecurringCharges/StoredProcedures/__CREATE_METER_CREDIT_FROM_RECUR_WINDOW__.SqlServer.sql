CREATE PROCEDURE [dbo].[MeterCreditFromRecurWindow]
      @currentDate dateTime
	  AS
    BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
	
    
	IF ((SELECT value FROM t_db_values WHERE parameter = N'InstantRc') = 'false') return;
	
SELECT DISTINCT
/* First, credit or debit the difference in the ending of the subscription.  If the new one is later, this will be a debit, otherwise a credit.
* There's a weird exception when this is (a) an arrears charge, (b) the old subscription end was after the pci end date, 
* and (c) the new sub end is inside the pci end date.*/
    CASE WHEN new_sub.vt_end > current_sub.vt_end THEN 'Debit' ELSE 'Credit' END AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)) AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, dbo.MTMaxOfTwoDates(new_sub.vt_end, current_sub.vt_end)) AS c_RCIntervalSubscriptionEnd
    ,dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)   AS c_SubscriptionStart
    ,dbo.MTMaxOfTwoDates(new_sub.vt_end, current_sub.vt_end) AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly -- NOTE: No longer used
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
	INTO #tmp_rc_1 
 FROM #recur_window_holder rw
    INNER LOOP JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER LOOP JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(pci_cycle_dt_idx))
      ON pci.id_cycle = 
      CASE 
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
        ELSE NULL END
      AND dbo.MTMinOfTwoDates(pci.dt_end, current_sub.vt_end)!= dbo.MTMinOfTwoDates(pci.dt_end, new_sub.vt_end)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end) 
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
	  AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
	  AND pci.dt_start < @currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      INNER LOOP JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = 
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
           ELSE NULL END 
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
   where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
	/* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  We'll deal with this 
    * elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
 UNION
 SELECT DISTINCT
/* Now, credit or debit the difference in the start of the subscription.  If the new one is earlier, this will be a debit, otherwise a credit*/
    CASE WHEN new_sub.vt_start < current_sub.vt_start THEN 'InitialDebit' ELSE 'InitialCredit' END AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, dbo.MTMinOfTwoDates(new_sub.vt_start, current_sub.vt_start)) AS c_RCIntervalSubscriptionStart
    ,dbo.mtminoftwodates(pci.dt_end, dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start)) AS c_RCIntervalSubscriptionEnd
    ,dbo.MTMinOfTwoDates(new_sub.vt_start, current_sub.vt_start)   AS c_SubscriptionStart
    ,dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start) AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly -- NOTE: No longer used
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
  FROM #recur_window_holder rw
    INNER LOOP JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER LOOP JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID 
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(pci_cycle_dt_idx))
      ON pci.id_cycle = 
      CASE 
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
        ELSE NULL END
      /*Check where the intersection of the pci interval and the subscription is different between the new & the old subs.*/
      AND dbo.MTMaxOfTwoDates(pci.dt_start, current_sub.vt_start) != dbo.MTMaxOfTwoDates(pci.dt_start, new_sub.vt_start)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end) 
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
      AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
	  AND pci.dt_start < @currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
          INNER LOOP JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
            and paymentInterval.id_usage_cycle = pci.id_cycle
    INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = 
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
           ELSE NULL END 
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
 where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  
    * We'll deal with this elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
    
 UNION
  SELECT DISTINCT
/* Now, handle the exceptional case above, where (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.
* In this case, issue a debit from the pci start to the subscription end immediately. */
    'Debit' AS c_RCActionType
    ,pci.dt_start      AS c_RCIntervalStart
    ,pci.dt_end      AS c_RCIntervalEnd
    ,paymentInterval.dt_start      AS c_BillingIntervalStart
    ,paymentInterval.dt_end          AS c_BillingIntervalEnd
    ,dbo.mtmaxoftwodates(pci.dt_start, new_sub.vt_start) AS c_RCIntervalSubscriptionStart
    ,new_sub.vt_end AS c_RCIntervalSubscriptionEnd
    ,new_sub.vt_start  AS c_SubscriptionStart
    ,new_sub.vt_end AS c_SubscriptionEnd
    --Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly -- NOTE: No longer used
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,new_sub.vt_start AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
 FROM #recur_window_holder rw
    INNER LOOP JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER LOOP JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER LOOP JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    INNER LOOP JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__AccountID
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER LOOP JOIN t_pc_interval pci WITH(INDEX(pci_cycle_dt_idx))
      ON pci.id_cycle = 
      CASE 
        WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
        WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
        ELSE NULL END
      AND dbo.MTMinOfTwoDates(pci.dt_end, current_sub.vt_end)!= dbo.MTMinOfTwoDates(pci.dt_end, new_sub.vt_end)
      AND pci.dt_start < dbo.MTMaxOfTwoDates(current_sub.vt_end, new_sub.vt_end) 
      AND pci.dt_end > dbo.MTMinOfTwoDates(current_sub.vt_start, new_sub.vt_start)
	  AND pci.dt_end BETWEEN rw.c_payerstart  AND rw.c_payerend                         /* rc start goes to this payer */
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      INNER LOOP JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER LOOP JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = 
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
           ELSE NULL END 
    INNER LOOP JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on @currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
 where 1=1
    and (rcr.b_prorate_on_deactivate='Y' or pci.dt_start > dbo.mtendofday(rw.c_SubscriptionEnd))
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* Deal with the above-mentioned exceptional case here.
    */
    AND (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end) ;
	
	
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
	  
UPDATE #recur_window_holder SET c_BilledThroughDate = dbo.metratime(1,'RC') ;

 end; 

