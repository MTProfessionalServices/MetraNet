
CREATE OR REPLACE PROCEDURE ApplyAccountTemplate
(
    accountTemplateId NUMBER,
    sessionId NUMBER,
    systemDate DATE
)
AS
    nRetryCount NUMBER := 0;
    DetailTypeGeneral NUMBER(10);
    DetailResultInformation NUMBER(10);
    DetailTypeSubscription NUMBER(10);
    id_acc_type NUMBER(10);
    id_acc NUMBER(10);
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
     
    --!!!Starting application of template
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Starting application of template',
        nRetryCount
    );

    --Select account hierarchy for current template and for each child template.
    FOR tmpl in (
        SELECT tat.id_acc_template
          FROM t_account_ancestor taa
          JOIN t_acc_template tat ON taa.id_descendent = tat.id_folder AND tat.id_acc_type = id_acc_type
         WHERE taa.id_ancestor = id_acc)
    LOOP

        --Apply account template to appropriate account list.
        ApplyTemplateToAccounts(tmpl.id_acc_template, sessionId, nRetryCount, systemDate);
    END LOOP;


    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeSubscription,
        DetailResultInformation,
        'There are no subscriptions to be applied',
        nRetryCount
    );

    --!!!Template application complete
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Template application complete',
        nRetryCount
    );
END;

