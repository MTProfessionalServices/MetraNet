CREATE TRIGGER trig_update_recur_window_on_t_sub
ON t_sub
FOR  INSERT, UPDATE, DELETE
AS
BEGIN
  DECLARE @now          DATETIME,
          @newSubStart  DATETIME,
          @newSubEnd    DATETIME,
          @curSubStart  DATETIME,
          @curSubEnd    DATETIME,
          @idAcc        INT,
          @idSub        INT,
          @num_notnull_quote_batchids INT

  DELETE
  FROM   t_recur_window
  WHERE  EXISTS (
             SELECT 1
             FROM   DELETED sub
             WHERE  t_recur_window.c__AccountID = sub.id_acc
                    AND t_recur_window.c__SubscriptionID = sub.id_sub
                    AND t_recur_window.c_SubscriptionStart = sub.vt_start
                    AND t_recur_window.c_SubscriptionEnd = sub.vt_end
         );

  MERGE INTO t_recur_window
    USING (
              SELECT DISTINCT sub.id_sub,
                     sub.id_acc,
                     sub.vt_start,
                     sub.vt_end,
                     plm.id_pi_template,
                     plm.id_pi_instance
              FROM   INSERTED sub
                     INNER JOIN t_recur_window trw
                          ON  trw.c__AccountID = sub.id_acc
                          AND trw.c__SubscriptionID = sub.id_sub
                     INNER JOIN t_pl_map plm
                          ON  sub.id_po = plm.id_po
                          AND plm.id_sub = sub.id_sub
                          AND plm.id_paramtable = NULL
          ) AS source
    ON (
           t_recur_window.c__SubscriptionID = source.id_sub
           AND t_recur_window.c__AccountID = source.id_acc
       )
  WHEN MATCHED AND t_recur_window.c__SubscriptionID = source.id_sub
               AND t_recur_window.c__AccountID      = source.id_acc
    THEN UPDATE SET c_SubscriptionStart = source.vt_start,
                    c_SubscriptionEnd   = source.vt_end;
 
  SELECT @num_notnull_quote_batchids = count(1) 
  FROM inserted 
  WHERE tx_quoting_batch is not null 
    AND tx_quoting_batch!=0x00000000000000000000000000000000; 

  SELECT sub.vt_start AS c_CycleEffectiveDate,
         sub.vt_start AS c_CycleEffectiveStart,
         sub.vt_end AS c_CycleEffectiveEnd,
         sub.vt_start AS c_SubscriptionStart,
         sub.vt_end AS c_SubscriptionEnd,
         rcr.b_advance AS c_Advance,
         pay.id_payee AS c__AccountID,
         pay.id_payer AS c__PayingAccount,
         plm.id_pi_instance AS c__PriceableItemInstanceID,
         plm.id_pi_template AS c__PriceableItemTemplateID,
         plm.id_po AS c__ProductOfferingID,
         pay.vt_start AS c_PayerStart,
         pay.vt_end AS c_PayerEnd,
         sub.id_sub AS c__SubscriptionID,
         ISNULL(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart,
         ISNULL(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd,
         rv.n_value AS c_UnitValue,
         dbo.mtmindate() AS c_BilledThroughDate,
         -1 AS c_LastIdRun,
         dbo.mtmindate() AS c_MembershipStart,
         dbo.mtmaxdate() AS c_MembershipEnd,
         dbo.AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, sub.dt_crt, @num_notnull_quote_batchids) AS c__IsAllowGenChargeByTrigger         
         /* We'll use #recur_window_holder in the stored proc that operates only on the latest data */
         INTO #recur_window_holder
  FROM   INSERTED sub
         INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc
         /* AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start */
         INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
         INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
         INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
         LEFT OUTER JOIN t_recur_value rv ON  rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
              AND rv.tt_end = dbo.MTMaxDate()
              AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
              AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
  WHERE  /* Make sure not to insert a row that already takes care of this account/sub id */
         NOT EXISTS
         (
             SELECT 1
             FROM   T_RECUR_WINDOW
             WHERE  c__AccountID = sub.id_acc
                    AND c__SubscriptionID = sub.id_sub
         )
         AND sub.id_group IS NULL
         AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)

  SELECT @now = tsh.tt_start FROM t_sub_history tsh JOIN INSERTED sub ON tsh.id_acc = sub.id_acc AND tsh.id_sub = sub.id_sub AND tsh.tt_end = dbo.MTMaxDate();

   /* adds charges to METER tables */
  EXEC MeterInitialFromRecurWindow @currentDate = @now;
  /* If this is update of existing subscription add also Credit/Debit charges */
  EXEC MeterCreditFromRecurWindow  @currentDate = @now;

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
  FROM   #recur_window_holder;

END;