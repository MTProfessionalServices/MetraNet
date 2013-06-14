
CREATE OR REPLACE PROCEDURE ApplyTemplateToAccounts(
    idAccountTemplate INTEGER,
    sessionId INTEGER,
    nRetryCount INTEGER,
    systemDate DATE
)
AS
    DetailTypeUpdate NUMBER(10);
    DetailResultSuccess NUMBER(10);
    DetailResultFailure NUMBER(10);

    DetailTypeGeneral NUMBER(10);
    DetailResultInformation NUMBER(10);
    DetailTypeSubscription NUMBER(10);
    tableName varchar2(256);
    additionalOptionString varchar2(256);

    vals VARCHAR2(32767);
    dSql VARCHAR2(32767);

    sucsesfullTransaction NUMBER(1);
    
    conditionStatement VARCHAR2(32767);
                    
    enumValue varchar2(256);
    val1 varchar2(256);
    val2 varchar2(256);

    UsageCycleId NUMBER(10);
    PayerId NUMBER(10);
    p_status NUMBER(10);
    intervalenddate DATE;
    intervalID NUMBER(10);
    pc_start DATE;
    pc_end DATE;
            
    oldpayerstart DATE;
    oldpayerend DATE;
    oldpayer NUMBER(10);
    payerenddate DATE;

    payerbillable VARCHAR2(1);
    accExists INTEGER;
