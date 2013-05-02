
	CREATE OR REPLACE TRIGGER TRG_UPDATE_REC_WIND_ON_REC_VAL FOR INSERT ON T_RECUR_VALUE COMPOUND TRIGGER 
	AFTER EACH ROW
IS
BEGIN
  INSERT
  INTO tmp_rv_new VALUES
    (
      :new.id_prop,
      :new.id_sub,
      :new.n_value,
      :new.vt_start,
      :new.vt_end,
      :new.tt_start,
      :new.tt_end
    );
END AFTER EACH row;
AFTER STATEMENT

IS
BEGIN
  /*Get the old vt_start and vt_end for recur values that have changed*/
  INSERT INTO tmp_new_units
  SELECT *
  FROM tmp_rv_new rdnew
  WHERE NOT EXISTS
    (SELECT *
    FROM tmp_rv_new rdold
    WHERE rdnew.n_value = rdold.n_value
    AND rdnew.vt_start  = rdold.vt_start
    AND rdnew.vt_end    = rdold.vt_end
	and rdnew.id_prop = rdold.id_prop
    and rdnew.id_sub = rdold.id_sub
    AND rdold.tt_end    < dbo.MTMaxDate()
    ) ;
  /*Get the old windows for recur values that have changed*/
  INSERT INTO tmp_newrw
  SELECT sub.vt_start c_CycleEffectiveDate ,
    sub.vt_start c_CycleEffectiveStart ,
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
    NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart ,
    NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd ,
    rv.n_value c_UnitValue ,
    dbo.mtmindate() c_BilledThroughDate ,
    -1 c_LastIdRun ,
    dbo.mtmindate() c_MembershipStart ,
    dbo.mtmaxdate() c_MembershipEnd
    from t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN tmp_new_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE 1=1
      AND sub.id_group IS NULL
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
  
  UNION ALL
  
  SELECT gsm.vt_start c_CycleEffectiveDate ,
    gsm.vt_start c_CycleEffectiveStart ,
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
    NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart ,
    NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd ,
    rv.n_value c_UnitValue ,
    dbo.mtmindate() c_BilledThroughDate ,
    -1 c_LastIdRun ,
    dbo.mtmindate() c_MembershipStart ,
    dbo.mtmaxdate() c_MembershipEnd
      FROM t_gsubmember gsm
      INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc 
        AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start 
        AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN tmp_new_units rv ON rv.id_prop = rcr.id_prop 
        AND sub.id_sub = rv.id_sub 
        AND rv.tt_end = dbo.MTMaxDate() 
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start 
        AND rv.vt_start < gsm.vt_end AND rv.vt_end > gsm.vt_start
      WHERE 1=1
      AND rcr.b_charge_per_participant = 'Y'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
  
  UNION ALL
  
  SELECT sub.vt_start c_CycleEffectiveDate ,
    sub.vt_start c_CycleEffectiveStart ,
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
    NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart ,
    NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd ,
    rv.n_value c_UnitValue ,
    dbo.mtmindate() c_BilledThroughDate ,
    -1 c_LastIdRun ,
    grm.vt_start c_MembershipStart ,
    grm.vt_end c_MembershipEnd
      FROM t_gsub_recur_map grm
      /* TODO: GRM dates or sub dates or both for filtering */
      INNER JOIN t_sub sub ON grm.id_group = sub.id_group
      INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN tmp_new_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub 
      AND rv.tt_end = dbo.MTMaxDate() 
      AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start 
      AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE 1=1
      AND grm.tt_end = dbo.mtmaxdate()
      AND rcr.b_charge_per_participant = 'N'
      AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL)
;

  /*Get the old vt_start and vt_end for recur values that have changed*/
  INSERT INTO tmp_old_units
  SELECT DISTINCT trw.c__SubscriptionID        AS id_sub,
    trw.c_UnitValue                            AS n_value,
    NVL(trw.c_UnitValueStart, dbo.mtmindate()) AS vt_start,
    NVL(trw.c_UnitValueEnd, dbo.mtmaxdate())   AS vt_end,
    trv.tt_end
  FROM t_recur_window trw  JOIN tmp_newrw rwh ON trw.c__SubscriptionID = rwh.c__SubscriptionID
    AND trw.c_UnitValue = rwh.c_UnitValue
    and trw.c__PriceableItemTemplateId = rwh.c__PriceableItemTemplateId
    and trw.c__PriceableItemInstanceId = rwh.c__PriceableItemInstanceId
    /*A possibly clumsy attempt at an XOR.  We want one of the start or end dates     to match the old start/end, but not the other one.*/
    AND (trw.c_UnitValueStart  = rwh.c_UnitValueStart OR trw.c_UnitValueEnd = rwh.c_UnitValueEnd)
    AND (trw.c_UnitValueStart != rwh.c_UnitValueStart OR trw.c_UnitValueEnd != rwh.c_UnitValueEnd)
  JOIN t_recur_value trv ON rwh.c__SubscriptionID = trv.id_sub
    AND trw.c_UnitValueStart = trv.vt_start AND trw.c_UnitValueEnd = trv.vt_end
    AND trv.tt_end < dbo.MTMaxDate() ;
  
  /*The recur_window_holder has too many entries, because of the way we drop all entries for a sub   
    then re-insert them.  So, drop all the entries that already exist in t_recur_window*/
DELETE FROM tmp_newrw WHERE EXISTS
(SELECT 1 FROM t_recur_window trw  JOIN t_recur_value trv 
    ON trw.c__SubscriptionID = trv.id_sub
    and trv.id_prop = trw.c__PriceableItemInstanceId
    AND trw.c_UnitValueStart = trv.vt_start
    AND trw.c_UnitValueEnd = trv.vt_end
    AND trv.tt_end = dbo.MTMaxDate()
 WHERE
   trw.c__SubscriptionID = tmp_newrw.c__SubscriptionID
   AND trw.c_UnitValue = tmp_newrw.c_UnitValue
   AND trw.c_UnitValueStart =tmp_newrw.c_UnitValueStart
   AND trw.c_UnitValueEnd = tmp_newrw.c_UnitValueEnd
   and trw.c__PriceableItemInstanceID = tmp_newrw.c__PriceableItemInstanceID
   and trw.c__PriceableItemTemplateID = tmp_newrw.c__PriceableItemTemplateID
);

  MeterInitialFromRecurWindow;
  MeterUdrcFromRecurWindow;
  
  /*Delete old values from t_recur_window*/
  DELETE FROM t_recur_window
  WHERE EXISTS
  (SELECT 1 FROM t_recur_value oldunits join t_pl_map plm on oldunits.id_sub = plm.id_sub
  and oldunits.id_prop = plm.id_pi_instance
     where 
  t_recur_window.c__SubscriptionID = oldunits.id_sub
  AND t_recur_window.c_UnitValueStart = oldunits.vt_start 
  AND t_recur_window.c_UnitValueEnd = oldunits.vt_end
  and plm.id_pi_instance = t_recur_window.c__PriceableItemInstanceID
  and plm.id_pi_template = t_recur_window.c__PriceableItemTemplateID  
  );
  
  UPDATE tmp_newrw SET c_BilledThroughDate = metratime(1,'RC');
  
  INSERT INTO T_RECUR_WINDOW
  SELECT DISTINCT * FROM tmp_newrw ;
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
END AFTER STATEMENT;
END;
