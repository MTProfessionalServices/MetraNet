CREATE TRIGGER trig_update_t_recur_window_with_t_payment_redirection
ON t_payment_redirection FOR INSERT, DELETE
/* Trigger always processing a single change related to update of 1 date range of 1 payee */
AS
BEGIN
  IF @@ROWCOUNT = 0 RETURN;

  DECLARE @currentDate DATETIME;
  SELECT @currentDate = h.tt_start
  FROM   INSERTED i
         JOIN t_payment_redir_history h
              ON  h.id_payee = i.id_payee
              AND h.id_payer = i.id_payer
              AND h.tt_end = dbo.MTMaxDate();

  IF EXISTS (SELECT * FROM DELETED)
  BEGIN
    /* Create shared table, if it wasn't created yet by another session */
    IF OBJECT_ID('tempdb..##p_redir_deleted') IS NULL 
      SELECT @@SPID spid, * INTO ##p_redir_deleted FROM t_payment_redirection WHERE 1=0;

    INSERT INTO ##p_redir_deleted SELECT @@SPID spid, * FROM DELETED;    
    RETURN;
  END;

  IF EXISTS (SELECT * FROM INSERTED)
  BEGIN
    IF OBJECT_ID('tempdb..##p_redir_deleted') IS NULL
      RETURN;
    IF NOT EXISTS (SELECT * FROM ##p_redir_deleted WHERE spid = @@SPID)
      RETURN; /* This is not Payer update. This is account creation. */

    /* Skip rows, that are the same.
       Skip new date ranges, if they are inside old range of the same payer. (was already billed)  */
    SELECT *
    INTO  #new_payer_range
    FROM  INSERTED new
    WHERE NOT EXISTS (
          SELECT 1
          FROM   ##p_redir_deleted old
          WHERE  spid = @@SPID
             AND old.id_payer = new.id_payer
             AND old.id_payee = new.id_payee
             /* Same or inside old range */
             AND old.vt_start <= new.vt_start AND new.vt_end <= old.vt_end
          )

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
          INTO #tmp_redir
    FROM   #new_payer_range new
          JOIN ##p_redir_deleted old
            ON old.id_payee = new.id_payee AND old.id_payer <> new.id_payer
              AND new.vt_start = old.vt_start AND old.vt_end = new.vt_end /* Old range the same as new one */

    IF NOT EXISTS ( SELECT 1 FROM #tmp_redir)
    BEGIN
      INSERT INTO #tmp_redir
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
      FROM   #new_payer_range new
            JOIN ##p_redir_deleted old
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
      FROM   #new_payer_range new
            JOIN ##p_redir_deleted old
              ON old.id_payee = new.id_payee AND old.id_payer <> new.id_payer
                AND new.vt_start <= old.vt_start AND old.vt_end <= new.vt_end /* Old range inside new one */
    END;

    /* Clean-up temp data of my session */
    DELETE FROM ##p_redir_deleted WHERE spid = @@SPID;
  END;

  /* Double-check that we detected payer change. */
  IF NOT EXISTS ( SELECT 1 FROM #tmp_redir)
    THROW 50000,'Fail to retrieve payer change information. #tmp_redir is empty.',1

  DECLARE @oldPayerCycleStart DATETIME,
          @oldPayerCycleEnd DATETIME,
          @oldPayerId INT,
          @newPayerStart DATETIME,
          @newPayerEnd DATETIME,
          @newPayerId INT

  SELECT TOP 1 @newPayerStart = NewStart, @newPayerEnd = NewEnd, @newPayerId = NewPayer, @oldPayerId = OldPayer FROM #tmp_redir;
  EXEC GetCurrentAccountCycleRange @id_acc = @oldPayerId, @curr_date = @currentDate,
                                   @StartCycle = @oldPayerCycleStart OUT, @EndCycle = @oldPayerCycleEnd OUT;                                   
  /* Check for current limitations */
  IF @oldPayerCycleStart <= @newPayerStart AND @newPayerEnd <= @oldPayerCycleEnd
    THROW 50000,'Limitation: New payer cannot start and end in current billing cycle.',1

  /* TODO: Check limitation "Payer starts before current interval start"
         This is not working in some scenarios. Not proper check - correct this.
  IF @newPayerStart <= @oldPayerCycleStart
    THROW 50000,'Limitation: New payer cannot start before the start of current billing interval.',1    
  IF @newPayerEnd <= @oldPayerCycleEnd
    THROW 50000,'Limitation: New payer cannot end before the start of next billing interval.',1
  */
  /* TODO: Check scenario where new payer replaces > 1 old payer */

  /* Snapshot current recur window, that will be used as template */
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
         trw.c_MembershipEnd,
         dbo.AllowInitialArrersCharge(trw.c_Advance, trw.c__PayingAccount, trw.c_SubscriptionEnd, @currentDate, 0 ) AS c__IsAllowGenChargeByTrigger
         INTO #old_rw
  FROM   t_recur_window trw
         JOIN #tmp_redir r
              ON  trw.c__AccountID = r.Payee
              AND trw.c__PayingAccount = r.OldPayer
              AND trw.c_PayerStart = r.OldStart
              AND trw.c_PayerEnd = r.OldEnd;

  /* Populate recur window for date range of new payer, to charge new payer and refund old payer */
  SELECT rw.c_CycleEffectiveDate,
         rw.c_CycleEffectiveStart,
         rw.c_CycleEffectiveEnd,
         rw.c_SubscriptionStart,
         rw.c_SubscriptionEnd,
         rw.c_Advance,
         rw.c__AccountID,
         r.NewPayer AS c__PayingAccount_New,
         r.OldPayer AS c__PayingAccount_Old, /* Temp additional field. Is used only for metering 'Credit' charges below. */
         rw.c__PriceableItemInstanceID,
         rw.c__PriceableItemTemplateID,
         rw.c__ProductOfferingID,
         r.BillRangeStart AS c_PayerStart, /* TODO: Don't use c_PayerStart / c_PayerEnd words here */
         r.BillRangeEnd AS c_PayerEnd,
         rw.c__SubscriptionID,
         rw.c_UnitValueStart,
         rw.c_UnitValueEnd,
         rw.c_UnitValue,
         rw.c_BilledThroughDate,
         rw.c_LastIdRun,
         rw.c_MembershipStart,
         rw.c_MembershipEnd,
         rw.c__IsAllowGenChargeByTrigger
         INTO #recur_window_holder
  FROM   #old_rw rw
         JOIN #tmp_redir r
              ON  rw.c__AccountID = r.Payee
              AND rw.c__PayingAccount = r.OldPayer;

  /* TODO: Fix scenarios:
           1. Account is paid by P1 and P2 in future. Updating so that P2 is paying for all period;
           2. If new payer starts after EOP old payer won't get instant charge for big RCs (e.g.: Annual PI). */
  EXEC MeterPayerChangesFromRecurWindow @currentDate;

  /* Update payer dates in t_recur_window */

  /* If ranges of Old and New payer are the same - just update Payer ID */
  IF EXISTS (SELECT * FROM #tmp_redir WHERE NewRangeInsideOld = '=')
  BEGIN
    UPDATE rw
    SET    c__PayingAccount = @newPayerId
    FROM   t_recur_window rw
           JOIN #old_rw orw
              ON rw.c__ProductOfferingID = orw.c__ProductOfferingID
              AND rw.c__SubscriptionID = orw.c__SubscriptionID
    WHERE  rw.c__PayingAccount = @oldPayerId
           AND rw.c_PayerStart = @newPayerStart
           AND rw.c_PayerEnd = @newPayerEnd;
  END
  /* If New payer range inside Old payer range:
     1. Update Old Payer Dates;
     2. Insert New Payer recur window.*/
  ELSE IF EXISTS (SELECT * FROM #tmp_redir WHERE NewRangeInsideOld = 'Y')
  BEGIN
    /* TODO: Handle case when new Payer does not have common Start Or End with Old payer. */
    IF EXISTS (SELECT * FROM t_recur_window rw
               JOIN #old_rw orw
                  ON  rw.c__PayingAccount = orw.c__PayingAccount AND rw.c__ProductOfferingID = orw.c__ProductOfferingID
                  AND rw.c_PayerStart = orw.c_PayerStart AND rw.c_PayerEnd = orw.c_PayerEnd
                  AND rw.c__SubscriptionID = orw.c__SubscriptionID
               WHERE  orw.c_PayerStart <> @newPayerStart AND orw.c_PayerEnd <> @newPayerEnd)
      THROW 50000,'Limitation: New and Old payer ranges should either have a common start date or common end date.',1

    /* Update Old Payer Dates */
    UPDATE rw
    SET    c_PayerEnd = dbo.SubtractSecond(@newPayerStart)
    FROM   t_recur_window rw
           JOIN #old_rw orw
              ON  rw.c__PayingAccount = orw.c__PayingAccount
              AND rw.c__ProductOfferingID = orw.c__ProductOfferingID
              AND rw.c_PayerStart = orw.c_PayerStart
              AND rw.c_PayerEnd = orw.c_PayerEnd
              AND rw.c__SubscriptionID = orw.c__SubscriptionID
    WHERE  orw.c_PayerStart <> @newPayerStart;
  
    UPDATE rw
    SET    c_PayerStart = dbo.AddSecond(@newPayerEnd)
    FROM   t_recur_window rw
           JOIN #old_rw orw
              ON  rw.c__PayingAccount = orw.c__PayingAccount
              AND rw.c__ProductOfferingID = orw.c__ProductOfferingID
              AND rw.c_PayerStart = orw.c_PayerStart
              AND rw.c_PayerEnd = orw.c_PayerEnd
              AND rw.c__SubscriptionID = orw.c__SubscriptionID
    WHERE  orw.c_PayerEnd <> @newPayerEnd;
    
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
           @newPayerStart AS c_PayerStart,
           @newPayerEnd AS c_PayerEnd,
           c__SubscriptionID,
           c_UnitValueStart,
           c_UnitValueEnd,
           c_UnitValue,
           c_BilledThroughDate,
           c_LastIdRun,
           c_MembershipStart,
           c_MembershipEnd
    FROM   #recur_window_holder;
  END
  /* If Old payer range inside New payer range:
     1. Delete Old Payer range from recur window;
     2. Update New Payer Dates. */
  ELSE IF EXISTS (SELECT * FROM #tmp_redir WHERE NewRangeInsideOld = 'N')
  BEGIN
    /* TODO: Handle case when new Payer does not have common Start Or End with Old payer. */
    IF EXISTS (SELECT * FROM t_recur_window rw
               JOIN #old_rw orw
                  ON  rw.c__PayingAccount = orw.c__PayingAccount AND rw.c__ProductOfferingID = orw.c__ProductOfferingID
                  AND rw.c_PayerStart = orw.c_PayerStart AND rw.c_PayerEnd = orw.c_PayerEnd
                  AND rw.c__SubscriptionID = orw.c__SubscriptionID
               WHERE  orw.c_PayerStart <> @newPayerStart AND orw.c_PayerEnd <> @newPayerEnd)
      THROW 50000,'Limitation: New and Old payer ranges should either have a common start date or common end date.',1

    DELETE
    FROM   t_recur_window
    WHERE  EXISTS (SELECT 1 FROM #old_rw orw
                   WHERE  t_recur_window.c__PayingAccount = @oldPayerId
                          AND t_recur_window.c_PayerStart >= @newPayerStart
                          AND t_recur_window.c_PayerEnd <= @newPayerEnd
                          AND t_recur_window.c__ProductOfferingID = orw.c__ProductOfferingID
                          AND t_recur_window.c__SubscriptionID = orw.c__SubscriptionID
                  );
    UPDATE rw
    SET    c_PayerStart = @newPayerStart,
           c_PayerEnd = @newPayerEnd
    FROM   t_recur_window rw
           JOIN #old_rw orw
              ON rw.c__ProductOfferingID = orw.c__ProductOfferingID
              AND rw.c__SubscriptionID = orw.c__SubscriptionID
    WHERE  rw.c__PayingAccount = @newPayerId
           AND (rw.c_PayerStart = @newPayerStart OR rw.c_PayerEnd = @newPayerEnd)
  END
  ELSE
    THROW 50000,'Unable to determine is new payer range inside old payer, vice-versa or they are the same.',1

  /* TODO: Do we need this UPDATE? */
  UPDATE t_recur_window
  SET    c_CycleEffectiveEnd = (
             SELECT MIN(ISNULL(c_CycleEffectiveDate, c_SubscriptionEnd))
             FROM   t_recur_window w2
             WHERE  w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
                    AND t_recur_window.c_PayerStart = w2.c_PayerStart
                    AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
                    AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
                    AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
                    AND t_recur_window.c_membershipstart = w2.c_membershipstart
                    AND t_recur_window.c_membershipend = w2.c_membershipend
                    AND t_recur_window.c__accountid = w2.c__accountid
                    AND t_recur_window.c__payingaccount = w2.c__payingaccount
                    AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
         )
  WHERE  c__PayingAccount IN (SELECT c__PayingAccount_New FROM #recur_window_holder)
         AND EXISTS
             (
                 SELECT 1
                 FROM   t_recur_window w2
                 WHERE  w2.c__SubscriptionId = t_recur_window.c__SubscriptionId
                        AND t_recur_window.c_PayerStart = w2.c_PayerStart
                        AND t_recur_window.c_PayerEnd = w2.c_PayerEnd
                        AND t_recur_window.c_UnitValueStart = w2.c_UnitValueStart
                        AND t_recur_window.c_UnitValueEnd = w2.c_UnitValueEnd
                        AND t_recur_window.c_membershipstart = w2.c_membershipstart
                        AND t_recur_window.c_membershipend = w2.c_membershipend
                        AND t_recur_window.c__accountid = w2.c__accountid
                        AND t_recur_window.c__payingaccount = w2.c__payingaccount
                        AND w2.c_CycleEffectiveDate > t_recur_window.c_CycleEffectiveDate
             );
END;
