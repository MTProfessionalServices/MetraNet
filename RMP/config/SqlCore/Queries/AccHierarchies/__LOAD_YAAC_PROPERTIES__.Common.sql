
select 
/* __LOAD_YAAC_PROPERTIES__ */
mapper.nm_login as nm_login,
state.status as status, 
case when ancestor.tx_path is NULL then '/'
else
ancestor.tx_path end as tx_path,
case when corporate.id_ancestor is NULL then -1
else
corporate.id_ancestor end as corporate_acc,
atype.name as acc_type,
case when c_billable is NULL then '0' else c_billable end as billable,
case when c_folder is NULL then '0' else c_folder end as IsFolder,
mapper.id_acc id_acc,
mapper.nm_space namespace,
mapper.hierarchydisplayname accountname,
imp.id_owner owner,
t_account.id_acc_ext id_acc_ext,
atype.id_type as AccountTypeID
from
vw_mps_or_system_acc_mapper mapper %%%READCOMMITTED%%%
INNER JOIN t_av_internal tav %%%READCOMMITTED%%% on tav.id_acc = mapper.id_acc
LEFT OUTER JOIN t_account_ancestor ancestor %%%READCOMMITTED%%% on ancestor.id_ancestor = 1 AND
ancestor.id_descendent = tav.id_acc AND %%REFDATE%% between
ancestor.vt_start AND ancestor.vt_end
LEFT OUTER JOIN 
(select id_ancestor, id_descendent from t_account_ancestor corp %%%READCOMMITTED%%% 
INNER JOIN t_av_internal tav
on corp.id_descendent = tav.id_acc AND 
%%REFDATE%% between corp.vt_start AND corp.vt_end 
INNER join t_account corpacct
on corpacct.id_acc = corp.id_ancestor
INNER JOIN t_account_type corptype
on corptype.id_type = corpacct.id_type
and corptype.b_iscorporate = '1'
)
corporate
on corporate.id_descendent = tav.id_acc
INNER JOIN t_account_state state %%%READCOMMITTED%%% on state.id_acc = tav.id_acc AND %%REFDATE%%
between state.vt_start AND state.vt_end 
INNER JOIN t_account %%%READCOMMITTED%%% on t_account.id_acc = tav.id_acc
INNER JOIN t_account_type atype %%%READCOMMITTED%%% on t_account.id_type = atype.id_type
LEFT OUTER JOIN t_impersonate imp %%%READCOMMITTED%%% on imp.id_acc = tav.id_acc
where
%%NAMESPACE_CRITERIA%%
			