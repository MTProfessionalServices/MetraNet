CREATE OR REPLACE FORCE VIEW amp_sorted_decisions (c_decisionname,c_decisiondescription,c_parametertable,c_paramtabledisplayname,c_decisionuniqueid,c_isactive,c_accountqualgroup,c_pvtoamountchainmapping,c_usagequalgroup,c_priorityvalue) AS
SELECT
        a.c_Name as c_decisionName,
        a.c_Description as c_decisionDescription,
        a.c_TableName as c_parameterTable,
        NVL(tbp.nm_display_name, NVL(tbp.nm_name, a.c_TableName)) AS c_paramTableDisplayName,
        a.c_DecisionType_Id as c_decisionUniqueId,
        b1.c_DefaultValue as c_isActive,
        b2.c_DefaultValue as c_accountQualGroup,
        NVL(b3.c_ColumnName, b3.c_DefaultValue) as c_pvToAmountChainMapping,
        b4.c_DefaultValue as c_usageQualGroup,
        CAST ( b5.c_DefaultValue AS number) as c_priorityValue
        FROM t_amp_decisiontype a
        INNER JOIN t_rulesetdefinition tr ON UPPER(tr.nm_instance_tablename) = UPPER(a.c_TableName)
        INNER JOIN t_base_props tbp ON tbp.id_prop = tr.id_paramtable
        JOIN t_amp_decisionattrib b1 ON
        a.c_DecisionType_id=b1.c_DecisionType_Id and b1.c_AttributeName='Is Active'
        JOIN t_amp_decisionattrib b2 ON
        a.c_DecisionType_id=b2.c_DecisionType_Id and b2.c_AttributeName='Account Qualification Group'
        JOIN t_amp_decisionattrib b3 ON
        a.c_DecisionType_id=b3.c_DecisionType_Id and b3.c_AttributeName='Product View To Amount Chain Mapping'
        JOIN t_amp_decisionattrib b4 ON
        a.c_DecisionType_id=b4.c_DecisionType_Id and b4.c_AttributeName='Usage Qualification Group'
        JOIN t_amp_decisionattrib b5 ON
        a.c_DecisionType_id=b5.c_DecisionType_Id and b5.c_AttributeName='Tier Priority'
/

CREATE OR REPLACE TRIGGER trig_recur_window_pay_redir
  /* We don't want to trigger on delete, because the insert comes right after a delete, and we can get the info that was deleted
  from payment_redir_history*/
  AFTER
  INSERT ON t_payment_redirection REFERENCING NEW AS NEW
  FOR EACH row
  DECLARE currentDate DATE;
  BEGIN
    /*Get the old vt_start and vt_end for payees that have changed*/
    insert into tmp_redir
    SELECT DISTINCT redirold.id_payer,
      redirold.id_payee,
      redirold.vt_start,
      redirold.vt_end
    FROM t_payment_redir_history redirnew
    JOIN t_payment_redir_history redirold
       ON redirold.tt_end      = dbo.subtractSecond(redirnew.tt_start)
       WHERE redirnew.id_payee = :new.id_payee
         AND redirnew.tt_end     = dbo.MTMaxDate();

   /*Get the old windows for payees that have changed*/
    insert into tmp_oldrw
      SELECT * FROM t_recur_window trw JOIN tmp_redir
        ON trw.c__AccountID  = tmp_redir.id_payee
        AND trw.c_PayerStart = tmp_redir.vt_start
        AND trw.c_PayerEnd   = tmp_redir.vt_end;

SELECT metratime(1,'RC') INTO currentDate FROM dual;

insert into tmp_newrw
  SELECT orw.c_CycleEffectiveDate ,
    orw.c_CycleEffectiveStart ,
    orw.c_CycleEffectiveEnd ,
    orw.c_SubscriptionStart ,
    orw.c_SubscriptionEnd ,
    orw.c_Advance ,
    orw.c__AccountID ,
    :new.id_payer c__PayingAccount ,
    orw.c__PriceableItemInstanceID ,
    orw.c__PriceableItemTemplateID ,
    orw.c__ProductOfferingID ,
    :new.vt_start c_PayerStart ,
    :new.vt_end c_PayerEnd ,
    orw.c__SubscriptionID ,
    orw.c_UnitValueStart ,
    orw.c_UnitValueEnd ,
    orw.c_UnitValue ,
    orw.c_BilledThroughDate ,
    orw.c_LastIdRun ,
    orw.c_MembershipStart ,
    orw.c_MembershipEnd,
    AllowInitialArrersCharge(orw.c_Advance, orw.c__AccountID, orw.c_SubscriptionEnd, currentDate) c__IsAllowGenChargeByTrigger
  FROM tmp_oldrw orw
  WHERE orw.c__AccountId = :new.id_payee;
  
  MeterPayerChangeFromRecWind(currentDate);
  
  DELETE
  FROM t_recur_window
  WHERE EXISTS
    (SELECT 1
    FROM tmp_newrw orw where
    t_recur_window.c__PayingAccount      = orw.c__PayingAccount
    AND t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
    AND t_recur_window.c_PayerStart         = orw.c_PayerStart
    AND t_recur_window.c_PayerEnd           = orw.c_PayerEnd
    AND t_recur_window.c__SubscriptionID    = orw.c__SubscriptionID
    );
  
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
    FROM tmp_newrw;

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
  WHERE EXISTS
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
/

