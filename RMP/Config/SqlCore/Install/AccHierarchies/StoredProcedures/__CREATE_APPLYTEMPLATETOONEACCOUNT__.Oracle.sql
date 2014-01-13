CREATE OR REPLACE 
PROCEDURE applytemplatetooneaccount
   (
     accountID IN NUMBER
    ,p_systemdate IN DATE
    ,p_acc_type IN VARCHAR2
    )
   IS
   templateId INTEGER;
   templateOwner INTEGER;
   templateCount INTEGER;
   sessionId INTEGER;
BEGIN
    SELECT NVL(MIN(id_acc_template),-1), NVL(MIN(templOwner),-1), COUNT(*)
        INTO templateId, templateOwner, templateCount
        FROM
        (
        select  id_acc_template
                , template.id_folder as templOwner
            from
                    t_acc_template template
            INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
            INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
            inner join t_account_type atype on template.id_acc_type = atype.id_type
            left join t_acc_tmpl_types tatt on tatt.id = 1
                WHERE id_descendent = accountID AND
                    p_systemdate between vt_start AND vt_end AND
                    (atype.name = p_acc_type or tatt.all_types = 1)
                    AND num_generations <> 0
            ORDER BY num_generations asc
        )
        where ROWNUM = 1;
    IF (templateCount <> 0 AND templateId <> -1)
    THEN
        updateprivatetempates(ID_TEMPLATE=>templateId, P_SYSTEMDATE=>p_systemdate);
    END IF;
    
    SELECT NVL(MIN(id_acc_template),-1), NVL(MIN(templOwner),-1), COUNT(*)
        INTO templateId, templateOwner, templateCount
        FROM
        (
        select  id_acc_template
                , template.id_folder as templOwner
            from
                    t_acc_template template
            INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
            INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
            inner join t_account_type atype on template.id_acc_type = atype.id_type
            left join t_acc_tmpl_types tatt on tatt.id = 1
                WHERE id_descendent = accountID AND
                    p_systemdate between vt_start AND vt_end AND
                    (atype.name = p_acc_type or tatt.all_types = 1)
            ORDER BY num_generations asc
        )
        where ROWNUM = 1;
    IF (templateCount <> 0 AND templateId <> -1)
    THEN
        inserttemplatesession(templateOwner, p_acc_type, 0, ' ', 0, 0, 0, sessionId, 'N');
        ApplyTemplateToAccounts
        (
            idAccountTemplate          => templateId,
            sessionId                  => sessionId,
            nRetryCount                => 0,
            systemDate                 => p_systemdate,
            sub_start                  => p_systemdate,
            sub_end                    => mtmaxdate(),
            next_cycle_after_startdate => 'N',
            next_cycle_after_enddate   => 'N',
            user_id                    => 0,
            id_event_success           => NULL,
            id_event_failure           => NULL,
            account_id                 => accountID,
            doCommit                   => 'N'
        );
        
    END IF;
END;
