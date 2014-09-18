CREATE OR REPLACE TRIGGER trig_recur_window_sub AFTER INSERT OR UPDATE OR DELETE
ON t_sub
REFERENCING NEW AS new old as old
FOR EACH row
DECLARE currentDate DATE;
        num_notnull_quote_batchids INTEGER;
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
      
      if :new.tx_quoting_batch is not null then         
        num_notnull_quote_batchids := 1;
      else 
        num_notnull_quote_batchids := 0;
      end if;
      
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
        AllowInitialArrersCharge(rcr.b_advance, pay.id_payer, :new.vt_end, :new.dt_crt, num_notnull_quote_batchids) c__IsAllowGenChargeByTrigger,
        :new.TX_QUOTING_BATCH c__QuoteBatchId
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
    c_MembershipEnd,
    c__QuoteBatchId
    FROM tmp_newrw
	WHERE c__SubscriptionID = :new.id_sub;
	
	END IF;
END;