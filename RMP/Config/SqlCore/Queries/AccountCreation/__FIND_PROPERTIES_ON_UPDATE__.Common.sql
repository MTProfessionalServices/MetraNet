
select 
map.id_acc,
tac.id_usage_cycle,
ancestor.id_ancestor,
ancestor_map.nm_login,
ancestor_map.nm_space,
ancestor.vt_start,
ancestor.vt_end,
redir.id_payer,
redir_map.nm_login,
redir_map.nm_space,
redir.vt_start,
redir.vt_end,
atype.name,
corporate.id_ancestor as corporate_acc,
root.tx_path path,
state.status status,
ucycle.id_cycle_type,
ucycle.day_of_month,
ucycle.day_of_week,
ucycle.first_day_of_month,
ucycle.second_day_of_month,
ucycle.start_day,
ucycle.start_month,
ucycle.start_year,
t_av_internal.c_folder,
t_av_internal.c_billable
from
t_account_mapper map %%%READCOMMITTED%%%
INNER JOIN (
  select dbo.mtmaxoftwodates(dt_crt,%%ANCESTORDATE%%) ancestor_date,
    dbo.mtmaxoftwodates(dt_crt,%%PAYMENTDATE%%) payment_date,
    dbo.mtmaxoftwodates(dt_crt,%%STATEDATE%%) state_date,
    t_account.id_acc id_acc
    from
    t_account %%%READCOMMITTED%%%) datelist on datelist.id_acc = map.id_acc
    
LEFT OUTER JOIN t_acc_usage_cycle tac %%%READCOMMITTED%%% on tac.id_acc = map.id_acc
INNER JOIN t_account %%%READCOMMITTED%%% on t_account.id_acc = map.id_acc
INNER JOIN t_account_type atype on atype.id_type = t_account.id_type
INNER JOIN t_av_internal %%%READCOMMITTED%%% on t_av_internal.id_acc = map.id_acc
INNER JOIN t_payment_redirection redir %%%READCOMMITTED%%% on redir.id_payee = map.id_acc AND
datelist.payment_date between vt_start AND vt_end
LEFT OUTER JOIN t_account_mapper redir_map %%%READCOMMITTED%%% on redir_map.id_acc = redir.id_payer AND 
%%%UPPER%%%(redir_map.nm_space) = %%%UPPER%%%(N'%%NAMESPACE%%')
INNER JOIN t_account_ancestor root %%%READCOMMITTED%%% on (root.id_ancestor = 1 OR root.id_ancestor = -1) and root.id_descendent = map.id_acc
AND datelist.ancestor_date between root.vt_start AND root.vt_end

LEFT OUTER JOIN
(select distinct id_ancestor, id_descendent from t_account_ancestor corp %%%READCOMMITTED%%% 
INNER JOIN t_account_mapper map1
on corp.id_descendent = map1.id_acc 
INNER join t_account corpacct
on corpacct.id_acc = corp.id_ancestor
INNER JOIN t_account_type corptype
on corptype.id_type = corpacct.id_type
and corptype.b_iscorporate = '1'
where dbo.mtmaxoftwodates(corpacct.dt_crt,%%ANCESTORDATE%%) between corp.vt_start AND corp.vt_end 
)
corporate
on corporate.id_descendent = map.id_acc

INNER JOIN t_account_ancestor ancestor %%%READCOMMITTED%%% on ancestor.id_descendent = map.id_acc AND
ancestor.num_generations = 1 AND datelist.ancestor_date between ancestor.vt_start AND ancestor.vt_end
LEFT OUTER JOIN t_account_mapper ancestor_map %%%READCOMMITTED%%% on ancestor_map.id_acc = ancestor.id_ancestor
AND %%%UPPER%%%(ancestor_map.nm_space) = %%%UPPER%%%(N'%%NAMESPACE%%')
INNER JOIN t_account_state state %%%READCOMMITTED%%% on state.id_acc = map.id_acc AND
datelist.state_date between state.vt_start AND state.vt_end
LEFT OUTER JOIN t_usage_cycle ucycle %%%READCOMMITTED%%% on ucycle.id_usage_cycle = tac.id_usage_cycle
where %%%UPPER%%%(map.nm_login) = %%%UPPER%%%(N'%%LOGINNAME%%') AND %%%UPPER%%%(map.nm_space) = %%%UPPER%%%(N'%%NAMESPACE%%')
