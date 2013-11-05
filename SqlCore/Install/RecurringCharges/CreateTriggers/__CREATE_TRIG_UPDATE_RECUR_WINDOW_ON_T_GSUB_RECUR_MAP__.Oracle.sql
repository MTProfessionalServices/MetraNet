
create or replace TRIGGER trig_recur_window_recur_map 
  AFTER INSERT OR UPDATE OR DELETE ON t_gsub_recur_map
    REFERENCING NEW AS new OLD AS OLD FOR EACH row 
    
  BEGIN 
    IF deleting THEN
      DELETE FROM t_recur_window WHERE EXISTS
       (SELECT 1
          FROM t_sub sub join t_pl_map plm on sub.id_po = plm.id_po
		  WHERE t_recur_window.c__AccountID = :old.id_acc
            AND t_recur_window.c__SubscriptionID = sub.id_sub
            AND sub.id_group = :old.id_group
			and t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance 
			and t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template		  
       );
    ELSE 
	/*inserting or updating*/
      BEGIN
        UPDATE t_recur_window 
          SET c_MembershipStart = :new.vt_start,
              c_MembershipEnd     = :new.vt_end
        WHERE EXISTS
         (SELECT 1 FROM t_recur_window trw JOIN t_sub sub
            on trw.c__AccountID    = sub.id_acc
              AND trw.c__SubscriptionID = sub.id_sub
              where sub.id_group = :new.id_group
      ) ;
    insert into t_recur_window
    SELECT sub.vt_start c_CycleEffectiveDate,
      sub.vt_start c_CycleEffectiveStart,
      sub.vt_end c_CycleEffectiveEnd,
      sub.vt_start c_SubscriptionStart,
      sub.vt_end c_SubscriptionEnd,
      rcr.b_advance c_Advance,
      pay.id_payee c__AccountID,
      pay.id_payer c__PayingAccount,
      plm.id_pi_instance c__PriceableItemInstanceID,
      plm.id_pi_template c__PriceableItemTemplateID,
      plm.id_po c__ProductOfferingID,
      pay.vt_start c_PayerStart,
      pay.vt_end c_PayerEnd,
      sub.id_sub c__SubscriptionID,
      NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart,
      NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd,
      rv.n_value c_UnitValue,
      metratime(1,'RC') c_BilledThroughDate,
      -1 c_LastIdRun,
      :new.vt_start c_MembershipStart,
      :new.vt_end c_MembershipEnd
      from t_sub sub INNER JOIN t_payment_redirection pay
         ON pay.id_payee = :new.id_acc AND pay.vt_start < sub.vt_end
          AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po
         AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop 
        AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE 1 = 1
      AND sub.id_group = :new.id_group
      AND NOT EXISTS
        (SELECT 1
          FROM T_RECUR_WINDOW WHERE c__AccountID = :new.id_acc
            AND c__SubscriptionID = sub.id_sub
        )
      AND :new.tt_end  = dbo.mtmaxdate()
      AND rcr.b_charge_per_participant = 'N' 
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)	      
	  AND AllowInitialArrersCharge(rcr.b_advance, sub.id_acc, sub.vt_end, sub.dt_crt) = 1;
    END;
  END IF;
  
  MeterInitialFromRecurWindow;
  MeterCreditFromRecurWindow;
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

  