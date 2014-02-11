select 
	aa.id_ancestor topLevelAccountId,
	aa.num_generations numGenerations,
	vwmap.fullname fullName,
	vwmap.displayname displayName,
	vwmap.hierarchydisplayname hierarchyDisplayName
from t_account_ancestor aa
left join vw_mps_or_system_acc_mapper vwmap on aa.id_ancestor = vwmap.id_acc
where aa.id_descendent = @accountId
  and @refDate between aa.vt_start and aa.vt_end
  and aa.num_generations = 
    (select max(num_generations)
    from t_account_ancestor 
    where id_descendent = @accountId
      and @refDate between vt_start and vt_end
      and id_ancestor <> 1)
