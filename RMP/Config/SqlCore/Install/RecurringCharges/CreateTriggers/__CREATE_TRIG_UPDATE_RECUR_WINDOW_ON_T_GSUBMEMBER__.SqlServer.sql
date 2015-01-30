create trigger trig_update_recur_window_on_t_gsubmember
ON t_gsubmember
for insert, UPDATE, delete
as 
begin
declare @startDate                    datetime,
        @num_notnull_quote_batchids   INT
        
delete from t_recur_window where exists (
  select 1 from deleted gsm 
         join t_sub sub on gsm.id_group = sub.id_group and
         t_recur_window.c__SubscriptionID = sub.id_sub and t_recur_window.c__AccountID = gsm.id_acc
	    join t_pl_map plm on sub.id_po = plm.id_po
		  and t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance and t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template
INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
AND rcr.b_charge_per_participant = 'Y');
         
         
MERGE into t_recur_window USING (
	select distinct sub.id_sub, gsubmember.id_acc, gsubmember.vt_start, gsubmember.vt_end, plm.id_pi_template, plm.id_pi_instance 
	FROM 
       INSERTED gsubmember inner join t_recur_window trw on 
         trw.c__AccountID = gsubmember.id_acc 
         inner join t_sub sub on sub.id_group = gsubmember.id_group
            and trw.c__SubscriptionID = sub.id_sub
         inner join t_pl_map plm on sub.id_po = plm.id_po
            and plm.id_sub = null and plm.id_paramtable = null		 
			) AS source
     ON (t_recur_window.c__SubscriptionID = source.id_sub  
     and t_recur_window.c__AccountID = source.id_acc)
WHEN matched AND t_recur_window.c__SubscriptionID = source.id_sub 
    AND t_recur_window.c__AccountID = source.id_acc
    and t_recur_window.c__PriceableItemInstanceID = source.id_pi_instance
    AND t_recur_window.c__PriceableItemTemplateID = source.id_pi_template	THEN
	UPDATE SET c_MembershipStart = source.vt_start,
	           c_MembershipEnd = source.vt_end;
	
	
	SET @startDate = dbo.metratime(1,'RC');
  
   SELECT @num_notnull_quote_batchids = count(1)
    FROM inserted gsm 
         join t_sub sub on gsm.id_group = sub.id_group 
    WHERE tx_quoting_batch is not null 
      AND tx_quoting_batch!=0x00000000000000000000000000000000; 
			   
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
      , @startDate as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd      
      , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, @startDate, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger
	INTO #recur_window_holder
    FROM INSERTED gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE 
		not EXISTS 
        (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = gsm.id_acc 
          AND c__SubscriptionID = sub.id_sub
		  and c__PriceableItemInstanceID = plm.id_pi_instance
		  and c__PriceableItemTemplateID = plm.id_pi_template)
      AND rcr.b_charge_per_participant = 'Y'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
	
	/* adds charges to METER tables */
    EXEC MeterInitialFromRecurWindow @currentDate = @startDate;
    EXEC MeterCreditFromRecurWindow @currentDate = @startDate;
	  
	INSERT INTO t_recur_window    
	SELECT c_CycleEffectiveDate,
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
	
/* step 2) update the cycle effective windows */

/* sql */
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
END;