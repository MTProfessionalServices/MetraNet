CREATE OR REPLACE 
PACKAGE BODY mt_acc_template
AS
    detailtypesubs      INT;
    detailresultfailure INT;

    PROCEDURE subscribe_account(
       id_acc              INT,
       id_po               INT,
       id_group            INT,
       sub_start           DATE,
       sub_end             DATE,
       systemdate          DATE,
       doCommit            CHAR DEFAULT 'Y'
    )
    AS
        v_guid                RAW(16);
        curr_id_sub           INT;
    BEGIN
        IF (id_group IS NOT NULL) THEN
            INSERT INTO tmp_gsubmember (id_group, id_acc, vt_start, vt_end)
                VALUES (id_group, id_acc, sub_start, sub_end);
        ELSE
            getcurrentid('id_subscription', curr_id_sub);
            SELECT SYS_GUID() INTO v_guid FROM dual;
            INSERT INTO tmp_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
                VALUES (curr_id_sub, v_guid, id_acc, NULL, id_po, systemdate, sub_start, sub_end);
        END IF;

    END;

    PROCEDURE apply_subscriptions (
       template_id                INT,
       sub_start                  DATE,
       sub_end                    DATE,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       id_event_failure           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT,
       doCommit                   CHAR DEFAULT 'Y'
    )
    AS
       my_id_audit           INT;
       my_error              VARCHAR2(1024);
       my_id_acc             INT;
       maxdate               DATE;
       audit_msg             VARCHAR2(256);
    BEGIN
        IF (my_id_audit IS NULL)
        THEN
           IF (apply_subscriptions.id_audit IS NOT NULL)
           THEN
              my_id_audit := apply_subscriptions.id_audit;
           ELSE
              getcurrentid ('id_audit', my_id_audit);
              INSERT INTO t_audit (
                    id_audit,
                    id_event,
                    id_userid,
                    id_entitytype,
                    id_entity,
                    dt_crt
                 )
              VALUES (
                    my_id_audit,
                    apply_subscriptions.id_event_failure,
                    apply_subscriptions.user_id,
                    1,
                    my_id_acc,
                    getutcdate ()
                 );
           END IF;
        END IF;

        IF detailtypesubs IS NULL THEN
            SELECT id_enum_data
            INTO   detailtypesubs
            FROM   t_enum_data
            WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription';

            SELECT id_enum_data
            INTO   detailresultfailure
            FROM   t_enum_data
            WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure';
         END IF;

      DELETE FROM t_acc_template_valid_subs WHERE id_acc_template_session = apply_subscriptions.id_template_session;
      /* Detect conflicting subscriptions in the template and choice first available of them and without conflicts */
      INSERT INTO t_acc_template_valid_subs (id_acc_template_session, id_po, id_group, sub_start, sub_end, po_start, po_end)
      SELECT DISTINCT
           apply_subscriptions.id_template_session,
           subs.id_po,
           subs.id_group,
           subs.sub_start,
           subs.sub_end,
           subs.sub_start,
           subs.sub_end
      FROM
        (
            SELECT t1.id_po, MAX(t1.id_group) AS id_group, GREATEST(MAX(ed.dt_start), t1.vt_start) AS sub_start, LEAST(NVL(MAX(ed.dt_end), mtmaxdate()), t1.vt_end) AS sub_end
                FROM (
                    SELECT NVL(ts.id_po,s.id_po) AS id_po, s.id_group, ts.vt_start, ts.vt_end
                        FROM t_acc_template_subs ts
                        LEFT JOIN t_sub s ON s.id_group = ts.id_group
                        WHERE ts.id_acc_template = apply_subscriptions.template_id
                ) t1
                JOIN t_po po ON po.id_po = t1.id_po
                JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
                GROUP BY t1.id_po, t1.vt_start, t1.vt_end
        ) subs;

       /* Applying subscriptions to accounts */
      FOR rec IN (
         SELECT id_descendent AS id_acc
         FROM   t_vw_get_accounts_by_tmpl_id v
         WHERE  v.id_template = apply_subscriptions.template_id)
      LOOP
           my_id_acc := rec.id_acc;
           apply_subscriptions_to_acc (
               id_acc                     => rec.id_acc,
               id_acc_template            => apply_subscriptions.template_id,
               next_cycle_after_startdate => apply_subscriptions.next_cycle_after_startdate,
               next_cycle_after_enddate   => apply_subscriptions.next_cycle_after_enddate,
               user_id                    => apply_subscriptions.user_id,
               id_audit                   => my_id_audit,
               id_event_success           => apply_subscriptions.id_event_success,
               systemdate                 => apply_subscriptions.systemdate,
               id_template_session        => apply_subscriptions.id_template_session,
               retrycount                 => apply_subscriptions.retrycount
           );
      END LOOP;

      maxdate := mtmaxdate();

      mt_rate_pkg.current_id_audit := apply_subscriptions.id_audit;

      INSERT INTO t_gsubmember_historical (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
      SELECT id_group, id_acc, vt_start, NVL(vt_end, maxdate), apply_subscriptions.systemdate, maxdate
      FROM   tmp_gsubmember;

      INSERT INTO t_gsubmember (id_group, id_acc, vt_start, vt_end)
      SELECT tmp.id_group, tmp.id_acc, tmp.vt_start, NVL(tmp.vt_end, maxdate)
      FROM   tmp_gsubmember tmp;

      INSERT INTO t_sub_history (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, tt_start, tt_end)
      SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, NVL(vt_end, maxdate), apply_subscriptions.systemdate, maxdate
      FROM   tmp_sub;

      INSERT INTO t_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
      SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, NVL(vt_end, maxdate)
      FROM   tmp_sub;

      INSERT INTO t_audit_details (id_auditdetails, id_audit, tx_details)
      SELECT seq_t_audit_details.NEXTVAL, tmp.my_id_audit, tmp.tx_details
      FROM   (
              SELECT my_id_audit AS my_id_audit,
                     'Added subscription to id_groupsub ' || id_group ||
                     ' for account ' || id_acc ||
                     ' from ' || vt_start ||
                     ' to ' || NVL(vt_end, maxdate) ||
                     ' on ' || systemdate AS tx_details
              FROM   tmp_gsubmember
              UNION ALL
              SELECT my_id_audit AS my_id_audit,
                     'Added subscription to product offering ' || id_po ||
                     ' for account ' || id_acc ||
                     ' from ' || vt_start ||
                     ' to ' || NVL(vt_end, maxdate) ||
                     ' on ' || apply_subscriptions.systemdate AS tx_details
              FROM   tmp_sub
             ) tmp;
      IF (doCommit = 'Y')
      THEN
      COMMIT;
      END IF;

      mt_rate_pkg.current_id_audit := NULL;
      DELETE FROM t_acc_template_valid_subs WHERE id_acc_template_session = apply_subscriptions.id_template_session;
    END;

    PROCEDURE apply_subscriptions_to_acc (
       id_acc                     INT,
       id_acc_template            INT,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT,
       doCommit                   CHAR DEFAULT 'Y'
    )
    AS
       v_acc_start       DATE;
       v_vt_start        DATE;
       v_vt_end          DATE;
       v_sub_start       DATE;
       v_sub_end         DATE;
       curr_id_sub       INT;
       my_id_audit       INT;
       my_user_id        INT;
       id_acc_type       INT;
       v_prev_start DATE;
       v_prev_end   DATE;

    BEGIN
       my_user_id := apply_subscriptions_to_acc.user_id;

       IF (my_user_id IS NULL)
       THEN
          my_user_id := 1;
       END IF;
       my_id_audit := apply_subscriptions_to_acc.id_audit;

       IF (my_id_audit IS NULL)
       THEN
          getcurrentid ('id_audit', my_id_audit);
          
          INSERT INTO t_audit
                      (id_audit, id_event, id_userid, id_entitytype, id_entity,
                       dt_crt
                      )
               VALUES (my_id_audit, apply_subscriptions_to_acc.id_event_success, apply_subscriptions_to_acc.user_id, 1, apply_subscriptions_to_acc.id_acc,
                       getutcdate ()
                      );
       END IF;

       SELECT vt_start
       INTO   v_acc_start
       FROM   t_account_state
       WHERE  id_acc = apply_subscriptions_to_acc.id_acc;

       SELECT id_type
       INTO   id_acc_type
       FROM   t_account
       WHERE  id_acc = apply_subscriptions_to_acc.id_acc;
       /* Create new subscriptions */
       FOR sub IN (
        SELECT
            id_po,
            id_group,
            CASE
                WHEN apply_subscriptions_to_acc.next_cycle_after_startdate = 'Y'
                THEN
                    (
                        SELECT GREATEST(tpc.dt_end + numtodsinterval(1, 'second'), tvs.po_start)
                            FROM   t_pc_interval tpc
                            INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
                            WHERE  tauc.id_acc = apply_subscriptions_to_acc.id_acc
                            AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
                    )
                ELSE tvs.sub_start
            END AS v_sub_start,
            CASE
                WHEN apply_subscriptions_to_acc.next_cycle_after_enddate = 'Y'
                THEN
                    (
                        SELECT LEAST(LEAST(tpc.dt_end + numtodsinterval(1, 'second'), mtmaxdate()), tvs.po_end)
                            FROM   t_pc_interval tpc
                            INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
                            WHERE  tauc.id_acc = apply_subscriptions_to_acc.id_acc
                            AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
                    )
                ELSE tvs.sub_end
            END AS v_sub_end
            FROM t_acc_template_valid_subs tvs
            WHERE tvs.id_acc_template_session = apply_subscriptions_to_acc.id_template_session
       )
       LOOP
            v_prev_end := sub.v_sub_start - 1;
            FOR c_sub IN (
                SELECT S.*
                    FROM t_sub s
                    WHERE s.vt_end >= sub.v_sub_start
                        AND s.vt_start <= sub.v_sub_end
                        AND s.id_acc = apply_subscriptions_to_acc.id_acc
                        AND s.id_po = sub.id_po
                    ORDER BY s.vt_start
            )
            LOOP
                IF c_sub.vt_start > v_prev_end THEN
                    v_vt_start := v_prev_end + 1;
                    v_vt_end := c_sub.vt_start - 1;
                END IF;
                IF v_vt_start <= v_vt_end THEN
                    subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate, doCommit);
                END IF;
                v_prev_end := c_sub.vt_end;
            END LOOP;
            IF (v_prev_end < sub.v_sub_end) THEN
                v_vt_start := v_prev_end + 1;
                v_vt_end := sub.v_sub_end;
                subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate, doCommit);
            END IF;
       END LOOP;
    END;

    PROCEDURE UpdateAccPropsFromTemplate (
      idAccountTemplate INT,
      systemDate DATE,
      idAcc INT DEFAULT NULL
    )
    AS
        vals VARCHAR2(32767);
        dSql VARCHAR2(32767);
        conditionStatement VARCHAR2(32767);
        enumValue VARCHAR2(256);
        val1 VARCHAR2(256);
        val2 VARCHAR2(256);
    BEGIN
        FOR rec IN (
            SELECT
                DISTINCT(v.account_view_name) AS viewName,
                't_av_'|| SUBSTR(td.nm_enum_data, INSTR (td.nm_enum_data, '/') + 1, LENGTH(td.nm_enum_data)) AS tableName,
                CASE WHEN INSTR(tp.nm_prop, ']') <> 0
                THEN SUBSTR(tp.nm_prop, INSTR(tp.nm_prop, '[') + 1, INSTR(tp.nm_prop, ']') - INSTR(tp.nm_prop, '[') - 1)
                ELSE NULL
                END AS additionalOptionString
            FROM t_enum_data td JOIN t_account_type_view_map v ON v.id_account_view = td.id_enum_data
            JOIN t_account_view_prop p ON v.id_type = p.id_account_view
            JOIN t_acc_template_props tp ON tp.nm_prop LIKE v.account_view_name || '%' AND tp.nm_prop LIKE '%' || p.nm_name
            WHERE tp.id_acc_template = idAccountTemplate)
        LOOP
            vals := NULL;
            FOR val IN (
                SELECT
                    --"Magic numbers" were took FROM MetraTech.Interop.MTYAAC.PropValType enumeration.
                    CASE WHEN ROWNUM = 1 THEN NULL ELSE ',' END ||
                    nm_column_name || ' ' ||
                        CASE
                            WHEN nm_prop_class IN(0, 1, 4, 5, 6, 8, 9, 12, 13)
                            THEN ' = ''' || REPLACE(TO_CHAR(nm_value), '''', '''''') || ''' '
                            WHEN nm_prop_class IN(2, 3, 10, 11, 14)
                            THEN ' = ' || REPLACE(TO_CHAR(nm_value), '''', '''''') || ' '
                            WHEN nm_prop_class = 7
                            THEN
                                CASE
                                    WHEN UPPER(nm_value) = 'TRUE'
                                    THEN ' = 1 '
                                    ELSE ' = 0 '
                                END
                            ELSE ''''' '
                        END AS colVal

                FROM t_account_type_view_map v
                JOIN t_account_view_prop p ON v.id_type = p.id_account_view
                JOIN t_acc_template_props tp ON tp.nm_prop LIKE v.account_view_name || '%' AND tp.nm_prop LIKE '%.' || REPLACE(REPLACE(REPLACE(p.nm_name, N'\', N'\\'), N'_', N'\_'), N'%', N'\%') ESCAPE N'\'
                WHERE tp.id_acc_template = idAccountTemplate AND tp.nm_prop LIKE rec.viewName || '%')
            LOOP
                vals := vals || val.colVal;
            END LOOP;

            conditionStatement := NULL;
            IF(rec.additionalOptionString IS NOT NULL) THEN
                -- Processing enum values
                FOR item IN (SELECT items AS conditionItem FROM TABLE(SplitStringByChar(rec.additionalOptionString,',')))
                LOOP

                    val1 := SUBSTR(item.conditionItem, 0, INSTR(item.conditionItem, '=') - 1);

                    val2 := SUBSTR(item.conditionItem, INSTR(item.conditionItem, '=') + 1, LENGTH(item.conditionItem) - INSTR(item.conditionItem, '=') + 1);
                    val2 := REPLACE(val2, '_', '-');

                    --Select value fot additional condition by namespace and name of enum.
                    SELECT id_enum_data
                      INTO enumValue
                      FROM t_enum_data
                     WHERE UPPER(nm_enum_data) =
                        (SELECT UPPER(nm_space || '/' || nm_enum || '/' || val2)
                        FROM t_account_type_view_map v JOIN t_account_view_prop p ON v.id_type = p.id_account_view
                        WHERE UPPER(account_view_name) = UPPER(rec.viewName) AND UPPER(nm_name) = UPPER(val1));

                    --Creation additional condition for update account view properties for each account view.
                    conditionStatement := conditionStatement || 'c_' || val1 || ' = ' || TO_CHAR(enumValue) || ' AND ';
                END LOOP;
            END IF;

            --Completion to creation dynamic sql-string for update account view.
            IF (idAcc IS NOT NULL) THEN
                conditionStatement := conditionStatement || 'id_acc = ' || TO_CHAR(idAcc) || ' ';
            ELSE
                conditionStatement := conditionStatement || 'id_acc in (SELECT id_descendent FROM t_vw_get_accounts_by_tmpl_id WHERE id_template = ' || TO_CHAR(idAccountTemplate) || '  AND CAST(''' || TO_CHAR(systemDate) || ''' AS DATE) BETWEEN COALESCE(vt_start, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)) AND COALESCE(vt_end, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)))';
            END IF;
            dSql := 'UPDATE ' || rec.tableName || ' SET ' || vals || ' WHERE ' || conditionStatement;
            EXECUTE IMMEDIATE dSql;
        END LOOP;
    END;

    PROCEDURE UpdateUsageCycleFromTemplate (
        IdAcc INT
        ,UsageCycleId INT
        ,OldUsageCycle INT
        ,systemDate DATE
    )
    AS
        p_status INT;
        intervalenddate DATE;
        intervalID INT;
        pc_start DATE;
        pc_end DATE;
    BEGIN
        IF OldUsageCycle <> UsageCycleId AND UsageCycleId <> -1 THEN
            p_status := dbo.ISBILLINGCYCLEUPDPROHIBITEDBYG(systemDate, IdAcc);
            IF p_status = 1 THEN
                p_status := 0;
                UPDATE t_acc_usage_cycle
                   SET id_usage_cycle = UsageCycleId
                 WHERE id_acc = IdAcc;

                  -- post-operation business rule check (relies on rollback of work done up until this point)
                  -- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's
                  -- group subscription BCR constraints
                SELECT NVL(MIN(dbo.CHECKGROUPMEMBERSHIPCYCLECONST(systemDate, "groups".id_group)), 1)
                  INTO p_status
                  FROM (
                        -- gets all of the payer's payee's and/or the payee's group subscriptions
                        SELECT DISTINCT gsm.id_group id_group
                            FROM t_gsubmember gsm
                            INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
                            WHERE pay.id_payer = IdAcc OR pay.id_payee = IdAcc
                      ) "groups";

                IF p_status = 1 THEN
                    p_status := 0;
                    -- deletes any mappings to intervals in the future from the old cycle
                    DELETE FROM t_acc_usage_interval
                        WHERE t_acc_usage_interval.id_acc = IdAcc
                        AND id_usage_interval IN (
                            SELECT id_interval
                                FROM t_usage_interval ui
                                INNER JOIN t_acc_usage_interval aui ON aui.id_acc = IdAcc AND aui.id_usage_interval = ui.id_interval
                                WHERE dt_start > systemDate
                        );

                    -- only one pending update is allowed at a time
                    -- deletes any previous update mappings which have not yet
                    -- transitioned (dt_effective is still in the future)
                    DELETE FROM t_acc_usage_interval
                        WHERE dt_effective IS NOT NULL
                            AND id_acc = IdAcc
                            AND dt_effective >= systemDate;

                    -- gets the current interval's end date
                    SELECT MAX(ui.dt_end)
                      INTO intervalenddate
                      FROM t_acc_usage_interval aui
                      INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval AND systemDate BETWEEN ui.dt_start AND ui.dt_end
                    WHERE aui.id_acc = IdAcc;

                    -- future dated accounts may not yet be associated with an interval (CR11047)
                    IF intervalenddate IS NOT NULL THEN
                        -- figures out the new interval ID based on the end date of the current interval
                        SELECT id_interval, dt_start, dt_end
                          INTO intervalID, pc_start, pc_end
                          FROM t_pc_interval
                        WHERE id_cycle = UsageCycleId
                          AND addsecond(intervalenddate) BETWEEN dt_start AND dt_end;

                        -- inserts the new usage interval if it doesn't already exist
                        -- (needed for foreign key relationship in t_acc_usage_interval)
                        INSERT INTO t_usage_interval
                            SELECT intervalID
                                    ,UsageCycleId
                                    ,pc_start
                                    ,pc_end
                                    ,'O'
                              FROM DUAL
                             WHERE NOT EXISTS (SELECT 1 FROM t_usage_interval WHERE id_interval = intervalID);

                        -- creates the special t_acc_usage_interval mapping to the interval of
                        -- new cycle. dt_effective is set to the end of the old interval.
                        INSERT INTO t_acc_usage_interval
                            SELECT IdAcc
                                    ,intervalID
                                    ,NVL(tx_interval_status, 'O')
                                    ,intervalenddate
                                FROM t_usage_interval
                                WHERE id_interval = intervalID
                                    AND tx_interval_status <> 'B';
                    END IF;
                END IF;
            END IF;
        END IF;
    END;

    PROCEDURE UpdatePayerFromTemplate (
        IdAcc INT
        ,PayerId INT
        ,systemDate DATE
        ,p_account_currency VARCHAR2
        ,sessionId INT
        ,DetailTypeSubscription INT
        ,DetailResultInformation INT
        ,nRetryCount INT
    )
    AS
        p_status INT;
        oldpayerstart DATE;
        oldpayerend DATE;
        oldpayer INT;
        payerenddate DATE;

        payerbillable VARCHAR2(1);
        accExists INT;
    BEGIN
        SELECT COUNT(1) INTO accExists FROM t_account WHERE id_acc = PayerID;
        IF accExists > 0 THEN
            payerenddate := dbo.MTMaxDate();
            -- find the old payment information
            SELECT MAX(vt_start), MAX(vt_end), MAX(id_payer)
              INTO oldpayerstart, oldpayerend, oldpayer
              FROM t_payment_redirection
             WHERE id_payee = IdAcc
               AND dbo.OverlappingDateRange(vt_start, vt_end, systemDate, dbo.mtmaxdate()) = 1;

            -- if the new record is in range of the old record and the payer is the same as the older payer,
            -- update the record
            IF (PayerID <> -1) THEN
                IF (PayerID = oldpayer) THEN
                    UpdatePaymentRecord (payerID, IdAcc, oldpayerstart, oldpayerend, systemDate, payerenddate, systemDate, 1, p_account_currency, p_status);

                    IF (p_status <> 1) THEN
                        InsertTmplSessionDetail
                        (
                            sessionId,
                            DetailTypeSubscription,
                            DetailResultInformation,
                            'No payment record changed. Return code is ' || TO_CHAR(p_status),
                            nRetryCount,
                            'N'
                        );
                        p_status := 0;
                    END IF;
                ELSE
                    payerbillable := dbo.IsAccountBillable(PayerID);
                    CreatePaymentRecord(payerID, IdAcc, systemDate, payerenddate, payerbillable, systemDate, 'N', 1, p_account_currency, p_status);
                    IF (p_status <> 1) THEN
                        InsertTmplSessionDetail
                        (
                            sessionId,
                            DetailTypeSubscription,
                            DetailResultInformation,
                            'No payment record created. Return code is ' || TO_CHAR(p_status),
                            nRetryCount,
                            'N'
                        );
                        p_status := 0;
                    END IF;
                END IF;
            END IF;
        END IF;
    END;

END mt_acc_template;
