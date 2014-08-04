SELECT 
RowNumber, account_type, icon, parent_id, child_id, b_children as children, nm_login, nm_space, hierarchyname,
CASE when folder_owner IS NULL THEN N'' ELSE folder_owner END as folder_owner,
folder, currency, status, numpayees, tx_path
FROM
(SELECT ROW_NUMBER() OVER(ORDER by descmap.d_count ASC, at.name ASC, CASE WHEN map.nm_space = 'system_user' THEN map.nm_login ELSE map.nm_login END ASC) RowNumber,
at.name as account_type,
'account.gif' as icon,
accs.id_ancestor as parent_id,
accs.id_descendent as child_id,
accs.b_children,
map.nm_login nm_login,
map.nm_space nm_space,
CASE
                WHEN (htac.c_firstname IS NULL OR htac.c_firstname = ' ') AND (htac.c_lastname IS NULL OR htac.c_lastname = ' ') THEN map.nm_login
                WHEN htac.c_firstname IS NULL OR htac.c_firstname = ' ' THEN translate(htac.c_lastname using nchar_cs)
                WHEN htac.c_lastname IS NULL OR htac.c_lastname = ' ' THEN translate(htac.c_firstname using nchar_cs)
                ELSE translate(concat(htac.c_firstname, concat(' ', htac.c_lastname)) using nchar_cs)
              END AS hierarchyname,
CASE
                WHEN (otac.c_firstname IS NULL OR otac.c_firstname = ' ') AND (otac.c_lastname IS NULL OR otac.c_lastname = ' ') THEN ownmap.nm_login
                WHEN otac.c_firstname IS NULL OR otac.c_firstname = ' ' THEN translate(otac.c_lastname using nchar_cs)
                WHEN otac.c_lastname IS NULL OR otac.c_lastname = ' ' THEN translate(otac.c_firstname using nchar_cs)
                ELSE translate(concat(otac.c_firstname, concat(' ', otac.c_lastname)) using nchar_cs)
              END as folder_owner,
descmap.d_count folder,
tav.c_currency currency,
accstate.status status,
accs.numpayees,
accs.tx_path
FROM
(
SELECT
parent.id_ancestor,
parent.id_descendent,
parent.tx_path,
parent.b_children,
(SELECT COUNT(*) FROM t_payment_redirection WHERE id_payer = parent.id_descendent AND id_payer <> id_payee) AS numpayees
FROM t_account_ancestor parent
LEFT OUTER JOIN t_payment_redirection pr ON parent.id_descendent = pr.id_payer AND %%REF_DATE%% BETWEEN pr.vt_start AND pr.vt_end AND pr.id_payee != pr.id_payer
where 1=1
AND parent.id_ancestor = %%ANCESTOR%%
AND parent.num_generations = 1
AND %%DESCENDENT_RANGE_CHECK%%
%%REF_DATE%% BETWEEN parent.vt_start AND parent.vt_end
GROUP BY id_ancestor, id_descendent, tx_path, b_children
) accs
INNER JOIN t_account acc on acc.id_acc = accs.id_descendent
INNER JOIN t_account_type at on at.id_type = acc.id_type
INNER  JOIN t_av_internal tav ON tav.id_acc = accs.id_descendent %%FOLDERCHECK%%
INNER JOIN t_account_mapper map ON map.id_acc = accs.id_descendent  
INNER JOIN t_namespace ns on ns.nm_space = map.nm_space 
AND ns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
LEFT OUTER  JOIN t_impersonate imp ON imp.id_acc = accs.id_descendent
LEFT OUTER JOIN t_account_mapper ownmap ON ownmap.id_acc = imp.id_owner  
LEFT OUTER JOIN t_namespace ownns on ownns.nm_space = ownmap.nm_space 
AND ownns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
left outer join t_account ownacc on ownacc.id_acc = imp.id_owner
left outer join t_account_type ownat on ownat.id_type = ownacc.id_type
LEFT OUTER JOIN (select at.id_type, CASE WHEN COUNT(adm.id_type) > 0 THEN 1 ELSE 0 END d_count from t_account_type at
left outer join t_acctype_descendenttype_map adm on at.id_type = adm.id_type
group by at.id_type
) descmap on descmap.id_type = at.id_type
INNER JOIN t_enum_data ed ON ed.nm_enum_data = 'metratech.com/accountcreation/ContactType/Bill-To'
LEFT OUTER JOIN t_av_contact htac ON htac.id_acc = accs.id_descendent AND htac.c_contacttype = ed.id_enum_data
LEFT OUTER JOIN t_av_contact otac ON otac.id_acc = ownacc.id_acc AND otac.c_contacttype = ed.id_enum_data
INNER JOIN t_account_state accstate ON
accstate.id_acc = accs.id_descendent AND
accstate.status IN (%%EXCLUDED_STATES%%) AND
%%REF_DATE%% BETWEEN accstate.vt_start AND accstate.vt_end
WHERE 1=1 
AND at.b_IsVisibleInHierarchy = '1'
AND ('%%COMPANY_NAME%%' = ' ' OR EXISTS (SELECT 1 FROM t_av_Contact avc WHERE avc.c_Company LIKE '%%COMPANY_NAME%%' AND avc.id_acc = acc.id_acc))
AND ('%%USER_NAME%%' = ' ' OR map.nm_login LIKE '%%USER_NAME%%')
/* AND ns.tx_typ_space = '%%TYPE_SPACE%%' Fix for CORE-7409*/ 
AND (ns.tx_typ_space = '%%TYPE_SPACE%%' OR ( (ns.tx_typ_space = 'system_user' and accs.id_ancestor <> 1 )))
) a
where 1=1
AND RowNumber > %%PAGE_SIZE%% * (%%PAGE_NUMBER%% -1)
AND ROWNUM <= %%PAGE_SIZE%%
ORDER BY RowNumber