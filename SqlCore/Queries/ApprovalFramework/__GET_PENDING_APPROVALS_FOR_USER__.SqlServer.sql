
SELECT c_ChangeType AS ChangeType, d.tx_desc AS DisplayName, COUNT(*) AS PendingCount
FROM   t_approvals a
       LEFT JOIN t_enum_data e ON ('Approvals/ChangeType/' + a.c_ChangeType) LIKE e.nm_enum_data
       LEFT JOIN t_description d ON e.id_enum_data = d.id_desc
WHERE  c_CurrentState = 'Pending' AND c_ChangeType IN (%%CHANGE_TYPES_USER_CAN_APPROVE%%)
       AND d.id_lang_code = ? AND a.c_SubmitterId <> ?
       %%PART_ID_PREDICATE%%
GROUP BY
       c_ChangeType, d.id_lang_code, d.tx_desc
