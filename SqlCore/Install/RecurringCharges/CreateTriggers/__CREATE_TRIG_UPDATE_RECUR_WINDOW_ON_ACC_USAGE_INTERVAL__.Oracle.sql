
create or replace TRIGGER trg_recur_win_acc_usage_int AFTER INSERT OR DELETE OR UPDATE 
  ON T_ACC_USAGE_INTERVAL 
    REFERENCING OLD AS old NEW AS new 
    FOR EACH ROW 
	when (new.tx_status ='O' or new.tx_status is null)
  BEGIN
    IF deleting THEN
      DELETE FROM t_recur_window
        WHERE c__AccountID = :old.id_acc
           AND c_CycleEffectiveDate = :old.dt_effective;
    ELSE
      INSERT INTO t_recur_window
        SELECT :new.dt_effective c_CycleEffectiveDate ,
          dbo.AddSecond(:new.dt_effective) c_CycleEffectiveStart ,
          sub.vt_end c_CycleEffectiveEnd ,
          sub.vt_start c_SubscriptionStart ,
          sub.vt_end c_SubscriptionEnd ,
          rcr.b_advance c_Advance ,
          pay.id_payee c__AccountID ,
          pay.id_payer c__PayingAccount ,
          plm.id_pi_instance c__PriceableItemInstanceID ,
          plm.id_pi_template c__PriceableItemTemplateID ,
          plm.id_po c__ProductOfferingID ,
          pay.vt_start c_PayerStart ,
          pay.vt_end c_PayerEnd ,
          sub.id_sub c__SubscriptionID ,
          NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart,
          NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd,
          rv.n_value c_UnitValue ,
          dbo.mtmindate() c_BilledThroughDate ,
          -1 c_LastIdRun ,
          dbo.mtmindate() c_MembershipStart ,
          dbo.mtmaxdate() c_MembershipEnd,
          sub.TX_QUOTING_BATCH
       FROM t_sub sub INNER JOIN t_payment_redirection pay
         ON pay.id_payee  = sub.id_acc AND pay.vt_start < sub.vt_end
           AND pay.vt_end   > sub.vt_start
         INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
         INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
         INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
         LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop
           AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
           AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
           AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
           AND dbo.AddSecond(:new.dt_effective) < rv.vt_end AND dbo.AddSecond(:new.dt_effective) >= rv.vt_start
        WHERE 1 =1
           AND pay.id_payer = :new.id_acc
           AND dbo.AddSecond(:new.dt_effective) < sub.vt_end AND dbo.AddSecond(:new.dt_effective) >= sub.vt_start
           AND dbo.AddSecond(:new.dt_effective) < pay.vt_end AND dbo.AddSecond(:new.dt_effective) >= pay.vt_start
           AND sub.id_group IS NULL AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
  UNION ALL
       SELECT :new.dt_effective c_CycleEffectiveDate ,
         dbo.AddSecond(:new.dt_effective) c_CycleEffectiveStart ,
         gsm.vt_end c_CycleEffectiveEnd ,
         gsm.vt_start c_SubscriptionStart ,
         gsm.vt_end c_SubscriptionEnd ,
         rcr.b_advance c_Advance ,
         pay.id_payee c__AccountID ,
         pay.id_payer c__PayingAccount ,
         plm.id_pi_instance c__PriceableItemInstanceID ,
         plm.id_pi_template c__PriceableItemTemplateID ,
         plm.id_po c__ProductOfferingID ,
         pay.vt_start c_PayerStart ,
         pay.vt_end c_PayerEnd ,
         sub.id_sub c__SubscriptionID ,
         NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart,
         NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd,
         rv.n_value c_UnitValue ,
         dbo.mtmindate() c_BilledThroughDate ,
         -1 c_LastIdRun ,
         dbo.mtmindate() c_MembershipStart ,
         dbo.mtmaxdate() c_MembershipEnd,
         sub.TX_QUOTING_BATCH
       FROM t_gsubmember gsm INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
         INNER JOIN t_payment_redirection pay ON pay.id_payee  = gsm.id_acc
           AND pay.vt_start < sub.vt_end AND pay.vt_end   > sub.vt_start
           AND pay.vt_start < gsm.vt_end AND pay.vt_end   > gsm.vt_start
         INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
         INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
         INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
         LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop
           AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
           AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
           AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
           AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
           AND dbo.AddSecond(:new.dt_effective)  < rv.vt_end
           AND dbo.AddSecond(:new.dt_effective) >= rv.vt_start
          WHERE 1  =1
          AND pay.id_payer = :new.id_acc
          AND dbo.AddSecond(:new.dt_effective) < sub.vt_end AND dbo.AddSecond(:new.dt_effective) >= sub.vt_start
          AND dbo.AddSecond(:new.dt_effective)  < pay.vt_end
          AND dbo.AddSecond(:new.dt_effective) >= pay.vt_start
          AND rcr.b_charge_per_participant = 'Y'
          AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
   UNION ALL
     SELECT :new.dt_effective c_CycleEffectiveDate ,
         dbo.AddSecond(:new.dt_effective) c_CycleEffectiveStart ,
         sub.vt_end c_CycleEffectiveEnd ,
         sub.vt_start c_SubscriptionStart ,
         sub.vt_end c_SubscriptionEnd ,
         rcr.b_advance c_Advance ,
         pay.id_payee c__AccountID ,
         pay.id_payer c__PayingAccount ,
         plm.id_pi_instance c__PriceableItemInstanceID ,
         plm.id_pi_template c__PriceableItemTemplateID ,
         plm.id_po c__ProductOfferingID ,
         pay.vt_start c_PayerStart ,
         pay.vt_end c_PayerEnd ,
         sub.id_sub c__SubscriptionID ,
         NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart,
         NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd,
         rv.n_value c_UnitValue ,
         dbo.mtmindate() c_BilledThroughDate ,
         -1 c_LastIdRun ,
         grm.vt_start c_MembershipStart ,
         grm.vt_end c_MembershipEnd,
          sub.TX_QUOTING_BATCH
    FROM t_gsub_recur_map grm
    /* TODO: GRM dates or sub dates or both for filtering */
       INNER JOIN t_sub sub ON grm.id_group = sub.id_group
       INNER JOIN t_payment_redirection pay ON pay.id_payee  = grm.id_acc
         AND pay.vt_start < sub.vt_end AND pay.vt_end   > sub.vt_start
       INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
       INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
       INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
       LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop
         AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
         AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
         AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
         AND dbo.AddSecond(:new.dt_effective)  < rv.vt_end AND :new.dt_effective > rv.vt_start
    WHERE 1                               =1
       AND pay.id_payer = :new.id_acc
       AND dbo.AddSecond(:new.dt_effective)  < sub.vt_end AND dbo.AddSecond(:new.dt_effective) >= sub.vt_start
       AND dbo.AddSecond(:new.dt_effective)  < pay.vt_end AND dbo.AddSecond(:new.dt_effective) >= pay.vt_start
       AND grm.tt_end =  dbo.mtmaxdate() AND rcr.b_charge_per_participant      = 'N'
       AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL) ;
END IF;
UPDATE t_recur_window w1
SET c_CycleEffectiveEnd =
  (SELECT MIN(NVL(w2.c_CycleEffectiveDate,w2.c_SubscriptionEnd))
  FROM t_recur_window w2
  WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
  AND w1.c_PayerStart         = w2.c_PayerStart
  AND w1.c_PayerEnd           = w2.c_PayerEnd
  AND w1.c_UnitValueStart     = w2.c_UnitValueStart
  AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
  AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
  )
WHERE 1=1
 AND c__PayingAccount = :new.id_acc  
AND EXISTS
  (SELECT 1
  FROM t_recur_window w2
  WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
  AND w1.c_PayerStart         = w2.c_PayerStart
  AND w1.c_PayerEnd           = w2.c_PayerEnd
  AND w1.c_UnitValueStart     = w2.c_UnitValueStart
  AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
  AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
  ) ;
END;