CREATE OR REPLACE TRIGGER TRG_UPDATE_REC_WIND_ON_REC_VAL FOR INSERT ON T_RECUR_VALUE COMPOUND TRIGGER
startDate DATE;
v_id_sub INTEGER;
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
	v_id_sub:=:new.id_sub;
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
	AND rdnew.id_prop = rdold.id_prop
    AND rdnew.id_sub = rdold.id_sub
    AND rdold.tt_end    < dbo.MTMaxDate()
    ) ;
	
  /*TODO: look at MSSQL version... now it different */
  SELECT metratime(1,'RC') INTO startDate FROM dual;
  
  DELETE FROM tmp_newrw WHERE c__SubscriptionID = v_id_sub;
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
    dbo.mtmaxdate() c_MembershipEnd,
    AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, sub.vt_end, startDate) c__IsAllowGenChargeByTrigger
    from t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      JOIN tmp_new_units rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
        AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
        AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
      WHERE
      		sub.id_group IS NULL
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
    dbo.mtmaxdate() c_MembershipEnd,
    AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, gsm.vt_end, startDate) c__IsAllowGenChargeByTrigger
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
	WHERE
		rcr.b_charge_per_participant = 'Y'
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
    grm.vt_end c_MembershipEnd,
    AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, sub.vt_end, null) c__IsAllowGenChargeByTrigger
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
	WHERE
		grm.tt_end = dbo.mtmaxdate()
      	AND rcr.b_charge_per_participant = 'N'
      	AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);

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

  /* Should be analozed for Arrears RC*/
  MeterInitialFromRecurWindow(startDate);
  MeterUdrcFromRecurWindow(startDate);
  
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
    FROM tmp_newrw
    WHERE c__SubscriptionID = v_id_sub;
  
END AFTER STATEMENT;
END;
/

CREATE OR REPLACE TRIGGER trig_recur_window_recur_map
AFTER INSERT OR UPDATE OR DELETE ON t_gsub_recur_map
REFERENCING NEW AS new OLD AS OLD
FOR EACH row
DECLARE
currentDate DATE;
v_id_sub INTEGER;
  BEGIN
    IF deleting THEN
      DELETE FROM t_recur_window WHERE EXISTS
       (SELECT 1
          FROM t_sub sub join t_pl_map plm on sub.id_po = plm.id_po
		  WHERE t_recur_window.c__AccountID = :old.id_acc
            AND t_recur_window.c__SubscriptionID = sub.id_sub
            AND sub.id_group = :old.id_group
			AND t_recur_window.c__PriceableItemInstanceID = plm.id_pi_instance
			AND t_recur_window.c__PriceableItemTemplateID = plm.id_pi_template
       );
    ELSE
	/*inserting or updating*/
		SELECT sub.id_sub INTO v_id_sub
		  FROM t_sub sub
		  WHERE sub.id_group = :new.id_group
			AND ROWNUM = 1;
		
		DELETE FROM TMP_NEWRW WHERE c__SubscriptionID = v_id_sub;
        UPDATE t_recur_window
          SET c_MembershipStart = :new.vt_start,
              c_MembershipEnd     = :new.vt_end
        WHERE EXISTS
         (SELECT 1
			FROM t_recur_window trw JOIN t_sub sub on trw.c__AccountID    = sub.id_acc
				AND trw.c__SubscriptionID = sub.id_sub
            WHERE sub.id_group = :new.id_group
      ) ;
	
	SELECT NVL(:new.tt_start, metratime(1,'RC')) INTO currentDate FROM dual;
	  
    insert into TMP_NEWRW
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
      currentDate c_BilledThroughDate,
      -1 c_LastIdRun,
      :new.vt_start c_MembershipStart,
      :new.vt_end c_MembershipEnd,
	   AllowInitialArrersCharge(rcr.b_advance, sub.id_acc, sub.vt_end, currentDate) c__IsAllowGenChargeByTrigger
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
      WHERE
      	sub.id_group = :new.id_group
      	AND NOT EXISTS
	        (SELECT 1
	          FROM T_RECUR_WINDOW
			  WHERE c__AccountID = :new.id_acc
	            AND c__SubscriptionID = sub.id_sub
	        )
	    AND :new.tt_end  = dbo.mtmaxdate()
	    AND rcr.b_charge_per_participant = 'N'
	    AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
 /* adds charges to METER tables */
  MeterInitialFromRecurWindow(currentDate);
  MeterCreditFromRecurWindow(currentDate);
  
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
    FROM tmp_newrw
	WHERE c__SubscriptionID = v_id_sub;
  
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
	
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_rec_win_on_t_gsubmember AFTER
  INSERT OR
  DELETE OR
  UPDATE ON t_gsubmember REFERENCING NEW AS new OLD AS OLD
  FOR EACH row
  DECLARE
	currentDate DATE;
	v_id_sub INTEGER;
  BEGIN
  IF deleting THEN
  BEGIN
	  SELECT sub.id_sub INTO v_id_sub
	  FROM t_sub sub
	  where sub.id_group = :old.id_group
		AND ROWNUM = 1;
	  
	  DELETE FROM t_recur_window trw
	  WHERE
			trw.c__subscriptionid = v_id_sub
			AND trw.c__accountid = :old.id_acc;
  END;
