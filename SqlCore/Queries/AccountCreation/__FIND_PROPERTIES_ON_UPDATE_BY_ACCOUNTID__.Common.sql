
select 
%%ID_ACC%%,
tac.id_usage_cycle,
ancestor.id_ancestor,
ancestor_map.nm_login as ancestor_nm_login,
ancestor_map.nm_space as ancestor_nm_space,
ancestor.vt_start as ancestor_vt_start,
ancestor.vt_end as ancestor_vt_end,
redir.id_payer,
redir_map.nm_login as payer_nm_login,
redir_map.nm_space as payer_nm_space,
redir.vt_start as payer_vt_start,
redir.vt_end as payer_vt_end,
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
t_account 
INNER JOIN (
  select dbo.mtmaxoftwodates(dt_crt,%%ANCESTORDATE%%) ancestor_date,
    dbo.mtmaxoftwodates(dt_crt,%%PAYMENTDATE%%) payment_date,
    dbo.mtmaxoftwodates(dt_crt,%%STATEDATE%%) state_date,
    t_account.id_acc id_acc
    from
    t_account) datelist on datelist.id_acc = %%ID_ACC%%
INNER JOIN t_account_type atype on t_account.id_type = atype.id_type    
LEFT OUTER JOIN t_acc_usage_cycle tac on tac.id_acc = %%ID_ACC%%
INNER JOIN t_av_internal on t_av_internal.id_acc =%%ID_ACC%%
INNER JOIN t_payment_redirection redir %%ADD_LOCK%% on redir.id_payee = %%ID_ACC%% AND
datelist.payment_date between vt_start AND vt_end
INNER JOIN vw_mps_or_system_acc_mapper acc_mapper on acc_mapper.id_acc = %%ID_ACC%%
LEFT JOIN t_account_mapper redir_map on redir_map.id_acc = redir.id_payer AND 
redir_map.nm_space = acc_mapper.nm_space
INNER JOIN t_account_ancestor root on (root.id_ancestor = 1 OR root.id_ancestor = -1) and root.id_descendent = %%ID_ACC%%
AND datelist.ancestor_date between root.vt_start AND root.vt_end

LEFT OUTER JOIN
(select distinct id_ancestor, id_descendent from t_account_ancestor corp %%%READCOMMITTED%%% 
INNER join t_account corpacct
on corpacct.id_acc = corp.id_ancestor
INNER JOIN t_account_type corptype
on corptype.id_type = corpacct.id_type
and corptype.b_iscorporate = '1'
where dbo.mtmaxoftwodates(corpacct.dt_crt,%%ANCESTORDATE%%) between corp.vt_start AND corp.vt_end 
and corp.id_descendent = %%ID_ACC%% 
)
corporate
on corporate.id_descendent = t_account.id_acc

INNER JOIN t_account_ancestor ancestor on ancestor.id_descendent = %%ID_ACC%% AND
ancestor.num_generations = 1 AND datelist.ancestor_date between ancestor.vt_start AND ancestor.vt_end
LEFT OUTER JOIN t_account_mapper ancestor_map on ancestor_map.id_acc = ancestor.id_ancestor
AND ancestor_map.nm_space =acc_mapper.nm_space
INNER JOIN t_account_state state on state.id_acc = %%ID_ACC%% AND
datelist.state_date between state.vt_start AND state.vt_end
LEFT OUTER JOIN t_usage_cycle ucycle on ucycle.id_usage_cycle = tac.id_usage_cycle
where
t_account.id_acc =%%ID_ACC%%
