
        SELECT c_ChangeType as ChangeType, d.tx_desc as DisplayName,  count(*) as PendingCount FROM t_approvals a 
        LEFT JOIN t_enum_data e on concat('Approvals/ChangeType/', a.c_ChangeType) like e.nm_enum_data
        LEFT JOIN t_description d on e.id_enum_data = d.id_desc
        WHERE c_CurrentState = 'Pending' AND c_ChangeType in (%%CHANGE_TYPES_USER_CAN_APPROVE%%)  AND d.id_lang_code = ? and a.c_SubmitterId <> ?
        %%PART_ID_PREDICATE%%
        GROUP BY c_ChangeType, d.id_lang_code, d.tx_desc
        