ELSE
  /*inserting or updating*/
  SELECT sub.id_sub INTO v_id_sub
  FROM t_sub sub
  WHERE sub.id_group = :new.id_group
	AND ROWNUM = 1;
  
   DELETE FROM tmp_newrw WHERE c__subscriptionid = v_id_sub;
      
   UPDATE t_recur_window trw
      SET trw.c_MembershipStart = :new.vt_start,
          trw.c_MembershipEnd = :new.vt_end
      WHERE exists
      (SELECT 1
         FROM t_sub ts inner join t_pl_map plm on ts.id_po = plm.id_po
            and plm.id_sub = null and plm.id_paramtable = null
   WHERE
              trw.c__accountid       = :new.id_acc
              AND ts.id_group           = :new.id_group
              AND trw.c__subscriptionid = ts.id_sub
           and trw.c__PriceableItemInstanceID = plm.id_pi_instance
              AND trw.c__PriceableItemTemplateID = plm.id_pi_template
      );
	  
	SELECT metratime(1,'RC') INTO currentDate FROM dual;
      
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
      , AllowInitialArrersCharge(rcr.b_advance, :new.id_acc, :new.vt_end, currentDate) c__IsAllowGenChargeByTrigger
      FROM t_sub sub
      INNER JOIN t_payment_redirection pay ON pay.id_payee = :new.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start AND pay.vt_start < :new.vt_end AND pay.vt_end > :new.vt_start
      INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate() AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start AND rv.vt_start < :new.vt_end AND rv.vt_end > :new.vt_start
      WHERE sub.id_group = :new.id_group
       AND not EXISTS
        (SELECT 1
		FROM T_RECUR_WINDOW
		where c__AccountID = :new.id_acc
			AND c__SubscriptionID = sub.id_sub
			and c__PriceableItemInstanceID = plm.id_pi_instance
			and c__PriceableItemTemplateID = plm.id_pi_template)
		AND rcr.b_charge_per_participant = 'Y'
		AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
  
	/* adds charges to METER tables */
	MeterInitialFromRecurWindow(currentDate);
	MeterCreditFromRecurWindow(currentDate);
 
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
    FROM tmp_newrw
	WHERE c__subscriptionid = v_id_sub;
 
	 /* TODO: do we need it for delete action? */
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
	WHERE EXISTS
	  (SELECT 1
	  FROM t_recur_window w2
	  WHERE w2.c__SubscriptionID  = w1.c__SubscriptionID
	  AND w1.c_PayerStart         = w2.c_PayerStart
	  AND w1.c_PayerEnd           = w2.c_PayerEnd
	  AND w1.c_UnitValueStart     = w2.c_UnitValueStart
	  AND w1.c_UnitValueEnd       = w2.c_UnitValueEnd
	  AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
	  ) ;
END IF;
END;
/