BEGIN
    SELECT id_enum_data
      INTO DetailTypeUpdate
      FROM t_enum_data 
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Update';

    SELECT id_enum_data
      INTO DetailResultFailure
      FROM t_enum_data 
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure';
     
    SELECT id_enum_data
      INTO DetailResultSuccess
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success';


    SELECT id_enum_data
      INTO DetailTypeGeneral
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success';
     
    SELECT id_enum_data
      INTO DetailResultInformation
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information';
     
    SELECT id_enum_data
      INTO DetailTypeSubscription
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription';

    sucsesfullTransaction := 1;

    BEGIN

        --SELECT list of account view by name of tables which start with 't_av'
        FOR rec in (
            SELECT
                DISTINCT(v.account_view_name) AS viewName,
                't_av_'|| SUBSTR(td.nm_enum_data, INSTR (td.nm_enum_data, '/') + 1, LENGTH(td.nm_enum_data)) AS tableName,
                CASE WHEN INSTR(tp.nm_prop, ']') <> 0 
                THEN SUBSTR(tp.nm_prop, INSTR(tp.nm_prop, '[') + 1, INSTR(tp.nm_prop, ']') - INSTR(tp.nm_prop, '[') - 1) 
                ELSE NULL
                END AS additionalOptionString
            FROM t_enum_data td JOIN t_account_type_view_map v on v.id_account_view = td.id_enum_data
            JOIN t_account_view_prop p on v.id_type = p.id_account_view
            JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name || '%' and tp.nm_prop like '%' || p.nm_name
            WHERE tp.id_acc_template = idAccountTemplate)
        LOOP
            vals := NULL;
            FOR val in (
                SELECT
                    --"Magic numbers" were took FROM MetraTech.Interop.MTYAAC.PropValType enumeration.
                    CASE WHEN ROWNUM = 1 THEN NULL ELSE ',' END ||
                    nm_column_name || ' ' ||
                        CASE
                            WHEN nm_prop_class in(0, 1, 4, 5, 6, 8, 9, 12, 13)          
                            THEN ' = ''' || REPLACE(TO_CHAR(nm_value), '''', '''''') || ''' '
                            WHEN nm_prop_class in(2, 3, 10, 11, 14)
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
                JOIN t_account_view_prop p on v.id_type = p.id_account_view
                JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name || '%' and tp.nm_prop like '%.' || REPLACE(REPLACE(REPLACE(p.nm_name, N'\', N'\\'), N'_', N'\_'), N'%', N'\%') ESCAPE N'\'
                WHERE tp.id_acc_template = idAccountTemplate and tp.nm_prop like rec.viewName || '%')
            LOOP
                vals := vals || val.colVal;
            END LOOP;
            
            conditionStatement := NULL;
            IF(rec.additionalOptionString IS NOT NULL) THEN
                -- Processing enum values
                FOR item in (SELECT items AS conditionItem FROM TABLE(SplitStringByChar(rec.additionalOptionString,',')))
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
                        FROM t_account_type_view_map v JOIN t_account_view_prop p on v.id_type = p.id_account_view
                        WHERE UPPER(account_view_name) = UPPER(rec.viewName) AND UPPER(nm_name) = UPPER(val1));
                    
                    --Creation additional condition for update account view properties for each account view.
                    conditionStatement := conditionStatement || 'c_' || val1 || ' = ' || TO_CHAR(enumValue) || ' AND ';
                END LOOP;
            END IF;
                    
            --Completion to creation dynamic sql-string for update account view.
            conditionStatement := conditionStatement || 'id_acc in (SELECT id_descendent FROM t_vw_get_accounts_by_tmpl_id WHERE id_template = ' || TO_CHAR(idAccountTemplate) || '  AND CAST(''' || TO_CHAR(systemDate) || ''' AS DATE) BETWEEN COALESCE(vt_start, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)) AND COALESCE(vt_end, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)))';
            dSql := 'UPDATE ' || rec.tableName || ' SET ' || vals || ' WHERE ' || conditionStatement;
            
            EXECUTE IMMEDIATE dSql;
        END LOOP;

        -- Apply billing cycles and payment redirection settings 
        SELECT NVL(MAX(tuc.id_usage_cycle), -1), NVL(MAX(ttp.PayerID), -1)
          INTO UsageCycleId, PayerId
          FROM t_usage_cycle tuc
            JOIN (
                SELECT  tp.DayOfMonth
                        ,tp.StartDay
                        ,tp.StartMonth
                        ,NVL(m.num,-1)
                        ,tuct.id_cycle_type
                        ,tp.DayOfWeek
                        ,tp.StartYear
                        ,tp.FirstDayOfMonth
                        ,tp.SecondDayOfMonth
                        ,tp.UsageCycleType
                        ,tp.PayerID
                    FROM (
                        SELECT   MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfWeek' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfWeek
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.StartDay' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartDay
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.StartMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.StartYear' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartYear
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.FirstDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS FirstDayOfMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.SecondDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS SecondDayOfMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Internal.UsageCycleType' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS UsageCycleType
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.PayerID' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS PayerID
                            FROM t_acc_template_props tatp
                            WHERE tatp.id_acc_template = idAccountTemplate
                            GROUP BY tatp.id_acc_template
                    ) tp
                    LEFT JOIN t_enum_data tedm ON tedm.id_enum_data = tp.StartMonth
                    LEFT JOIN t_enum_data tedc ON tedc.id_enum_data = tp.UsageCycleType
                    LEFT JOIN t_months m ON UPPER(m.name) = UPPER(SUBSTR(tedm.nm_enum_data, INSTR(tedm.nm_enum_data, '/', -1) + 1))
                    LEFT JOIN t_usage_cycle_type tuct ON UPPER(tuct.tx_desc) = UPPER(SUBSTR(tedc.nm_enum_data, INSTR(tedc.nm_enum_data, '/', -1) + 1))
            
            ) ttp ON
                  tuc.id_cycle_type = ttp.id_cycle_type
              AND ttp.DayOfMonth = NVL(tuc.day_of_month, ttp.DayOfMonth)
              AND ttp.StartDay = NVL(tuc.start_day, ttp.StartDay) 
              AND ttp.StartMonth = NVL(tuc.start_month, ttp.StartMonth) 
              AND ttp.DayOfWeek = NVL(tuc.day_of_week, ttp.DayOfWeek)
              AND ttp.StartYear = NVL(tuc.start_year, ttp.StartYear)
              AND ttp.FirstDayOfMonth = NVL(tuc.first_day_of_month, ttp.FirstDayOfMonth)
              AND ttp.SecondDayOfMonth = NVL(tuc.second_day_of_month, ttp.SecondDayOfMonth);
              
        FOR acc IN (
            SELECT   ta.id_acc AS IdAcc
                ,tauc.id_usage_cycle AS OldUsageCycle
                ,tpr.id_payee
                ,tpr.id_payer
                ,tpr.vt_start
                ,tpr.vt_end
                ,tavi.c_Currency AS p_account_currency
            FROM T_VW_GET_ACCOUNTS_BY_TMPL_ID va
            JOIN t_account ta ON ta.id_acc = va.id_descendent
            JOIN t_acc_usage_cycle tauc ON tauc.id_acc = ta.id_acc
            LEFT JOIN t_payment_redirection tpr ON tpr.id_payee = ta.id_acc
            LEFT JOIN t_av_Internal tavi ON tavi.id_acc = ta.id_acc
            WHERE va.id_template = idAccountTemplate  AND systemDate BETWEEN COALESCE(va.vt_start, systemDate) AND COALESCE(va.vt_end, systemDate)
                AND (
                    (UsageCycleId <> -1 AND tauc.id_usage_cycle <> UsageCycleId)
                    OR (PayerId <> -1 AND tpr.id_payee <> PayerId)
                ))
        LOOP

            IF acc.OldUsageCycle <> UsageCycleId AND UsageCycleId <> -1 THEN
                p_status := dbo.ISBILLINGCYCLEUPDPROHIBITEDBYG(systemDate, acc.IdAcc);
                IF p_status = 1 THEN
                    p_status := 0;
                    UPDATE t_acc_usage_cycle
                       SET id_usage_cycle = UsageCycleId
                     WHERE id_acc = acc.IdAcc;

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
                                WHERE pay.id_payer = acc.IdAcc OR pay.id_payee = acc.IdAcc
                          ) "groups";

                    IF p_status = 1 THEN
                        p_status := 0;
                        -- deletes any mappings to intervals in the future from the old cycle
                        DELETE FROM t_acc_usage_interval 
                            WHERE t_acc_usage_interval.id_acc = acc.IdAcc
                            AND id_usage_interval IN ( 
                                SELECT id_interval 
                                    FROM t_usage_interval ui
                                    INNER JOIN t_acc_usage_interval aui ON aui.id_acc = acc.IdAcc AND aui.id_usage_interval = ui.id_interval
                                    WHERE dt_start > systemDate
                            );

                        -- only one pending update is allowed at a time
                        -- deletes any previous update mappings which have not yet
                        -- transitioned (dt_effective is still in the future)
                        DELETE FROM t_acc_usage_interval 
                            WHERE dt_effective IS NOT NULL 
                                AND id_acc = acc.IdAcc 
                                AND dt_effective >= systemDate;

                        -- gets the current interval's end date
                        SELECT MAX(ui.dt_end)
                          INTO intervalenddate
                          FROM t_acc_usage_interval aui
                          INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval AND systemDate BETWEEN ui.dt_start AND ui.dt_end
                        WHERE aui.id_acc = acc.IdAcc;

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
                                SELECT acc.IdAcc
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
            
            SELECT COUNT(1) INTO accExists FROM t_account where id_acc = PayerID;
            IF accExists > 0 THEN
                payerenddate := dbo.MTMaxDate();
                -- find the old payment information
                SELECT MAX(vt_start), MAX(vt_end), MAX(id_payer)
                  INTO oldpayerstart, oldpayerend, oldpayer
                  FROM t_payment_redirection
                 WHERE id_payee = acc.IdAcc 
                   AND dbo.OverlappingDateRange(vt_start, vt_end, systemDate, dbo.mtmaxdate()) = 1;
                
                -- if the new record is in range of the old record and the payer is the same as the older payer,
                -- update the record
                IF (PayerID <> -1) THEN
                    IF (PayerID = oldpayer) THEN
                        UpdatePaymentRecord (payerID, acc.IdAcc, oldpayerstart, oldpayerend, systemDate, payerenddate, systemDate, 1, acc.p_account_currency, p_status);
                        
                        IF (p_status <> 1) THEN
                            InsertTmplSessionDetail
                            (
                                sessionId,
                                DetailTypeSubscription,
                                DetailResultInformation,
                                'No payment record changed. Return code is ' || TO_CHAR(p_status),
                                nRetryCount
                            );
                            p_status := 0;
                        END IF;
                    ELSE
                        payerbillable := dbo.IsAccountBillable(PayerID);
                        CreatePaymentRecord(payerID, acc.IdAcc, systemDate, payerenddate, payerbillable, systemDate, 'N', 1, acc.p_account_currency, p_status);
                        IF (p_status <> 1) THEN
                            InsertTmplSessionDetail
                            (
                                sessionId,
                                DetailTypeSubscription,
                                DetailResultInformation,
                                'No payment record created. Return code is ' || TO_CHAR(p_status),
                                nRetryCount
                            );
                            p_status := 0;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            sucsesfullTransaction := 0;
    END;
END;

