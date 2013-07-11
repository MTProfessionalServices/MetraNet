
CREATE OR REPLACE 
PACKAGE mt_acc_template
AS
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
    );

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
       retrycount                 INT
    );

    PROCEDURE UpdateAccPropsFromTemplate (
        idAccountTemplate INT,
        systemDate DATE,
        idAcc INT DEFAULT NULL
    );

    PROCEDURE UpdateUsageCycleFromTemplate (
        IdAcc INT
        ,UsageCycleId INT
        ,OldUsageCycle INT
        ,systemDate DATE
    );

    PROCEDURE UpdatePayerFromTemplate (
        IdAcc INT
        ,PayerId INT
        ,systemDate DATE
        ,p_account_currency VARCHAR2
        ,sessionId INT
        ,DetailTypeSubscription INT
        ,DetailResultInformation INT
        ,nRetryCount INT
    );

END mt_acc_template;