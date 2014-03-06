;with intv_gaps as
(
	select
	a.id_interval as id_interval_old, dense_rank() over(order by b.id_interval) - 1 as n_gap, b.id_interval as id_interval_new
	from t_usage_interval a
	inner join t_pc_interval b on a.id_usage_cycle = b.id_cycle and b.id_interval >= a.id_interval
	where 1=1
	and a.id_interval = %%ID_INTERVAL%%
)
select /* __MVIEW_GET_CURRENT_DECISION_STATE__ */
tui_start.dt_start as dt_slice_start, tui_end.dt_end as dt_slice_end,
info.*, audt.*
from agg_decision_info info
inner join agg_decision_audit_trail audt on info.decision_unique_id + case when info.decision_object_id like '%<|BULK_AGGREGATE<|%' then 'a' else '' end = audt.decision_unique_id
inner join intv_gaps g on g.id_interval_old = audt.id_usage_interval and g.n_gap = isnull(audt.intervals_remaining,0)
inner join t_usage_interval tui_start on tui_start.id_interval = audt.id_usage_interval
inner join t_pc_interval tui_end on tui_end.id_interval = g.id_interval_new
where 1=1
and info.id_acc = %%ID_ACC%%
and audt.id_usage_interval = %%ID_INTERVAL%%
and isnull(audt.expired,0) = 0
and audt.tt_end = dbo.mtmaxdate()
and info.account_qualification_group <> 'bulk_node'
order by info.id_acc, info.tier_priority, info.decision_unique_id, audt.id_usage_interval
