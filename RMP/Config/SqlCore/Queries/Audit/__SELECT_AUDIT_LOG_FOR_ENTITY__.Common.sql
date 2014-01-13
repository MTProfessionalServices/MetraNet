
        (select * from vw_audit_log
        WHERE
          
        EntityId = %%ENTITY_ID%%)
        UNION
        (select * from vw_audit_log
        where EntityId in
        (select id_group from t_group_sub where
        t_group_sub.id_corporate_account = %%ENTITY_ID%%))

      