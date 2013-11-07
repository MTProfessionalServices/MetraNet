create or replace
TRIGGER trig_recur_window_pay_redir
  /* We don't want to trigger on delete, because the insert comes right after a delete, and we can get the info that was deleted
  from payment_redir_history*/
  AFTER
  INSERT ON t_payment_redirection REFERENCING NEW AS NEW
  FOR EACH row
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
    1 c__IsAllowGenChargeByTrigger
  FROM tmp_oldrw orw
  WHERE orw.c__AccountId = :new.id_payee;
  
  MeterPayerChangeFromRecWind;
  
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
  
  UPDATE tmp_newrw SET c_BilledThroughDate =metratime(1,'RC');
 
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