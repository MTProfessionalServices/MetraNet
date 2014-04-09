if object_id('tempdb..#tmp') is not null
drop table #tmp

if object_id('tempdb..#tmpacc') is not null
drop table #tmpacc

SELECT parent.* 
INTO #tmp
FROM t_account_ancestor parent
WHERE
  parent.id_ancestor = %%ANCESTOR%% 
AND %%DESCENDENT_RANGE_CHECK%%
      parent.num_generations = 1 
AND %%REF_DATE%% BETWEEN parent.vt_start AND parent.vt_end  

create index idx_tmp on #tmp(id_ancestor, num_generations)
create index idx2_tmp on #tmp(id_descendent, num_generations)

Declare @IsSuperUser bit

/* Determine if the user is a member of "Surep User" role*/
SELECT @IsSuperUser = CASE COUNT(*) WHEN 0 THEN 0 ELSE 1 END
FROM t_principal_policy pp 
	JOIN t_policy_role pr on pp.id_policy = pr.id_policy AND pp.id_acc = %%CURRENT_USER%%
	JOIN t_role r on pr.id_role = r.id_role AND r.tx_name = 'Super User'

CREATE TABLE #tmpacc
(AccountID int, WritePermission bit)

/* Don't check permissions for the Super User*/
IF @IsSuperUser = 0
	INSERT INTO #tmpacc
	SELECT * FROM GetAccountsWithPermission(%%CURRENT_USER%%)

create index idx3_tmp on #tmpacc(AccountID)

Declare @PageSize int
Declare @PageNumber int

set @PageSize=%%PAGE_SIZE%%
set @PageNumber = %%PAGE_NUMBER%%

select top (@PageSize) *
from (

SELECT
 ROW_NUMBER() OVER(ORDER by folder ASC, account_type ASC, hname.hierarchyname ASC) RowNumber,
 foo.account_type,
 hname.icon,
 foo.parent_id,
 foo.child_id,
 foo.children,
 map.nm_login nm_login,
 map.nm_space nm_space,
  hname.hierarchyname hierarchyname,
  CASE WHEN ownername.hierarchyname IS NULL THEN N'' ELSE ownername.hierarchyname END AS folder_owner,
 foo.folder,
 foo.currency,
 foo.status,
 foo.numpayees,
 foo.tx_path,
 ISNULL(foo.WritePermission, @IsSuperUser) AS WritePermission,
 (select CASE COUNT(*) WHEN 0 THEN 0 ELSE 1 END
 from t_capability_instance ci
    join t_composite_capability_type cct on ci.id_cap_type = cct.id_cap_type
    join t_principal_policy pp_acc on pp_acc.id_acc = foo.child_id
    join t_policy_role pr on pp_acc.id_policy = pr.id_policy
    join t_principal_policy pp_p on pp_p.id_role = pr.id_role and ci.id_policy = pp_p.id_policy
where cct.tx_name = 'Application LogOn') HasLogonCapability
FROM
(
SELECT 
  acctype.name account_type,
 parent.id_ancestor parent_id,
 parent.id_descendent child_id,
 parent.b_children children,
 case when descmap.id_type is null then 0 else 1 end folder,
 tav.c_currency currency,
 accstate.status status,
  COUNT(redir.id_payee) numpayees,
  parent.tx_path tx_path,
  imp.id_owner,
  avp.WritePermission
FROM 
  #tmp parent
  /* get folder		  */   
  INNER  JOIN t_av_internal tav ON tav.id_acc = parent.id_descendent %%FOLDERCHECK%%
  LEFT JOIN #tmpacc avp ON avp.accountID = tav.id_acc
  /* get account type */
  INNER  JOIN t_account acc ON acc.id_acc = parent.id_descendent
  INNER  JOIN t_account_type acctype ON acctype.id_type = acc.id_type
   /* get if this account type can have any descendents */
  LEFT OUTER  JOIN t_acctype_descendenttype_map descmap
 on descmap.id_type = acctype.id_type
  LEFT OUTER  JOIN t_impersonate imp ON imp.id_acc = parent.id_descendent
  /* get account state  */ 
  INNER  JOIN t_account_state accstate ON 
      accstate.id_acc = parent.id_descendent AND
    /* account state effective dates */
      %%REF_DATE%% BETWEEN accstate.vt_start AND accstate.vt_end AND
      /* make sure the account IS NOT closed OR archived */
      accstate.status IN (%%EXCLUDED_STATES%%)
  /* get account payment redirection payer IF EXISTS */
  INNER  JOIN t_account_ancestor child ON child.id_descendent = parent.id_descendent AND child.num_generations = 0
  LEFT OUTER  JOIN t_payment_redirection redir ON 
  redir.id_payer = child.id_descendent AND
  %%REF_DATE%% BETWEEN redir.vt_start AND redir.vt_end AND
   redir.id_payee <> child.id_descendent
WHERE
  (@IsSuperUser = 1 OR avp.accountID IS NOT NULL) AND
  acctype.b_IsVisibleInHierarchy = '1' AND
  /* Filter by company and user name for nested levels in the hierarchy */
  ('%%COMPANY_NAME%%' = '' OR EXISTS (SELECT 1 FROM t_av_Contact avc WHERE avc.c_Company LIKE '%%COMPANY_NAME%%' AND avc.id_acc = acc.id_acc)) AND
  ('%%USER_NAME%%' = '' OR EXISTS (SELECT 1 FROM t_account_mapper am WHERE am.nm_login LIKE '%%USER_NAME%%' AND am.id_acc = acc.id_acc))
GROUP BY
 parent.id_ancestor,
 parent.id_descendent,
 parent.b_children,
 tav.c_currency,
 accstate.status,
  parent.tx_path,
  acctype.name,
  descmap.id_type,
  imp.id_owner,
  avp.WritePermission
) foo
  /* get nm_login */
  INNER JOIN vw_mps_or_system_acc_mapper map ON map.id_acc = foo.child_id 
   /* account name */
  INNER JOIN vw_mps_or_system_hierarchyname hname ON hname.id_acc = foo.child_id
  LEFT OUTER JOIN vw_mps_or_system_hierarchyname ownername ON ownername.id_acc = foo.id_owner
  WHERE	map.tx_typ_space = '%%TYPE_SPACE%%' OR (map.tx_typ_space = 'system_user' and foo.parent_id != 1)
) m
where m.RowNumber > @PageSize * (@PageNumber -1)
order by m.RowNumber
