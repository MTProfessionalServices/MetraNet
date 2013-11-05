
    CREATE OR REPLACE TRIGGER trg_rec_win_on_t_gsubmember AFTER
  INSERT OR
  DELETE OR
  UPDATE ON t_gsubmember REFERENCING NEW AS new OLD AS OLD
  FOR EACH row 
  BEGIN 
  IF deleting THEN
  DELETE FROM t_recur_window
  WHERE EXISTS
    (SELECT 1
    FROM t_sub sub INNER JOIN t_pl_map plm on sub.id_po = plm.id_po
	   inner join t_recur_window trw on trw.c__subscriptionid = sub.id_sub
	          and trw.c__PriceableItemInstanceID = plm.id_pi_instance
              AND trw.c__PriceableItemTemplateID = plm.id_pi_template
      WHERE sub.id_acc = :old.id_acc
        AND sub.id_group = :old.id_group
        AND t_recur_window.c__subscriptionid = sub.id_sub
        AND t_recur_window.c__accountid      = sub.id_acc
    );
ELSE
  /*inserting or updating*/
  BEGIN
   DELETE FROM tmp_newrw;
   UPDATE t_recur_window trw  
      SET trw.c_MembershipStart = :new.vt_start,
          trw.c_MembershipEnd = :new.vt_end
      where exists 
      (SELECT 1
         FROM t_sub ts inner join t_pl_map plm on ts.id_po = plm.id_po
            and plm.id_sub = null and plm.id_paramtable = null
			where   
              trw.c__accountid       = :new.id_acc
              AND ts.id_group           = :new.id_group
              AND trw.c__subscriptionid = ts.id_sub
	          and trw.c__PriceableItemInstanceID = plm.id_pi_instance
              AND trw.c__PriceableItemTemplateID = plm.id_pi_template	
      );
      
  INSERT INTO tmp_newrw
  SELECT
       :new.vt_start AS c_CycleEffectiveDate
      ,:new.vt_start AS c_CycleEffectiveStart
      ,:new.vt_end AS c_CycleEffectiveEnd
      ,:new.vt_start          AS c_SubscriptionStart
      ,:new.vt_end          AS c_SubscriptionEnd
      ,rcr.b_advance          AS c_Advance
      ,pay.id_payee AS c__AccountID
      ,pay.id_payer      AS c__PayingAccount
      ,plm.id_pi_instance      AS c__PriceableItemInstanceID
      ,plm.id_pi_template      AS c__PriceableItemTemplateID
      ,plm.id_po      AS c__ProductOfferingID
      ,pay.vt_start AS c_PayerStart
      ,pay.vt_end AS c_PayerEnd
      ,sub.id_sub      AS c__SubscriptionID
      , nvl(rv.vt_start, dbo.mtmindate()) AS c_UnitValueStart
      , nvl(rv.vt_end, dbo.mtmaxdate()) AS c_UnitValueEnd
      , rv.n_value AS c_UnitValue
      , metratime(1,'RC') as c_BilledThroughDate
      , -1 AS c_LastIdRun
      , dbo.mtmindate() AS c_MembershipStart
      , dbo.mtmaxdate() AS c_MembershipEnd
      FROM t_sub sub 
      INNER JOIN t_payment_redirection pay ON pay.id_payee = :new.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start AND pay.vt_start < :new.vt_end AND pay.vt_end > :new.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start AND rv.vt_start < :new.vt_end AND rv.vt_end > :new.vt_start
      WHERE 1=1
       and sub.id_group = :new.id_group
       AND not EXISTS 
        (SELECT 1 FROM T_RECUR_WINDOW where c__AccountID = :new.id_acc 
          AND c__SubscriptionID = sub.id_sub
		  and c__PriceableItemInstanceID = plm.id_pi_instance
		  and c__PriceableItemTemplateID = plm.id_pi_template)
      AND rcr.b_charge_per_participant = 'Y'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL) 
	  AND AllowInitialArrersCharge(rcr.b_advance, :new.id_acc, :new.vt_end, :new.dt_crt) = 1;
  END;
  UPDATE tmp_newrw SET c_BilledThroughDate = metratime(1,'RC');
  INSERT INTO t_recur_window
  SELECT * FROM tmp_newrw;

 MeterInitialFromRecurWindow;
 MeterCreditFromRecurWindow;
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
