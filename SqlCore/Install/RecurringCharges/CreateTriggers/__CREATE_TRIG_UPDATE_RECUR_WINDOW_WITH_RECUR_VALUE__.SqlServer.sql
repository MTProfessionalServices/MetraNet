CREATE TRIGGER trig_update_t_recur_window_with_recur_value
ON t_recur_value FOR INSERT, UPDATE, DELETE
AS 
BEGIN
/* Notes:
Trigger is executed 7 times after each update of UDRC values.
5 first times INSERTED and DELETED tables are empty.
On 6 time we have update (INSERTED and DELETED have same number of rows)
On 7 time we have insert (INSERTED only have rows)
*/
  IF @@ROWCOUNT = 0 RETURN;

  DECLARE @startDate              datetime,
          @num_notnull_quote_batchids   INT
          
  SELECT @startDate = tt_start FROM inserted;

  SELECT *, 1 AS c__IsAllowGenChargeByTrigger INTO #recur_window_holder FROM t_recur_window WHERE 1=0;
  SELECT * INTO #tmp_changed_units FROM t_recur_value WHERE 1=0;

  IF EXISTS (SELECT * FROM DELETED)
  BEGIN
    INSERT INTO #tmp_changed_units SELECT * FROM DELETED;

    INSERT INTO #recur_window_holder
    SELECT *, 1 AS c__IsAllowGenChargeByTrigger
    FROM   t_recur_window
    WHERE  EXISTS
           (
               SELECT 1 FROM DELETED d
               WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                      AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                      AND t_recur_window.c_UnitValueStart = d.vt_start
                      AND t_recur_window.c_UnitValueEnd = d.vt_end
           );

    UPDATE rw
    SET rw.c_SubscriptionStart = current_sub.vt_start,
        rw.c_SubscriptionEnd = current_sub.vt_end,
        rw.c_CycleEffectiveStart = current_sub.vt_start,
        rw.c_CycleEffectiveEnd = current_sub.vt_end
    FROM #recur_window_holder rw
        INNER LOOP JOIN t_sub_history new_sub ON new_sub.id_acc = rw.c__AccountID
            AND new_sub.id_sub = rw.c__SubscriptionID
            AND new_sub.tt_end = dbo.MTMaxDate()
        INNER LOOP JOIN t_sub_history current_sub ON current_sub.id_acc = rw.c__AccountID
            AND current_sub.id_sub = rw.c__SubscriptionID
            AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start);

    DELETE
    FROM   t_recur_window
    WHERE  EXISTS
           (
               SELECT 1 FROM DELETED d
               WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                      AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                      AND t_recur_window.c_UnitValueStart = d.vt_start
                      AND t_recur_window.c_UnitValueEnd = d.vt_end
           );

    EXEC MeterUdrcFromRecurWindow @currentDate = @startDate, @actionType = 'AdvanceCorrection';
    RETURN;
  END;
  
  INSERT INTO #tmp_changed_units SELECT * FROM INSERTED;
  
   SELECT @num_notnull_quote_batchids = count(1)
    FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
    WHERE tx_quoting_batch is not null 
        AND tx_quoting_batch!=0x00000000000000000000000000000000; 

		--SET @num_notnull_quote_batchids=0;
  
  INSERT INTO #recur_window_holder
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
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger      
      FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
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
	  , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, gsm.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
      FROM t_gsubmember gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc 
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start 
        AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop 
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
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger      
      FROM t_gsub_recur_map grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN #tmp_changed_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
      AND rv.tt_end = dbo.MTMaxDate() 
      AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
      AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
      	grm.tt_end = dbo.mtmaxdate()
      	AND rcr.b_charge_per_participant = 'N'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);


  EXEC MeterInitialFromRecurWindow @currentDate = @startDate;
  EXEC MeterUdrcFromRecurWindow @currentDate = @startDate, @actionType = 'DebitCorrection';


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