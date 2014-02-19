/*create index IDX_FT_DATE ON t_failed_transaction (dt_failuretime desc) include(state);*/
with cte1 as(
select datediff(day,ft.dt_FailureTime, getutcdate()) as Days_Old, sum(case when ft.state='R' then 1 else 0 end) as Fixed_Count, sum(case when ft.state='N' then 1 else 0 end) as Open_Count, sum(case when ft.state='I' then 1 else 0 end) as Under_Investigation_Count from t_failed_transaction ft with (nolock, index(IDX_FT_DATE)) where 1=1
and datediff(day,ft.dt_FailureTime, getutcdate()) <= 30
group by datediff(day,ft.dt_FailureTime, getutcdate())
),
cte2 as(
SELECT TOP (30) n = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id]))
FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2
)
select cte2.n as Days_Old, IsNull(cte1.Fixed_Count,0) as Fixed_Count, IsNull(cte1.Open_Count,0) as Open_Count, IsNull(cte1.Under_Investigation_Count,0) as Under_Investigation_count from cte2 left outer join cte1 on cte2.n = cte1.Days_Old
order by cte2.n asc
OPTION (MAXDOP 1)
