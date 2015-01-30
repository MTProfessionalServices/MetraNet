CREATE OR REPLACE TRIGGER TRG_UPDATE_REC_WIND_ON_REC_VAL
  FOR INSERT OR UPDATE ON T_RECUR_VALUE
    COMPOUND TRIGGER

  startDate DATE;
  v_id_sub INTEGER;
  v_QuoteBatchId raw(16);
  num_notnull_quote_batchids INTEGER;

  AFTER EACH ROW IS
  BEGIN
    IF UPDATING THEN
      INSERT
      INTO TMP_CHANGED_UNITS VALUES
        (
          :OLD.id_prop,
          :OLD.id_sub,
          :OLD.n_value,
          :OLD.vt_start,
          :OLD.vt_end,
          :OLD.tt_start,
          :OLD.tt_end
        );
    END IF;

    IF INSERTING THEN
      INSERT
      INTO TMP_CHANGED_UNITS VALUES
        (
          :NEW.id_prop,
          :NEW.id_sub,
          :NEW.n_value,
          :NEW.vt_start,
          :NEW.vt_end,
          :NEW.tt_start,
          :NEW.tt_end
        );
      v_id_sub:= :NEW.id_sub;
     
      SELECT sub.TX_QUOTING_BATCH INTO v_QuoteBatchId
		  FROM t_sub sub
		  WHERE sub.id_sub = :new.id_sub
			AND ROWNUM = 1;
    END IF;

  END AFTER EACH ROW;


  AFTER STATEMENT IS BEGIN

    IF sql%rowcount != 0 THEN
      /*TODO: look at MSSQL version... now it different */
      SELECT metratime(1,'RC') INTO startDate FROM dual;
      
      IF v_QuoteBatchId is not null THEN
        num_notnull_quote_batchids := 1;
      ELSE
        num_notnull_quote_batchids := 0;
      END IF;

      IF UPDATING THEN
        INSERT INTO TMP_NEWRW
        SELECT
          C_CYCLEEFFECTIVEDATE,
          C_CYCLEEFFECTIVESTART,
          C_CYCLEEFFECTIVEEND,
          C_SUBSCRIPTIONSTART,
          C_SUBSCRIPTIONEND,
          C_ADVANCE,
          C__ACCOUNTID,
          C__PAYINGACCOUNT,
          C__PRICEABLEITEMINSTANCEID,
          C__PRICEABLEITEMTEMPLATEID,
          C__PRODUCTOFFERINGID,
          C_PAYERSTART,
          C_PAYEREND,
          C__SUBSCRIPTIONID,
          C_UNITVALUESTART,
          C_UNITVALUEEND,
          C_UNITVALUE,
          C_BILLEDTHROUGHDATE,
          C_LASTIDRUN,
          C_MEMBERSHIPSTART,
          C_MEMBERSHIPEND,
          1 c__IsAllowGenChargeByTrigger,
          c__QuoteBatchId
        FROM   t_recur_window
        WHERE  EXISTS
           (
             SELECT 1 FROM TMP_CHANGED_UNITS d
             WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                AND t_recur_window.c_UnitValueStart = d.vt_start
                AND t_recur_window.c_UnitValueEnd = d.vt_end
           );

        MERGE
        INTO    TMP_NEWRW rw
        USING   (
                  SELECT current_sub.* FROM t_sub_history new_sub
                    JOIN t_sub_history current_sub ON current_sub.id_acc = new_sub.id_acc
                      AND current_sub.id_sub = new_sub.id_sub
                      AND current_sub.tt_end = dbo.SubtractSecond(new_sub.tt_start)
                  WHERE new_sub.tt_end = dbo.MTMaxDate()
                ) cur_sub
        ON      ( rw.c__AccountID = cur_sub.id_acc AND rw.c__SubscriptionID = cur_sub.id_sub)
        WHEN MATCHED THEN
        UPDATE
        SET     rw.c_SubscriptionStart   = cur_sub.vt_start, rw.c_SubscriptionEnd   = cur_sub.vt_end,
                rw.c_CycleEffectiveStart = cur_sub.vt_start, rw.c_CycleEffectiveEnd = cur_sub.vt_end;

        DELETE
        FROM   t_recur_window
        WHERE  EXISTS
               (
                   SELECT 1 FROM TMP_CHANGED_UNITS d
                   WHERE  t_recur_window.c__SubscriptionID = d.id_sub
                          AND t_recur_window.c__PriceableItemInstanceID = d.id_prop
                          AND t_recur_window.c_UnitValueStart = d.vt_start
                          AND t_recur_window.c_UnitValueEnd = d.vt_end
               );

        MeterUdrcFromRecurWindow(startDate, 'AdvanceCorrection');

      END IF;


      IF INSERTING THEN

        /*Get the old windows for recur values that have changed*/
        INSERT INTO TMP_NEWRW
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
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, sub.vt_end, startDate, num_notnull_quote_batchids) c__IsAllowGenChargeByTrigger,
          sub.TX_QUOTING_BATCH c__QuoteBatchId
          FROM t_sub sub
            INNER JOIN t_payment_redirection pay ON pay.id_payee = sub.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
            INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
            INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
            INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
            JOIN TMP_CHANGED_UNITS rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub AND rv.tt_end = dbo.MTMaxDate()
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
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, gsm.vt_end, startDate, num_notnull_quote_batchids) c__IsAllowGenChargeByTrigger,
          sub.TX_QUOTING_BATCH c__QuoteBatchId
          FROM t_gsubmember gsm
            INNER JOIN t_sub sub ON sub.id_group = gsm.id_group
            INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
              AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
              AND pay.vt_start < gsm.vt_end AND pay.vt_end > gsm.vt_start
            INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
            INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
            INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
            JOIN TMP_CHANGED_UNITS rv ON rv.id_prop = rcr.id_prop
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
          AllowInitialArrersCharge(rcr.b_advance, pay.id_payee, sub.vt_end, null, num_notnull_quote_batchids) c__IsAllowGenChargeByTrigger,
          sub.TX_QUOTING_BATCH c__QuoteBatchId
          FROM t_gsub_recur_map grm
            /* TODO: GRM dates or sub dates or both for filtering */
            INNER JOIN t_sub sub ON grm.id_group = sub.id_group
            INNER JOIN t_payment_redirection pay ON pay.id_payee = grm.id_acc AND pay.vt_start < sub.vt_end AND pay.vt_end > sub.vt_start
            INNER JOIN t_pl_map plm ON plm.id_po = sub.id_po AND plm.id_paramtable IS NULL
            INNER JOIN t_recur rcr ON plm.id_pi_instance = rcr.id_prop
            INNER JOIN t_base_props bp ON bp.id_prop = rcr.id_prop
            JOIN TMP_CHANGED_UNITS rv ON rv.id_prop = rcr.id_prop AND sub.id_sub = rv.id_sub
            AND rv.tt_end = dbo.MTMaxDate()
            AND rv.vt_start < sub.vt_end AND rv.vt_end > sub.vt_start
            AND rv.vt_start < pay.vt_end AND rv.vt_end > pay.vt_start
        WHERE
          grm.tt_end = dbo.mtmaxdate()
              AND rcr.b_charge_per_participant = 'N'
              AND (bp.n_kind = 20 OR rv.id_prop IS NOT NULL);

        /* Should be analozed for Arrears RC*/
        MeterInitialFromRecurWindow(startDate);
        MeterUdrcFromRecurWindow(startDate, 'DebitCorrection');

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
          c_MembershipEnd,
          c__QuoteBatchId
          FROM TMP_NEWRW
          WHERE c__SubscriptionID = v_id_sub;

      END IF;
      /* TODO: Using "ON COMMIT DELETE ROWS" caused "ORA-14450: attempt to access a transactional temp table already in use" some time ago */
      DELETE FROM TMP_CHANGED_UNITS;
      DELETE FROM TMP_NEWRW;
      DELETE FROM TMP_UDRC;

    END IF;
  END AFTER STATEMENT;
END;