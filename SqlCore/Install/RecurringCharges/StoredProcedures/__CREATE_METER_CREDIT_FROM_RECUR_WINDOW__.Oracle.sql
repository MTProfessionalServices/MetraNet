create or replace
PROCEDURE METERCreditFROMRECURWINDOW (currentDate DATE) AS
    enabled      VARCHAR2(10);
    v_newSubStart DATE;
    v_newSubEnd   DATE;
    v_curSubStart DATE;
    v_curSubEnd   DATE;
BEGIN
  SELECT value into enabled FROM t_db_values WHERE parameter = N'InstantRc';
  IF (enabled like 'false')then return;  end if;

  /* [TODO]: It is partially ported approach from MSSQL. Port else from MSSQL due to priority */
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

   INSERT INTO tmp_rc
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
    /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly 
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMinOfTwoDates(new_sub.vt_end, current_sub.vt_end)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
    ,null as id_source_sess
    FROM tmp_newrw  rw
   INNER JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci
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
	  and pci.dt_start < currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
      INNER JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = 
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
           ELSE NULL END 
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
   where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  We'll deal with this 
    * elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	AND rw.c__IsAllowGenChargeByTrigger = 1
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
    /*Booleans are, stupidly enough, stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,dbo.MTMaxOfTwoDates(new_sub.vt_start, current_sub.vt_start)  AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
    ,null as id_source_sess
    FROM tmp_newrw  rw
    INNER JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount 
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci
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
	  and pci.dt_start < currentDate /* Don't go into the future*/
      AND rw.c_unitvaluestart      < pci.dt_end AND rw.c_unitvalueend      > pci.dt_start /* rc overlaps with this UDRC */
      AND rw.c_membershipstart     < pci.dt_end AND rw.c_membershipend     > pci.dt_start /* rc overlaps with this membership */
          INNER JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
            and paymentInterval.id_usage_cycle = pci.id_cycle
    INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = 
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
           ELSE NULL END 
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
    inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
  where 1=1
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  
    * We'll deal with this elsewhere.
    */
    AND NOT (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end)
	AND rw.c__IsAllowGenChargeByTrigger = 1
    
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
    /*Booleans are stored as Y/N in one table, but 0/1 in another table.  Convert them.*/
    ,case when rw.c_advance  ='Y' then '1' else '0' end          AS c_Advance
    ,case when rcr.b_prorate_on_activate ='Y' then '1' else '0' end         AS c_ProrateOnSubscription
    ,case when rcr.b_prorate_instantly  ='Y' then '1' else '0' end          AS c_ProrateInstantly 
    ,rw.c_UnitValueStart AS c_UnitValueStart
    ,rw.c_UnitValueEnd AS c_UnitValueEnd
    ,rw.c_UnitValue AS c_UnitValue
    ,rcr.n_rating_type AS c_RatingType
    ,case when rcr.b_prorate_on_deactivate  ='Y' then '1' else '0' end          AS c_ProrateOnUnsubscription
    ,CASE WHEN rcr.b_fixed_proration_length = 'Y' THEN fxd.n_proration_length ELSE 0 END          AS c_ProrationCycleLength
    ,rw.c__accountid AS c__AccountID
    ,rw.c__payingaccount      AS c__PayingAccount
    ,rw.c__priceableiteminstanceid      AS c__PriceableItemInstanceID
    ,rw.c__priceableitemtemplateid      AS c__PriceableItemTemplateID
    ,rw.c__productofferingid      AS c__ProductOfferingID
    ,new_sub.vt_start AS c_BilledRateDate
    ,rw.c__subscriptionid      AS c__SubscriptionID
    ,currentui.id_interval AS c__IntervalID
    ,null as id_source_sess
    FROM tmp_newrw  rw
   INNER JOIN t_sub_history new_sub on new_sub.id_acc = rw.c__AccountID and new_sub.id_sub = rw.c__SubscriptionID AND new_sub.tt_end = dbo.MTMaxDate()
    INNER JOIN t_sub_history current_sub on current_sub.id_acc = rw.c__AccountID and current_sub.id_sub = rw.c__SubscriptionID
      AND current_sub.tt_end  = dbo.SubtractSecond(new_sub.tt_start)
    INNER JOIN t_recur rcr ON rw.c__priceableiteminstanceid = rcr.id_prop
    JOIN t_acc_usage_cycle auc ON auc.id_acc = rw.c__payingaccount
    /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
    INNER JOIN t_pc_interval pci
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
      INNER JOIN t_usage_interval paymentInterval ON pci.dt_start between paymentInterval.dt_start AND paymentInterval.dt_end
        and paymentInterval.id_usage_cycle = pci.id_cycle
      INNER JOIN t_usage_cycle ccl ON ccl.id_usage_cycle = 
      CASE WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'BCR Constrained' THEN auc.id_usage_cycle 
           WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(auc.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type) 
           ELSE NULL END 
    INNER JOIN t_usage_cycle_type fxd ON fxd.id_cycle_type = ccl.id_cycle_type
	inner join t_usage_interval currentui on currentDate between currentui.dt_start and currentui.dt_end and currentui.id_usage_cycle = paymentInterval.id_usage_cycle
 where 1=1
    and (rcr.b_prorate_on_deactivate='Y' or pci.dt_start > dbo.mtendofday(rw.c_SubscriptionEnd))
    AND EXISTS (SELECT 1 FROM t_sub_history tsh WHERE tsh.id_sub = rw.C__SubscriptionID AND tsh.id_acc = rw.c__AccountID AND tsh.tt_end < dbo.MTMaxDate())
    /* We have one exceptional case: (a) an arrears charge, (b) old sub end date was after the end of the pci, (c) new sub end date is inside the pci.  We'll deal with this 
    * elsewhere.
    */
    AND (rcr.b_advance = 'N' AND current_sub.vt_end > pci.dt_end AND new_sub.vt_end < pci.dt_end) 
	AND rw.c__IsAllowGenChargeByTrigger = 1;
	
    update tmp_rc set id_source_sess = sys_guid();
	
    insertChargesIntoSvcTables('%Credit','%Debit');
	
	UPDATE tmp_newrw rw
	SET c_BilledThroughDate = currentDate	
	where rw.c__IsAllowGenChargeByTrigger = 1;

	
/*We can get an no data exception if there are no previous subscriptions; just return in this case.*/   
   EXCEPTION WHEN NO_DATA_FOUND THEN return;
end METERCreditFROMRECURWINDOW;