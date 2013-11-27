
        select 
  aa.id_descendent as accountId, 
  hName.hierarchyName as accountName
from
    t_account_ancestor aa
    inner join
    t_account_mapper am on aa.id_descendent = am.id_acc
    inner join
    t_account a on aa.id_descendent = a.id_acc
    inner join
    t_account_type at on a.id_type = at.id_type
	inner join
	VW_HIERARCHYNAME hName on aa.id_descendent = hName.id_acc
	left join t_acc_tmpl_types tatt ON 1 = 1
where
    (COALESCE(tatt.all_types,0) = 1 OR at.name = '%%ACCOUNT_TYPE%%')
    and
    aa.id_ancestor = %%TEMPLATE_OWNER%%
    and
    %%EFFECTIVE_DATE%% between aa.vt_start and aa.vt_end
	and
    (
        %%ACCOUNT_LIST%%
    )
        