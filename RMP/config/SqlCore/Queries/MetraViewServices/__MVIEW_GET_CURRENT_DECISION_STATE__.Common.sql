select /* __MVIEW_GET_CURRENT_DECISION_STATE__ */ *
from agg_decision_info info
inner join agg_decision_audit_trail audt on info.decision_unique_id + case when info.decision_object_id like '%<|BULK<|%' then 'a' else '' end = audt.decision_unique_id
where 1=1
and info.id_acc = %%ID_ACC%%
and audt.id_usage_interval = %%ID_INTERVAL%%
and info.account_qualification_group <> 'bulk_node'
order by info.id_acc, info.decision_unique_id, audt.id_usage_interval, info.tier_priority
