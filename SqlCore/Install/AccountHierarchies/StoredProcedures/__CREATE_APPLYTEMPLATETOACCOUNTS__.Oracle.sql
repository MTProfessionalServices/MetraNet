CREATE OR REPLACE 
PROCEDURE ApplyTemplateToAccounts(
    idAccountTemplate          INT,
    sessionId                  INT,
    nRetryCount                INT,
    systemDate                 DATE,
    sub_start                  DATE,
    sub_end                    DATE,
    next_cycle_after_startdate CHAR,
    next_cycle_after_enddate   CHAR,
    user_id                    INT,
    id_event_success           INT,
    id_event_failure           INT,
    account_id                 INT DEFAULT NULL,
    doCommit                   CHAR DEFAULT 'Y'
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

    UsageCycleId NUMBER(10);
    PayerId NUMBER(10);

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

--    BEGIN
        mt_acc_template.UpdateAccPropsFromTemplate (
            idAccountTemplate => idAccountTemplate,
            systemDate        => systemDate,
            idAcc             => account_id
        );
        -- Apply billing cycles and payment redirection settings
        SELECT NVL(MAX(tuc.id_usage_cycle), -1), NVL(MAX(ttp.PayerID), -1)
          INTO UsageCycleId, PayerId
          FROM t_usage_cycle tuc
            RIGHT OUTER JOIN (
                SELECT  tp.DayOfMonth
                        ,tp.StartDay
                        ,tp.StartMonth
                        ,NVL(m.num,-1) as MonthNum
                        ,NVL(dw.num,-1) as DayOfWeekNum
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
                    LEFT JOIN t_enum_data tedw ON tedw.id_enum_data = tp.DayOfWeek
                    LEFT JOIN t_months m ON UPPER(m.name) = UPPER(SUBSTR(tedm.nm_enum_data, INSTR(tedm.nm_enum_data, '/', -1) + 1))
                    LEFT JOIN t_day_of_week dw ON dw.name = UPPER(SUBSTR(tedw.nm_enum_data, INSTR(tedw.nm_enum_data, '/', -1) + 1))
                    LEFT JOIN t_usage_cycle_type tuct ON UPPER(tuct.tx_desc) LIKE REPLACE(UPPER(SUBSTR(tedc.nm_enum_data, INSTR(tedc.nm_enum_data, '/', -1) + 1)), '-', '%')

            ) ttp ON
                  tuc.id_cycle_type = ttp.id_cycle_type
              AND ttp.DayOfMonth = NVL(tuc.day_of_month, ttp.DayOfMonth)
              AND ttp.StartDay = NVL(tuc.start_day, ttp.StartDay)
              AND ttp.MonthNum = NVL(tuc.start_month, ttp.MonthNum)
              AND ttp.DayOfWeekNum = NVL(tuc.day_of_week, ttp.DayOfWeekNum)
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
                )
                AND ta.id_acc = COALESCE(account_id, ta.id_acc)
        )

        LOOP
            mt_acc_template.UpdateUsageCycleFromTemplate(
                IdAcc => acc.IdAcc,
                UsageCycleId => UsageCycleId,
                OldUsageCycle => acc.OldUsageCycle,
                systemDate => systemDate
            );

            mt_acc_template.UpdatePayerFromTemplate(
                IdAcc => acc.IdAcc
                ,PayerId => PayerId
                ,systemDate => systemDate
                ,p_account_currency => acc.p_account_currency
                ,sessionId => sessionId
                ,DetailTypeSubscription => DetailTypeSubscription
                ,DetailResultInformation => DetailResultInformation
                ,nRetryCount => nRetryCount
            );
        END LOOP;

        IF (doCommit = 'Y')
        THEN
        COMMIT;
        END IF;

/*    EXCEPTION
        WHEN OTHERS THEN
            IF (doCommit = 'Y')
            THEN
            ROLLBACK;
            END IF;
            InsertTmplSessionDetail
            (
                sessionId,
                DetailTypeSubscription,
                DetailResultFailure,
                'Applying template failed with error message: ' || SQLERRM,
                nRetryCount,
                doCommit
            );
    END;
*/
    mt_acc_template.apply_subscriptions(
        template_id                => idAccountTemplate,
        sub_start                  => sub_start,
        sub_end                    => sub_end,
        next_cycle_after_startdate => next_cycle_after_startdate,
        next_cycle_after_enddate   => next_cycle_after_enddate,
        user_id                    => user_id,
        id_audit                   => null,
        id_event_success           => id_event_success,
        id_event_failure           => id_event_failure,
        systemdate                 => systemDate,
        id_template_session        => sessionId,
        retrycount                 => nRetryCount,
        doCommit                   => doCommit
    );

END;
