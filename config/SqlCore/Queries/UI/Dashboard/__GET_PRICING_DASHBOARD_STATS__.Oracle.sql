select
'pipeline_wait_count' as c_category,
count(ss.session_count) as c_count
from t_message m 
inner join t_session_set ss on m.id_message = ss.id_message
where 1=1
and m.dt_assigned is null
and m.dt_completed is null
and m.id_pipeline is null
--union all
--select
--'scheduler_wait_count' as c_category,
--count(1) as c_count
--from mvm_scheduled_tasks tsks
--where 1=1
--and tsks.is_scheduled = 1
--and tsks.mvm_scheduled_dt <= sysdate
union all
select /* we do not treat resubmits special */
'pipeline_wait_seconds' as c_category,
nvl(avg(extract(day from nvl(m.dt_assigned, GETUTCDATE()) - m.dt_crt)*60*60*24),0.0) as c_count
from t_message m
where 1=1
and nvl(m.dt_assigned, GETUTCDATE()) between (GETUTCDATE() - (1/(60*24))) and GETUTCDATE()
union all
select /* we do not treat resubmits special */
'pipeline_seconds' as c_category,
nvl(avg(extract(day from m.dt_completed - m.dt_assigned) *60*60*24),0.0) as c_count
from t_message m
where 1=1
and m.dt_completed between (SYSDATE - (1/(60*24))) and sysdate

