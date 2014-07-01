
 create trigger trig_update_t_recur_window_with_recur_value
 ON t_recur_value for INSERT, UPDATE, delete
 as 
BEGIN
declare @startDate datetime;
select @startDate = tt_start from inserted
  --Get the values which are new (the problem is that we delete and
  --     re-insert EVERY unit value for this subscription, even the
  --     ones that haven't changed.
  select * into #tmp_new_units 
  FROM inserted rdnew 
  --WHERE NOT EXISTS 
  -- (SELECT * FROM inserted rdold where
   --  rdnew.n_value = rdold.n_value
   --  AND rdnew.vt_start = rdold.vt_start
   --  AND rdnew.vt_end = rdold.vt_end
	 -- and rdnew.id_prop = rdold.id_prop
    -- and rdnew.id_sub = rdold.id_sub
    -- AND rdold.tt_end < dbo.MTMaxDate()) /* FIXME: this should join to new tt_start + 1 second */
     
  SELECT 
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate) AS c__IsAllowGenChargeByTrigger
      INTO #recur_window_holder
      FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_new_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
        --AND rv.tt_end = dbo.MTMaxDate() 
       -- AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
       -- AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE 1=1
      AND sub.id_group IS NULL
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

UNION ALL
SELECT
       gsm.vt_start AS c_CycleEffectiveDate
      ,gsm.vt_start AS c_CycleEffectiveStart
      ,gsm.vt_end AS c_CycleEffectiveEnd
      ,gsm.vt_start          AS c_SubscriptionStart
      ,gsm.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, gsm.vt_end, @startDate) AS c__IsAllowGenChargeByTrigger
      FROM t_gsubmember gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc 
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start 
        AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_new_units rv ON rv.id_prop = rcr.id_prop 
        AND sub.id_sub = rv.id_sub 
        AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start 
        AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE 
      	rcr.b_charge_per_participant = 'Y'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
UNION ALL
SELECT
       sub.vt_start AS c_CycleEffectiveDate
      ,sub.vt_start AS c_CycleEffectiveStart
      ,sub.vt_end AS c_CycleEffectiveEnd
      ,sub.vt_start          AS c_SubscriptionStart
      ,sub.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , dbo.mtmindate() as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , grm.vt_start AS c_MembershipStart
      , grm.vt_end AS c_MembershipEnd
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate) AS c__IsAllowGenChargeByTrigger
      FROM t_gsub_recur_map grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_new_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
      AND rv.tt_end = dbo.MTMaxDate() 
      AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
      AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
      	grm.tt_end = dbo.mtmaxdate()
      	AND rcr.b_charge_per_participant = 'N'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
;
--Get the old vt_start and vt_end for recur values that have changed
select distinct trw.c__SubscriptionID AS id_sub, 
    trw.c_UnitValue as n_value,
   IsNull(trw.c_UnitValueStart, dbo.mtmindate()) AS vt_start, 
    IsNull(trw.c_UnitValueEnd, dbo.mtmaxdate()) AS vt_end,
    trv.tt_end
  into  #tmp_old_units 
  FROM
     t_recur_window trw 
     JOIN #recur_window_holder rwh ON
  trw.c__SubscriptionID = rwh.c__SubscriptionID
  and trw.c__PriceableItemTemplateId = rwh.c__PriceableItemTemplateId
  and trw.c__PriceableItemInstanceId = rwh.c__PriceableItemInstanceId
  AND trw.c_UnitValue = rwh.c_UnitValue
  --A possibly clumsy attempt at an XOR.  We want one of the start or end dates
  --  to match the old start/end, but not the other one.
 -- AND (trw.c_UnitValueStart = rwh.c_UnitValueStart
  --or trw.c_UnitValueEnd = rwh.c_UnitValueEnd)
  --AND (trw.c_UnitValueStart != rwh.c_UnitValueStart
  --or trw.c_UnitValueEnd != rwh.c_UnitValueEnd)
  JOIN t_recur_value trv 
    ON rwh.c__SubscriptionID = trv.id_sub
    and trv.id_prop = rwh.c__PriceableItemInstanceId
    AND trw.c_UnitValueStart = trv.vt_start
    and trw.c_UnitValueEnd = trv.vt_end
    AND trv.tt_end < dbo.MTMaxDate() ; /* FIXME: this should join to new tt_start + 1 second */
    
