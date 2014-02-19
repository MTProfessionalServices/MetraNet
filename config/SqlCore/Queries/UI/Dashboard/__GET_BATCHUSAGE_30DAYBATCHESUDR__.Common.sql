/*create index IDX_TB_DATE ON t_batch (dt_crt desc) include(n_expected);*/
with cte1 as(
select datediff(day,tb.dt_crt, getutcdate()) as Day_No, count(1) as Batch_Count, sum(tb.n_expected) as UDR_Count from t_batch tb with(nolock, index(IDX_TB_DATE)) where 1=1 and datediff(day,tb.dt_crt, getutcdate()) <= 30 and tb.n_expected > 0 /*and tx_namespace = 'premconf.com/CDR'*/ group by datediff(day,tb.dt_crt, getutcdate()), cast(tb.dt_crt as date)
),
cte2 as(
SELECT TOP (30) n = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id]))
FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2
)
select DATEADD(day, -cte2.n, CAST(GETUTCDATE() AS DATE)) as CalendarDate, cte2.n as Day_No, IsNull(cte1.Batch_Count,0) as Batch_Count, IsNull(cte1.UDR_Count,0) as UDR_Count from cte2 left outer join cte1 on cte2.n = cte1.Day_No
order by cte2.n asc
OPTION (MAXDOP 1)
