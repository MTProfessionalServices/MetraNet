begin
declare @StartDate datetime;
declare @EndDate datetime;

select @EndDate = getutcdate();
select @StartDate = DATEADD(minute,-1, @EndDate)
select
'pipeline_wait_count' as c_category,
count(ss.session_count) as c_count
from t_message m with(nolock)
inner join t_session_set ss with(nolock) on m.id_message = ss.id_message
where 1=1
and m.dt_assigned is null
and m.dt_completed is null
and m.id_pipeline is null
union all
select
'scheduler_wait_count' as c_category,
count(1) as c_count
from mvm_scheduled_tasks tsks with(nolock)
where 1=1
and tsks.is_scheduled = 1
and tsks.mvm_scheduled_dt <= @EndDate
union all
select /* we do not treat resubmits special */
'pipeline_wait_seconds' as c_category,
cast(round( isnull(avg(case when m.dt_crt > m.dt_assigned then 0 else datediff(second,DATEADD(ms, -DATEPART(ms, m.dt_crt), m.dt_crt), m.dt_assigned) end),0.0) , 2)as numeric(22,10)) as c_count
from t_message m with(nolock)
where 1=1
and m.dt_assigned between @StartDate and @EndDate
union all
select /* we do not treat resubmits special */
'pipeline_seconds' as c_category,
cast(round( isnull(avg(datediff(second,m.dt_assigned, m.dt_completed)),0.0) , 2)as numeric(22,10)) as c_count
from t_message m with(nolock)
where 1=1
and m.dt_completed between @StartDate and @EndDate
OPTION(MAXDOP 1, FORCE ORDER)
;
end;