--The recur_window_holder has too many entries, because of the way we drop all entries for a sub
--  then re-insert them.  So, drop all the entries that already exist in t_recur_window
DELETE FROM #recur_window_holder WHERE EXISTS
(SELECT 1 FROM t_recur_window trw  JOIN t_recur_value trv 
    ON trw.c__SubscriptionID = trv.id_sub
    AND trw.c__PriceableItemInstanceId = trv.id_prop
    AND trw.c_UnitValueStart = trv.vt_start
    AND trw.c_UnitValueEnd = trv.vt_end
    AND trv.tt_end = dbo.MTMaxDate()
WHERE
   trw.c__SubscriptionID = #recur_window_holder.c__SubscriptionID
   AND trw.c_UnitValue = #recur_window_holder.c_UnitValue
   AND trw.c_UnitValueStart = #recur_window_holder.c_UnitValueStart
   AND trw.c_UnitValueEnd = #recur_window_holder.c_UnitValueEnd
   and trw.c__PriceableItemInstanceID = #recur_window_holder.c__PriceableItemInstanceID
   and trw.c__PriceableItemTemplateID = #recur_window_holder.c__PriceableItemTemplateID
)
      
      EXEC MeterInitialFromRecurWindow @currentDate = @startDate;
	  EXEC MeterUdrcFromRecurWindow @currentDate = @startDate;

--Delete old values from t_recur_window
delete from t_recur_window WHERE EXISTS 
  (SELECT 1 FROM t_recur_value oldunits join t_pl_map plm on oldunits.id_sub = plm.id_sub
  and oldunits.id_prop = plm.id_pi_instance
     where 
  t_recur_window.c__SubscriptionID = oldunits.id_sub
  AND t_recur_window.c_UnitValueStart = oldunits.vt_start 
  AND t_recur_window.c_UnitValueEnd = oldunits.vt_end
  and plm.id_pi_instance = t_recur_window.c__PriceableItemInstanceID
  and plm.id_pi_template = t_recur_window.c__PriceableItemTemplateID  
  ); 
                  
	INSERT INTO t_recur_window    
	SELECT DISTINCT c_CycleEffectiveDate,
	c_CycleEffectiveStart,
	c_CycleEffectiveEnd,
	c_SubscriptionStart,
	c_SubscriptionEnd,
	c_Advance,
	c__AccountID,
	c__PayingAccount,
	c__PriceableItemInstanceID,
	c__PriceableItemTemplateID,
	c__ProductOfferingID,
	c_PayerStart,
	c_PayerEnd,
	c__SubscriptionID,
	c_UnitValueStart,
	c_UnitValueEnd,
	c_UnitValue,
	c_BilledThroughDate,
	c_LastIdRun,
	c_MembershipStart,
	c_MembershipEnd
	FROM #recur_window_holder;


UPDATE t_recur_window
SET c_CycleEffectiveEnd = 
 (
  SELECT MIN(IsNull(c_CycleEffectiveDate,c_SubscriptionEnd)) FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId AND t_recur_window.c_PayerStart = w2.c_PayerStart 
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd 
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart 
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd 
    AND t_recur_window.c_membershipstart = w2.c_membershipstart 
    AND t_recur_window.c_membershipend = w2.c_membershipend 
    AND t_recur_window.c__accountid = w2.c__accountid 
    AND t_recur_window.c__payingaccount = w2.c__payingaccount 
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
)
WHERE EXISTS 
(SELECT 1 FROM t_recur_window w2
    WHERE w2.c__SubscriptionId = t_recur_window.c__SubscriptionId 
    AND t_recur_window.c_PayerStart = w2.c_PayerStart 
    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd 
    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart 
    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd 
    AND t_recur_window.c_membershipstart = w2.c_membershipstart 
    AND t_recur_window.c_membershipend = w2.c_membershipend 
    AND t_recur_window.c__accountid = w2.c__accountid 
    AND t_recur_window.c__payingaccount = w2.c__payingaccount 
    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate)
    ;
end;