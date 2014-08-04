select
ad.*,
adi.account_qualification_group,
dt.c_Name as nm_decision,
dt.c_Description as tx_description,
adi.decision_object_id
from 
(select
auat.id_usage_interval,
auat.id_sess,
1 as n_index,
auat.agg_tier_1_id as id_decision,
auat.agg_tier_1_amount_before as amount_before,
auat.agg_tier_1_amount_after as amount_after,
auat.agg_tier_1_perc_elig as percent_eligible,
auat.agg_tier_1_start as qualified_before,
auat.agg_tier_1_end as qualified_after,
auat.agg_tier_1_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 1
union all
select
auat.id_usage_interval,
auat.id_sess,
2 as n_index,
auat.agg_tier_2_id as id_decision,
auat.agg_tier_2_amount_before as amount_before,
auat.agg_tier_2_amount_after as amount_after,
auat.agg_tier_2_perc_elig as percent_eligible,
auat.agg_tier_2_start as qualified_before,
auat.agg_tier_2_end as qualified_after,
auat.agg_tier_2_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 2
union all
select
auat.id_usage_interval,
auat.id_sess,
3 as n_index,
auat.agg_tier_3_id as id_decision,
auat.agg_tier_3_amount_before as amount_before,
auat.agg_tier_3_amount_after as amount_after,
auat.agg_tier_3_perc_elig as percent_eligible,
auat.agg_tier_3_start as qualified_before,
auat.agg_tier_3_end as qualified_after,
auat.agg_tier_3_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 3
union all
select
auat.id_usage_interval,
auat.id_sess,
4 as n_index,
auat.agg_tier_4_id as id_decision,
auat.agg_tier_4_amount_before as amount_before,
auat.agg_tier_4_amount_after as amount_after,
auat.agg_tier_4_perc_elig as percent_eligible,
auat.agg_tier_4_start as qualified_before,
auat.agg_tier_4_end as qualified_after,
auat.agg_tier_4_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 4
union all
select
auat.id_usage_interval,
auat.id_sess,
5 as n_index,
auat.agg_tier_5_id as id_decision,
auat.agg_tier_5_amount_before as amount_before,
auat.agg_tier_5_amount_after as amount_after,
auat.agg_tier_5_perc_elig as percent_eligible,
auat.agg_tier_5_start as qualified_before,
auat.agg_tier_5_end as qualified_after,
auat.agg_tier_5_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 5
union all
select
auat.id_usage_interval,
auat.id_sess,
6 as n_index,
auat.agg_tier_6_id as id_decision,
auat.agg_tier_6_amount_before as amount_before,
auat.agg_tier_6_amount_after as amount_after,
auat.agg_tier_6_perc_elig as percent_eligible,
auat.agg_tier_6_start as qualified_before,
auat.agg_tier_6_end as qualified_after,
auat.agg_tier_6_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 6
union all
select
auat.id_usage_interval,
auat.id_sess,
7 as n_index,
auat.agg_tier_7_id as id_decision,
auat.agg_tier_7_amount_before as amount_before,
auat.agg_tier_7_amount_after as amount_after,
auat.agg_tier_7_perc_elig as percent_eligible,
auat.agg_tier_7_start as qualified_before,
auat.agg_tier_7_end as qualified_after,
auat.agg_tier_7_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 7
union all
select
auat.id_usage_interval,
auat.id_sess,
8 as n_index,
auat.agg_tier_8_id as id_decision,
auat.agg_tier_8_amount_before as amount_before,
auat.agg_tier_8_amount_after as amount_after,
auat.agg_tier_8_perc_elig as percent_eligible,
auat.agg_tier_8_start as qualified_before,
auat.agg_tier_8_end as qualified_after,
auat.agg_tier_8_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 8
union all
select
auat.id_usage_interval,
auat.id_sess,
9 as n_index,
auat.agg_tier_9_id as id_decision,
auat.agg_tier_9_amount_before as amount_before,
auat.agg_tier_9_amount_after as amount_after,
auat.agg_tier_9_perc_elig as percent_eligible,
auat.agg_tier_9_start as qualified_before,
auat.agg_tier_9_end as qualified_after,
auat.agg_tier_9_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 9
union all
select
auat.id_usage_interval,
auat.id_sess,
10 as n_index,
auat.agg_tier_10_id as id_decision,
auat.agg_tier_10_amount_before as amount_before,
auat.agg_tier_10_amount_after as amount_after,
auat.agg_tier_10_perc_elig as percent_eligible,
auat.agg_tier_10_start as qualified_before,
auat.agg_tier_10_end as qualified_after,
auat.agg_tier_10_cqg as amount_chain_group
from agg_usage_audit_trail auat
where 1=1
and auat.agg_applied_tier_counter >= 10
) ad
inner join agg_decision_info adi on adi.decision_unique_id = case when ad.id_decision like '%a' then substr(ad.id_decision, 1, length(ad.id_decision) - 1) else ad.id_decision end
left outer join t_amp_decisiontype dt on dt.c_Name = adi.tier_column_group
where 1=1
order by n_index