CREATE OR REPLACE TRIGGER trig_recur_window_sub AFTER INSERT OR UPDATE OR DELETE
ON t_sub
REFERENCING NEW AS new old as old
FOR EACH row
DECLARE currentDate DATE;
BEGIN
	IF deleting THEN
	BEGIN
		/* dt_crt is nullable. Use SystemDate as workaround not disable possibility of fail on production */
        SELECT NVL(:old.dt_crt, metratime(1,'RC')) INTO currentDate FROM dual;
        DELETE FROM t_recur_window
           WHERE c__SubscriptionID   = :old.id_sub;
    END;
    ELSE
	/*inserting or deleting*/
		/* dt_crt is nullable. Use SystemDate as workaround not disable possibility of fail on production */
		SELECT NVL(:new.dt_crt, metratime(1,'RC')) INTO currentDate FROM dual;
		
		DELETE FROM TMP_NEWRW where c__SubscriptionID = :new.id_sub;
	
		UPDATE t_recur_window
            SET c_SubscriptionStart = :new.vt_start,
				c_SubscriptionEnd   = :new.vt_end
            WHERE EXISTS
             (	SELECT 1
				FROM t_recur_window trw
					JOIN t_pl_map plm on :new.id_po = plm.id_po
                and plm.id_sub = :new.id_sub and plm.id_paramtable = null
                WHERE
				  c__AccountID      = :new.id_acc
				  AND c__SubscriptionID   = :new.id_sub
          ) ;
          
		UPDATE t_recur_window
			SET 	c_SubscriptionStart = :new.vt_start,
					c_SubscriptionEnd   = :new.vt_end
			WHERE c__AccountID      = :new.id_acc
				AND c__SubscriptionID   = :new.id_sub;
      
      DELETE FROM TMP_NEWRW;
    
      INSERT INTO TMP_NEWRW
      SELECT :new.vt_start c_CycleEffectiveDate,
        :new.vt_start c_CycleEffectiveStart,
        :new.vt_end c_CycleEffectiveEnd,
        :new.vt_start c_SubscriptionStart,
        :new.vt_end c_SubscriptionEnd,
        rcr.b_advance c_Advance ,
        pay.id_payee c__AccountID,
        pay.id_payer c__PayingAccount,
        plm.id_pi_instance c__PriceableItemInstanceID,
        plm.id_pi_template c__PriceableItemTemplateID,
        plm.id_po c__ProductOfferingID,
        pay.vt_start c_PayerStart,
        pay.vt_end c_PayerEnd,
        :new.id_sub c__SubscriptionID,
        NVL(rv.vt_start, dbo.mtmindate()) c_UnitValueStart,
        NVL(rv.vt_end, dbo.mtmaxdate()) c_UnitValueEnd,
        rv.n_value c_UnitValue,
        dbo.mtmindate() c_BilledThroughDate,
        -1 c_LastIdRun,
        dbo.mtmindate() c_MembershipStart,
        dbo.mtmaxdate() c_MembershipEnd,
        AllowInitialArrersCharge(rcr.b_advance, :new.id_acc, :new.vt_end, :new.dt_crt) c__IsAllowGenChargeByTrigger
      from t_payment_redirection pay INNER JOIN t_pl_map plm
         ON plm.id_po = :new.id_po AND plm.id_paramtable IS NULL
      INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
      INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
      LEFT OUTER JOIN t_recur_value rv ON rv.id_prop = rcr.id_prop
        AND :new.id_sub  = rv.id_sub AND rv.tt_end   = dbo.MTMaxDate()
        AND rv.vt_start < :new.vt_end AND rv.vt_end   > :new.vt_start
        AND rv.vt_start < pay.vt_end  AND rv.vt_end   > pay.vt_start
      WHERE
		pay.id_payee  = :new.id_acc
		AND pay.vt_start < :new.vt_end
		AND pay.vt_end   > :new.vt_start
      /*Make sure not to insert a row that already takes care of this account/sub id*/
		AND NOT EXISTS
			(SELECT 1
			FROM T_RECUR_WINDOW
			  WHERE c__AccountID    = :new.id_acc
			  AND c__SubscriptionID = :new.id_sub
			)
		AND :new.id_group IS NULL
		AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);
 	
	/* adds charges to METER tables */
	MeterInitialFromRecurWindow(currentDate);
	MeterCreditFromRecurWindow(currentDate);

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
    FROM tmp_newrw
	WHERE c__SubscriptionID = :new.id_sub;
	
	END IF;
END;
/

DROP TRIGGER quoteheader_quoteid_increment
/

ALTER PROCEDURE moveaccount2 COMPILE 
/

ALTER PROCEDURE applytemplatetooneaccount COMPILE 
/

DROP SEQUENCE qu_quoteheader_sequence
/

BEGIN
	prtn_insert_meter_part_info(id_partition =>1);
END;
/

DECLARE
    last_upgrade_id NUMBER;
BEGIN
    SELECT MAX(upgrade_id)
    INTO   last_upgrade_id
    FROM   t_sys_upgrade;
    
    UPDATE t_sys_upgrade
    SET db_upgrade_status = 'C',
    dt_end_db_upgrade = SYSDATE()
    WHERE upgrade_id = last_upgrade_id; 
END;
/
