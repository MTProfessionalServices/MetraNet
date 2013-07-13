
CREATE OR REPLACE 
PROCEDURE ApplyAccountTemplate
(
    accountTemplateId          NUMBER,
    sessionId                  NUMBER,
    systemDate                 DATE,
    sub_start                  DATE,
    sub_end                    DATE,
    next_cycle_after_startdate CHAR,
    next_cycle_after_enddate   CHAR,
    id_event_success           INT,
    id_event_failure           INT,
    account_id                 INT DEFAULT NULL,
    doCommit                   CHAR DEFAULT 'Y'
)
AS
    nRetryCount NUMBER := 0;
    DetailTypeGeneral NUMBER(10);
    DetailResultInformation NUMBER(10);
    DetailTypeSubscription NUMBER(10);
    id_acc_type NUMBER(10);
    id_acc NUMBER(10);
    user_id NUMBER(10);
BEGIN

    SELECT id_acc_type, id_folder
      INTO id_acc_type, id_acc
      FROM t_acc_template
     WHERE id_acc_template = accountTemplateId;


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

    SELECT NVL(MAX(id_submitter),0)
    INTO   user_id
    FROM   t_acc_template_session ts
    WHERE  id_session = sessionId;

    --!!!Starting application of template
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Starting application of template',
        nRetryCount,
        doCommit
    );

    /* Updating session details with a number of themplates to be applied in the session */
    UPDATE t_acc_template_session
    SET    n_templates = (SELECT COUNT(1) FROM t_account_ancestor aa JOIN t_acc_template at ON aa.id_ancestor = id_acc AND aa.id_descendent = at.id_folder)
    WHERE  id_session = sessionId;

    IF (doCommit = 'Y')
    THEN
    COMMIT;
    END IF;

    --Select account hierarchy for current template and for each child template.
    FOR tmpl in (
        SELECT tat.id_acc_template
          FROM t_account_ancestor taa
          JOIN t_acc_template tat ON taa.id_descendent = tat.id_folder AND tat.id_acc_type = id_acc_type
         WHERE taa.id_ancestor = id_acc AND systemDate BETWEEN taa.vt_start AND taa.vt_end)
    LOOP

        --Apply account template to appropriate account list.
        ApplyTemplateToAccounts
        (
            idAccountTemplate          => tmpl.id_acc_template,
            sessionId                  => sessionId,
            nRetryCount                => nRetryCount,
            systemDate                 => systemDate,
            sub_start                  => sub_start,
            sub_end                    => sub_end,
            next_cycle_after_startdate => next_cycle_after_startdate,
            next_cycle_after_enddate   => next_cycle_after_enddate,
            user_id                    => user_id,
            id_event_success           => id_event_success,
            id_event_failure           => id_event_failure,
            account_id                 => account_id,
            doCommit                   => doCommit
        );

        UPDATE t_acc_template_session
        SET    n_templates_applied = n_templates_applied + 1
        WHERE  id_session = sessionId;

        IF (doCommit = 'Y')
        THEN
        COMMIT;
        END IF;

    END LOOP;

    /* Apply default security */
    INSERT INTO t_policy_role
    SELECT pd.id_policy, pr.id_role
    FROM   t_account_ancestor aa
           JOIN t_account_ancestor ap ON ap.id_descendent = aa.id_descendent AND ap.num_generations = 1
           JOIN t_principal_policy pp ON pp.id_acc = ap.id_ancestor AND pp.policy_type = 'D'
           JOIN t_principal_policy pd ON pd.id_acc = aa.id_descendent AND pd.policy_type = 'A'
           JOIN t_policy_role pr ON pr.id_policy = pp.id_policy
           JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.b_applydefaultpolicy = 'Y'
    WHERE  t.id_acc_template = accountTemplateId
       AND aa.num_generations > 0 
       AND systemDate BETWEEN aa.vt_start AND aa.vt_end
       AND systemDate BETWEEN ap.vt_start AND ap.vt_end
       AND NOT EXISTS (SELECT 1 FROM t_policy_role pr2 WHERE pr2.id_policy = pd.id_policy AND pr2.id_role = pr.id_role);

    /* Finalize session state */
    UPDATE t_acc_template_session
    SET    n_templates = n_templates_applied
    WHERE  id_session = sessionId;

    --!!!Template application complete
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Template application complete',
        nRetryCount,
        doCommit
    );
END;
