/*__HIERARCHY_BROWESER_LEVELS__*/
SELECT
num_generations,account_type, icon, parent_id, id_parent, child_id, b_children AS children, nm_login, nm_space, hierarchyname,
CASE WHEN folder_owner IS NULL THEN N'' ELSE folder_owner END AS folder_owner,
folder, currency, status, numpayees, id_payee
FROM
(
SELECT
accs.num_generations,
at.name AS account_type,
'account.gif' AS icon,
accs.id_ancestor AS parent_id,
accs.id_parent,
accs.id_descendent AS child_id,
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
id_payee 
FROM
(
SELECT
aa.num_generations,
aa.id_ancestor,
aa2.id_ancestor AS id_parent,
aa.id_descendent,
aa3.b_children,
COUNT(1) numpayees,
pr.id_payee id_payee
FROM t_account_ancestor aa
INNER JOIN t_account_ancestor aa2 ON aa2.id_descendent = aa.id_ancestor AND %%REF_DATE%% BETWEEN aa2.vt_start AND aa2.vt_end AND aa2.num_generations=1
INNER JOIN t_account_ancestor aa3 ON aa3.id_descendent = aa.id_ancestor AND %%REF_DATE%% BETWEEN aa3.vt_start AND aa3.vt_end AND aa3.num_generations=0 
AND aa3.id_ancestor = aa.id_ancestor
LEFT OUTER JOIN t_payment_redirection pr ON aa.id_descendent = pr.id_payer
                                         AND %%REF_DATE%% BETWEEN pr.vt_start AND pr.vt_end AND pr.id_payee != pr.id_payer
WHERE 1=1
AND aa.id_descendent = %%DESCENDENT%%
AND %%REF_DATE%% BETWEEN aa.vt_start AND aa.vt_end
GROUP BY aa.num_generations, aa.id_ancestor, aa2.id_ancestor, aa.id_descendent, aa3.b_children, pr.id_payee) accs
 INNER JOIN t_account acc ON acc.id_acc = accs.id_ancestor
 INNER JOIN t_account_type at ON at.id_type = acc.id_type
  INNER  JOIN t_av_internal tav ON tav.id_acc = accs.id_ancestor
INNER JOIN t_account_mapper map ON map.id_acc = accs.id_ancestor  
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
			AND ns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
  LEFT OUTER  JOIN t_impersonate imp ON imp.id_acc = accs.id_ancestor
LEFT OUTER JOIN t_account_mapper ownmap ON ownmap.id_acc = imp.id_owner  
		LEFT OUTER JOIN t_namespace ownns ON ownns.nm_space = ownmap.nm_space
			AND ownns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
LEFT OUTER JOIN t_account ownacc ON ownacc.id_acc = imp.id_owner
 LEFT OUTER JOIN t_account_type ownat ON ownat.id_type = ownacc.id_type
  LEFT OUTER JOIN (
SELECT at.id_type, CASE WHEN COUNT(adm.id_type) > 0 THEN 1 ELSE 0 END d_count FROM
  t_account_type at
  LEFT OUTER JOIN t_acctype_descendenttype_map adm ON at.id_type = adm.id_type
  GROUP BY at.id_type
) descmap ON descmap.id_type = at.id_type
INNER JOIN t_enum_data ed ON ed.nm_enum_data = 'metratech.com/accountcreation/ContactType/Bill-To'
LEFT OUTER JOIN t_av_contact htac ON htac.id_acc = accs.id_ancestor AND htac.c_contacttype = ed.id_enum_data
LEFT OUTER JOIN t_av_contact otac ON otac.id_acc = ownacc.id_acc AND otac.c_contacttype = ed.id_enum_data
INNER JOIN t_account_state accstate ON
      accstate.id_acc = accs.id_ancestor AND
      %%REF_DATE%% BETWEEN accstate.vt_start AND accstate.vt_end
WHERE 1=1 
AND at.b_IsVisibleInHierarchy = '1'
AND ns.tx_typ_space IN (%%TYPE_SPACE%%)
) a
WHERE 1=1
ORDER BY num_generations desc