CREATE OR REPLACE TRIGGER trig_recur_window_pay_redir
  FOR INSERT OR DELETE ON t_payment_redirection
    COMPOUND TRIGGER
    /* Trigger always processing a single change related to update of 1 date range of 1 payee */
  currentDate DATE;
  r_cnt NUMBER;

  AFTER EACH ROW IS BEGIN
    IF DELETING THEN
      INSERT INTO TMP_REDIR_DELETED (ID_PAYER, ID_PAYEE, VT_START, VT_END)
      SELECT :old.ID_PAYER, :old.ID_PAYEE, :old.VT_START, :old.VT_END FROM DUAL;
    ELSIF INSERTING THEN
      INSERT INTO TMP_REDIR_INSETED (ID_PAYER, ID_PAYEE, VT_START, VT_END)
      SELECT :new.ID_PAYER, :new.ID_PAYEE, :new.VT_START, :new.VT_END FROM DUAL;
    END IF;
  END AFTER EACH ROW;

  AFTER STATEMENT IS BEGIN
    IF SQL%ROWCOUNT != 0 AND INSERTING THEN
      SELECT COUNT(*) INTO r_cnt FROM TMP_REDIR_DELETED;
      IF( r_cnt > 0 ) THEN

        INSERT INTO TMP_NEW_PAYER_RANGE (ID_PAYER, ID_PAYEE, VT_START, VT_END)
        SELECT ID_PAYER, ID_PAYEE, VT_START, VT_END
        FROM TMP_REDIR_INSETED new
        WHERE NOT EXISTS (
              SELECT 1
              FROM   TMP_REDIR_DELETED old
              WHERE  old.id_payer = new.id_payer AND old.id_payee = new.id_payee 
                     /* Same or inside old range */
                     AND old.vt_start <= new.vt_start AND new.vt_end <= old.vt_end
              );

        INSERT INTO TMP_REDIR (Payee, NewPayer, OldPayer, BillRangeStart, BillRangeEnd,
                               NewStart, NewEnd, OldStart, OldEnd, NewRangeInsideOld)
        SELECT  new.id_payee Payee,
                new.id_payer NewPayer,
                old.id_payer OldPayer,
                new.vt_start BillRangeStart,
                new.vt_end BillRangeEnd,
                /* Date ranges of old and new payer. Requires for joins to rw and business rules validation. */
                new.vt_start NewStart,
                new.vt_end NewEnd,
                old.vt_start OldStart,
                old.vt_end OldEnd,
                '=' NewRangeInsideOld
        FROM   TMP_NEW_PAYER_RANGE new
              JOIN TMP_REDIR_DELETED old
                ON old.id_payee = new.id_payee AND old.id_payer <> new.id_payer
                  AND new.vt_start = old.vt_start AND old.vt_end = new.vt_end; /* Old range the same as new one */

        SELECT COUNT(*) INTO r_cnt FROM TMP_REDIR;
        IF( r_cnt < 1 ) THEN
          INSERT INTO TMP_REDIR (Payee, NewPayer, OldPayer, BillRangeStart, BillRangeEnd,
                                 NewStart, NewEnd, OldStart, OldEnd, NewRangeInsideOld)
          SELECT  new.id_payee Payee,
                  new.id_payer NewPayer,
                  old.id_payer OldPayer,
                  new.vt_start BillRangeStart,
                  new.vt_end BillRangeEnd,
                  /* Date ranges of old and new payer. Requires for joins to rw and business rules validation. */
                  new.vt_start NewStart,
                  new.vt_end NewEnd,
                  old.vt_start OldStart,
                  old.vt_end OldEnd,
                  'Y' NewRangeInsideOld
          FROM   TMP_NEW_PAYER_RANGE new
                JOIN TMP_REDIR_DELETED old
                  ON old.id_payee = new.id_payee AND old.id_payer <> new.id_payer
                    AND old.vt_start <= new.vt_start AND new.vt_end <= old.vt_end /* New range inside old one */
          UNION
          SELECT  new.id_payee Payee,
                  new.id_payer NewPayer,
                  old.id_payer OldPayer,
                  old.vt_start BillRangeStart,
                  old.vt_end BillRangeEnd,
                  /* Date ranges of old and new payer. Requires for joins to rw and business rules validation. */
                  new.vt_start NewStart,
                  new.vt_end NewEnd,
                  old.vt_start OldStart,
                  old.vt_end OldEnd,
                  'N' NewRangeInsideOld
          FROM   TMP_NEW_PAYER_RANGE new
                JOIN TMP_REDIR_DELETED old
                  ON old.id_payee = new.id_payee AND old.id_payer <> new.id_payer
                    AND new.vt_start <= old.vt_start AND old.vt_end <= new.vt_end; /* Old range inside new one */
        END IF;

        SELECT h.tt_start INTO currentDate
        FROM   TMP_REDIR_INSETED i
               JOIN t_payment_redir_history h
                    ON  h.id_payee = i.id_payee
                    AND h.id_payer = i.id_payer
                    AND h.tt_end = dbo.MTMaxDate()
        WHERE ROWNUM <=1;

        /* Clean-up temp tables. */
        DELETE FROM TMP_REDIR_DELETED;
        DELETE FROM TMP_REDIR_INSETED;

        SELECT COUNT(*) INTO r_cnt FROM TMP_REDIR;
        IF( r_cnt < 1 ) THEN
          RAISE_APPLICATION_ERROR (-20010,'Fail to retrieve payer change information. TMP_REDIR is empty.');
        END IF;

        DECLARE v_oldPayerCycleStart DATE;
                v_oldPayerCycleEnd DATE;
                v_oldPayerStart DATE;
                v_oldPayerEnd DATE;
                v_oldPayerId NUMBER(10,0);
                v_newPayerStart DATE;
                v_newPayerEnd DATE;
                v_newPayerId NUMBER(10,0);
                v_NewRangeInsideOld CHAR(1 BYTE);
        BEGIN
          SELECT NewStart, NewEnd, NewPayer, OldStart, OldEnd, OldPayer, NewRangeInsideOld
          INTO v_newPayerStart, v_newPayerEnd, v_newPayerId, v_oldPayerStart, v_oldPayerEnd, v_oldPayerId, v_NewRangeInsideOld
          FROM TMP_REDIR WHERE ROWNUM <=1;
          
          IF (v_oldPayerStart <> v_newPayerStart AND v_oldPayerEnd <> v_newPayerEnd) THEN
              /* TODO: Handle case when new Payer does not have common Start Or End with Old payer. */
              RAISE_APPLICATION_ERROR (-20010,'Limitation: New and Old payer ranges should either have a common start date or common end date.');
          END IF;
          
          GetCurrentAccountCycleRange (v_oldPayerId, currentDate, v_oldPayerCycleStart, v_oldPayerCycleEnd);
          /* Check for current limitations */
          IF (v_oldPayerCycleStart <= v_newPayerStart AND v_newPayerEnd <= v_oldPayerCycleEnd) THEN
            RAISE_APPLICATION_ERROR (-20010,'Limitation: New payer cannot start and end in current billing cycle.');
          END IF;
                  
          /* Snapshot current recur window, that will be used as template */
          INSERT INTO TMP_OLDRW
          SELECT trw.c_CycleEffectiveDate,
                 trw.c_CycleEffectiveStart,
                 trw.c_CycleEffectiveEnd,
                 trw.c_SubscriptionStart,
                 trw.c_SubscriptionEnd,
                 trw.c_Advance,
                 trw.c__AccountID,
                 trw.c__PayingAccount,
                 trw.c__PriceableItemInstanceID,
                 trw.c__PriceableItemTemplateID,
                 trw.c__ProductOfferingID,
                 trw.c_PayerStart,
                 trw.c_PayerEnd,
                 trw.c__SubscriptionID,
                 trw.c_UnitValueStart,
                 trw.c_UnitValueEnd,
                 trw.c_UnitValue,
                 trw.c_BilledThroughDate,
                 trw.c_LastIdRun,
                 trw.c_MembershipStart,
                 trw.c_MembershipEnd
          FROM   t_recur_window trw
                 JOIN TMP_REDIR r
                      ON  trw.c__AccountID = r.Payee
                      AND trw.c__PayingAccount = r.OldPayer
                      AND trw.c_PayerStart = r.OldStart
                      AND trw.c_PayerEnd = r.OldEnd;

          /* Populate recur window for date range of new payer, to charge new payer and refund old payer */
          INSERT INTO TMP_NEW_RW_PAYER
          SELECT r.BillRangeStart,
                 r.BillRangeEnd,
                 rw.c_CycleEffectiveDate,
                 rw.c_CycleEffectiveStart,
                 rw.c_CycleEffectiveEnd,
                 rw.c_SubscriptionStart,
                 rw.c_SubscriptionEnd,
                 rw.c_Advance,
                 rw.c__AccountID,
                 v_newPayerId AS c__PayingAccount_New,
                 v_oldPayerId AS c__PayingAccount_Old, /* Temp additional field. Is used only for metering 'Credit' charges below. */
                 rw.c__PriceableItemInstanceID,
                 rw.c__PriceableItemTemplateID,
                 rw.c__ProductOfferingID,
                 dbo.MTMinOfTwoDates(v_oldPayerStart, v_newPayerStart) AS c_PayerStart, /* Get maximum Payer range for charging. */
                 dbo.MTMaxOfTwoDates(v_newPayerEnd, v_oldPayerEnd) AS c_PayerEnd,
                 rw.c__SubscriptionID,
                 rw.c_UnitValueStart,
                 rw.c_UnitValueEnd,
                 rw.c_UnitValue,
                 rw.c_BilledThroughDate,
                 rw.c_LastIdRun,
                 rw.c_MembershipStart,
                 rw.c_MembershipEnd,
                 AllowInitialArrersCharge(rw.c_Advance, rw.c__PayingAccount, rw.c_SubscriptionEnd, currentDate, 0 ) AS c__IsAllowGenChargeByTrigger
          FROM   TMP_OLDRW rw
                 JOIN TMP_REDIR r
                      ON  rw.c__AccountID = r.Payee
                      AND rw.c__PayingAccount = r.OldPayer;

          MeterPayerChangeFromRecWind(currentDate);
          
          /* Update payer dates in t_recur_window */

          /* If ranges of Old and New payer are the same - just update Payer ID */
          IF( v_NewRangeInsideOld = '=' ) THEN
            UPDATE t_recur_window
            SET    c__PayingAccount = v_newPayerId
            WHERE  c__PayingAccount = v_oldPayerId
                   AND c_PayerStart = v_newPayerStart
                   AND c_PayerEnd = v_newPayerEnd
                   AND EXISTS(
                        SELECT 1 FROM TMP_OLDRW orw
                        WHERE t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
                              AND t_recur_window.c__SubscriptionID = orw.c__SubscriptionID);
          /* If New payer range inside Old payer range:
             1. Update Old Payer Dates;
             2. Insert New Payer recur window.*/
          ELSIF (v_NewRangeInsideOld = 'Y') THEN
            /* Old payer now ends just before new payer start, if new payer after old one (have common end dates). */
            IF (v_newPayerEnd = v_oldPayerEnd) THEN
              UPDATE t_recur_window
              SET    c_PayerEnd = dbo.SubtractSecond(v_newPayerStart)
              WHERE  c__PayingAccount = v_oldPayerId
                     AND c_PayerStart = v_oldPayerStart
                     AND c_PayerEnd = v_oldPayerEnd
                     AND EXISTS(
                          SELECT 1 FROM TMP_OLDRW orw
                          WHERE t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
                                AND t_recur_window.c__SubscriptionID = orw.c__SubscriptionID);
            /* Old payer now starts right after new payer ends, if new payer before old one. */
            ELSIF (v_newPayerStart = v_oldPayerStart) THEN
              UPDATE t_recur_window
              SET    c_PayerStart = dbo.AddSecond(v_newPayerEnd)
              WHERE  c__PayingAccount = v_oldPayerId
                     AND c_PayerStart = v_oldPayerStart
                     AND c_PayerEnd = v_oldPayerEnd
                     AND EXISTS(
                          SELECT 1 FROM TMP_OLDRW orw
                          WHERE t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
                                AND t_recur_window.c__SubscriptionID = orw.c__SubscriptionID);
            ELSE
              RAISE_APPLICATION_ERROR (-20010,'Limitation: New and Old payer ranges should either have a common start date or common end date.');
            END IF;

            /* Insert New Payer recur window */
            INSERT INTO t_recur_window
            SELECT DISTINCT c_CycleEffectiveDate,
                   c_CycleEffectiveStart,
                   c_CycleEffectiveEnd,
                   c_SubscriptionStart,
                   c_SubscriptionEnd,
                   c_Advance,
                   c__AccountID,
                   c__PayingAccount_New,
                   c__PriceableItemInstanceID,
                   c__PriceableItemTemplateID,
                   c__ProductOfferingID,
                   v_newPayerStart AS c_PayerStart,
                   v_newPayerEnd AS c_PayerEnd,
                   c__SubscriptionID,
                   c_UnitValueStart,
                   c_UnitValueEnd,
                   c_UnitValue,
                   c_BilledThroughDate,
                   c_LastIdRun,
                   c_MembershipStart,
                   c_MembershipEnd,
                   NULL
            FROM   TMP_NEW_RW_PAYER;
    
          /* If Old payer range inside New payer range:
             1. Delete Old Payer range from recur window;
             2. Update New Payer Dates. */
          ELSIF (v_NewRangeInsideOld = 'N') THEN
            DELETE
            FROM   t_recur_window
            WHERE  EXISTS (SELECT 1 FROM TMP_OLDRW orw
                           WHERE  t_recur_window.c__PayingAccount = v_oldPayerId
                                  AND t_recur_window.c_PayerStart >= v_newPayerStart
                                  AND t_recur_window.c_PayerEnd <= v_newPayerEnd
                                  AND t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
                                  AND t_recur_window.c__SubscriptionID = orw.c__SubscriptionID
                          );
            UPDATE t_recur_window
            SET    c_PayerStart = v_newPayerStart,
                   c_PayerEnd = v_newPayerEnd
            WHERE  c__PayingAccount = v_newPayerId
                   AND (c_PayerStart = v_newPayerStart OR c_PayerEnd = v_newPayerEnd)
                   AND EXISTS(
                        SELECT 1 FROM TMP_OLDRW orw
                        WHERE t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
                              AND t_recur_window.c__SubscriptionID = orw.c__SubscriptionID);
          ELSE
            RAISE_APPLICATION_ERROR (-20010,'Unable to determine is new payer range inside old payer, vice-versa or they are the same.');
          END IF;
          
          /* TODO: Do we need this UPDATE? */
          UPDATE t_recur_window w1
          SET    c_CycleEffectiveEnd = (
                     SELECT MIN(NVL(w2.c_CycleEffectiveDate, w2.c_SubscriptionEnd))
                     FROM   t_recur_window w2
                     WHERE  w2.c__SubscriptionID = w1.c__SubscriptionID
                            AND w1.c_PayerStart = w2.c_PayerStart
                            AND w1.c_PayerEnd = w2.c_PayerEnd
                            AND w1.c_UnitValueStart = w2.c_UnitValueStart
                            AND w1.c_UnitValueEnd = w2.c_UnitValueEnd
                            AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
                 )
          WHERE  EXISTS 
                 (
                     SELECT 1
                     FROM   t_recur_window w2
                     WHERE  w2.c__SubscriptionID = w1.c__SubscriptionID
                            AND w1.c_PayerStart = w2.c_PayerStart
                            AND w1.c_PayerEnd = w2.c_PayerEnd
                            AND w1.c_UnitValueStart = w2.c_UnitValueStart
                            AND w1.c_UnitValueEnd = w2.c_UnitValueEnd
                            AND w2.c_CycleEffectiveDate > w1.c_CycleEffectiveDate
                 );
        END;
      END IF;
    END IF;
  END AFTER STATEMENT;
END;
