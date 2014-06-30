/*__HIERARCHY_BROWESER_LEVELS__*/
;with my_drivers as
(
select
aa.num_generations,
aa.id_ancestor,
aa2.id_ancestor as id_parent,
aa.id_descendent,
aa3.b_children,
COUNT(1) numpayees
from t_account_ancestor aa
inner join t_account_ancestor aa2 on aa2.id_descendent = aa.id_ancestor and %%REF_DATE%% between aa2.vt_start and aa2.vt_end and aa2.num_generations=1
inner join t_account_ancestor aa3 on aa3.id_descendent = aa.id_ancestor and %%REF_DATE%% between aa3.vt_start and aa3.vt_end and aa3.num_generations=0 and aa3.id_ancestor = aa.id_ancestor
left outer join t_payment_redirection pr on aa.id_descendent = pr.id_payer
                                         and %%REF_DATE%% BETWEEN pr.vt_start and pr.vt_end
                                         and pr.id_payee != pr.id_payer
where 1=1
and aa.id_descendent = %%DESCENDENT%%
and %%REF_DATE%% between aa.vt_start and aa.vt_end
group by aa.num_generations, aa.id_ancestor, aa2.id_ancestor, aa.id_descendent, aa3.b_children
),
my_types as
(
select at.id_type, CASE WHEN COUNT(adm.id_type) > 0 THEN 1 ELSE 0 END d_count from
  t_account_type at
  left outer join t_acctype_descendenttype_map adm on at.id_type = adm.id_type
  group by at.id_type
)

select
num_generations,account_type, icon, parent_id, id_parent, child_id, b_children as children, nm_login, nm_space, hierarchyname,
CASE when folder_owner IS NULL THEN N'' ELSE folder_owner END as folder_owner,
folder, currency, status, numpayees

from (

SELECT
accs.num_generations,
at.name as account_type,
'account.gif' as icon,
accs.id_ancestor as parent_id,
accs.id_parent,
accs.id_descendent as child_id,
accs.b_children,
map.nm_login nm_login,
map.nm_space nm_space,
CASE
                WHEN (htac.c_firstname IS NULL OR htac.c_firstname = '') AND (htac.c_lastname IS NULL OR htac.c_lastname = '') THEN map.nm_login
                WHEN htac.c_firstname IS NULL OR htac.c_firstname = '' THEN htac.c_lastname
                WHEN htac.c_lastname IS NULL OR htac.c_lastname = '' THEN htac.c_firstname
                ELSE (htac.c_firstname + (' ' + htac.c_lastname))
              END AS hierarchyname,
CASE
                WHEN (otac.c_firstname IS NULL OR otac.c_firstname = '') AND (otac.c_lastname IS NULL OR otac.c_lastname = '') THEN ownmap.nm_login
                WHEN otac.c_firstname IS NULL OR otac.c_firstname = '' THEN otac.c_lastname
                WHEN otac.c_lastname IS NULL OR otac.c_lastname = '' THEN otac.c_firstname
                ELSE (otac.c_firstname + (' ' + otac.c_lastname))
              END as folder_owner,
descmap.d_count folder,
tav.c_currency currency,
accstate.status status,
accs.numpayees
FROM my_drivers accs
 inner join t_account acc on acc.id_acc = accs.id_ancestor
 inner join t_account_type at on at.id_type = acc.id_type
  INNER  JOIN t_av_internal tav ON tav.id_acc = accs.id_ancestor
INNER JOIN t_account_mapper map ON map.id_acc = accs.id_ancestor  
		INNER JOIN dbo.t_namespace ns on ns.nm_space = map.nm_space 
			AND ns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
  LEFT OUTER  JOIN t_impersonate imp ON imp.id_acc = accs.id_ancestor
LEFT OUTER JOIN t_account_mapper ownmap ON ownmap.id_acc = imp.id_owner  
		LEFT OUTER JOIN dbo.t_namespace ownns on ownns.nm_space = ownmap.nm_space 
			AND ownns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
left outer join t_account ownacc on ownacc.id_acc = imp.id_owner
 left outer join t_account_type ownat on ownat.id_type = ownacc.id_type
  LEFT OUTER JOIN my_types descmap on descmap.id_type = at.id_type
  INNER JOIN dbo.t_enum_data ed ON ed.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'
  LEFT OUTER JOIN t_av_contact htac ON htac.id_acc = accs.id_ancestor AND htac.c_contacttype = ed.id_enum_data
  LEFT OUTER JOIN t_av_contact otac ON otac.id_acc = ownacc.id_acc AND otac.c_contacttype = ed.id_enum_data
INNER LOOP JOIN t_account_state accstate ON
      accstate.id_acc = accs.id_ancestor AND
      %%REF_DATE%% BETWEEN accstate.vt_start AND accstate.vt_end
WHERE 1=1 
AND at.b_IsVisibleInHierarchy = '1'
AND ns.tx_typ_space IN (%%TYPE_SPACE%%)
) a
where 1=1
ORDER BY num_generations desc
OPTION(MAXDOP 1)