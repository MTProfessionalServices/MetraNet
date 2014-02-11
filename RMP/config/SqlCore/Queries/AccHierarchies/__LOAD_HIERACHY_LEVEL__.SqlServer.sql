Declare @PageSize int;
Declare @PageNumber int;

set @PageSize=%%PAGE_SIZE%%;
set @PageNumber = %%PAGE_NUMBER%%;

with my_drivers as
(
select
parent.id_ancestor,
parent.id_descendent,
parent.tx_path,
parent.b_children,
(SELECT COUNT(*) FROM t_payment_redirection WHERE id_payer = parent.id_descendent AND id_payer <> id_payee) as numpayees
from t_account_ancestor parent
left outer join t_payment_redirection pr on parent.id_descendent = pr.id_payer
                                         and %%REF_DATE%% BETWEEN pr.vt_start and pr.vt_end
                                         and pr.id_payee != pr.id_payer
where 1=1
and parent.id_ancestor = %%ANCESTOR%%
and parent.num_generations = 1
AND %%DESCENDENT_RANGE_CHECK%%
%%REF_DATE%% between parent.vt_start and parent.vt_end
group by id_ancestor, id_descendent, tx_path, b_children
),
my_types as
(
select at.id_type, CASE WHEN COUNT(adm.id_type) > 0 THEN 1 ELSE 0 END d_count from
  t_account_type at
  left outer join t_acctype_descendenttype_map adm on at.id_type = adm.id_type
  group by at.id_type
)

select top (@PageSize)
RowNumber, account_type, icon, parent_id, child_id, b_children as children, nm_login, nm_space, hierarchyname,
CASE when folder_owner IS NULL THEN N'' ELSE folder_owner END as folder_owner,
folder, currency, status, numpayees, tx_path

from (

SELECT
ROW_NUMBER() OVER(ORDER by descmap.d_count ASC, at.name ASC, CASE 
		    WHEN map.nm_space = 'system_user' THEN map.nm_login        
        ELSE map.nm_login
      END ASC) RowNumber,
at.name as account_type,
'account.gif' as icon,
accs.id_ancestor as parent_id,
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
accs.numpayees,
accs.tx_path

FROM my_drivers accs
 inner join t_account acc on acc.id_acc = accs.id_descendent
 inner join t_account_type at on at.id_type = acc.id_type
  INNER  JOIN t_av_internal tav ON tav.id_acc = accs.id_descendent %%FOLDERCHECK%%
INNER JOIN t_account_mapper map ON map.id_acc = accs.id_descendent  
		INNER JOIN dbo.t_namespace ns on ns.nm_space = map.nm_space 

			AND ns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
  LEFT OUTER  JOIN t_impersonate imp ON imp.id_acc = accs.id_descendent
LEFT OUTER JOIN t_account_mapper ownmap ON ownmap.id_acc = imp.id_owner  
		LEFT OUTER JOIN dbo.t_namespace ownns on ownns.nm_space = ownmap.nm_space 

			AND ownns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
left outer join t_account ownacc on ownacc.id_acc = imp.id_owner
 left outer join t_account_type ownat on ownat.id_type = ownacc.id_type
  LEFT OUTER JOIN my_types descmap on descmap.id_type = at.id_type
INNER JOIN dbo.t_enum_data ed ON ed.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'
  LEFT OUTER JOIN t_av_contact htac ON htac.id_acc = accs.id_descendent AND htac.c_contacttype = ed.id_enum_data
  LEFT OUTER JOIN t_av_contact otac ON otac.id_acc = ownacc.id_acc AND otac.c_contacttype = ed.id_enum_data
INNER LOOP JOIN t_account_state accstate ON
      accstate.id_acc = accs.id_descendent AND
      accstate.status IN (%%EXCLUDED_STATES%%) AND
     %%REF_DATE%% BETWEEN accstate.vt_start AND accstate.vt_end
WHERE 1=1 
AND at.b_IsVisibleInHierarchy = '1'
AND ('%%COMPANY_NAME%%' = '' OR EXISTS (SELECT 1 FROM t_av_Contact avc WHERE avc.c_Company LIKE '%%COMPANY_NAME%%' AND avc.id_acc = acc.id_acc))
AND ('%%USER_NAME%%' = '' OR map.nm_login LIKE '%%USER_NAME%%')
AND ns.tx_typ_space = '%%TYPE_SPACE%%' OR (ns.tx_typ_space = 'system_user' and accs.id_ancestor != 1)
) a
where 1=1
AND RowNumber > @PageSize * (@PageNumber -1)
ORDER BY RowNumber
OPTION(MAXDOP 1)