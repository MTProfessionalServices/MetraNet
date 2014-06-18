CREATE trigger trig_update_recur_window_on_t_sub
ON t_sub
for INSERT, UPDATE, delete
as 
BEGIN  
declare @temp datetime
  delete from t_recur_window where exists (
    select 1 from deleted sub where
      t_recur_window.c__AccountID = sub.id_acc
      and t_recur_window.c__SubscriptionID = sub.id_sub
      AND t_recur_window.c_SubscriptionStart = sub.vt_start
      AND t_recur_window.c_SubscriptionEnd = sub.vt_end);

  MERGE into t_recur_window USING (
    select distinct sub.id_sub, sub.id_acc, sub.vt_start, sub.vt_end, plm.id_pi_template, plm.id_pi_instance
    FROM INSERTED sub inner join t_recur_window trw on trw.c__AccountID = sub.id_acc
       AND trw.c__SubscriptionID = sub.id_sub
       inner join t_pl_map plm on sub.id_po = plm.id_po
            and plm.id_sub = sub.id_sub and plm.id_paramtable = null	) AS source
        ON (t_recur_window.c__SubscriptionID = source.id_sub
             and t_recur_window.c__AccountID = source.id_acc)
    WHEN matched AND t_recur_window.c__SubscriptionID = source.id_sub and t_recur_window.c__AccountID = source.id_acc
      THEN UPDATE SET c_SubscriptionStart = source.vt_start, c_SubscriptionEnd = source.vt_end;
    
  SELECT sub.vt_start AS c_CycleEffectiveDate
        ,sub.vt_start AS c_CycleEffectiveStart
        ,sub.vt_end   AS c_CycleEffectiveEnd
        ,sub.vt_start AS c_SubscriptionStart
        ,sub.vt_end   AS c_SubscriptionEnd
        ,rcr.b_advance  AS c_Advance
        ,pay.id_payee AS c__AccountID
        ,pay.id_payer AS c__PayingAccount
        ,plm.id_pi_instance AS c__PriceableItemInstanceID
        ,plm.id_pi_template AS c__PriceableItemTemplateID
        ,plm.id_po    AS c__ProductOfferingID
        ,pay.vt_start AS c_PayerStart
        ,pay.vt_end   AS c_PayerEnd
        ,sub.id_sub   AS c__SubscriptionID
        ,IsNull(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
        ,IsNull(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
        ,rv.n_value   AS c_UnitValue
        ,dbo.mtmindate() as c_BilledThroughDate
        ,-1 AS c_LastIdRun
        ,dbo.mtmindate() AS c_MembershipStart
        ,dbo.mtmaxdate() AS c_MembershipEnd
        , dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, sub.dt_crt) AS c__IsAllowGenChargeByTrigger
      --We'll use #recur_window_holder in the stored proc that operates only on the latest data
        INTO #recur_window_holder
        FROM inserted sub
          INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc 
         --   AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
          INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
          INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
          INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
          LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
            AND rv.tt_end = dbo.MTMaxDate() 
            AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
            AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
         WHERE 1=1
        --Make sure not to insert a row that already takes care of this account/sub id
           AND not EXISTS
           (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = sub.id_acc
              AND c__SubscriptionID = sub.id_sub)
              AND sub.id_group IS NULL
              AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

   select @temp = max(tsh.tt_start) from t_sub_history tsh 
   join inserted sub 
   on tsh.id_acc = sub.id_acc and tsh.id_sub = sub.id_sub;
   
   /* adds charges to METER tables */
   EXEC MeterInitialFromRecurWindow @currentDate = @temp;
   EXEC MeterCreditFromRecurWindow @currentDate = @temp;  
  
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

 END;
