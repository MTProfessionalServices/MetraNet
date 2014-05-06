
SELECT 
GETUTCDATE()-cte2.n as CalendarDate, 
cte2.n as Day_No, 
NVL(ctel.Batch_Count,0) as Batch_Count, 
NVL(ctel.UDR_Count,0) as UDR_Count 
FROM 
(
SELECT ROWNUM AS n FROM ALL_OBJECTS WHERE ROWNUM <= 31
) cte2,
(
select
getutcdate()-tb.dt_crt as Day_No,
count(1) as Batch_Count, 
sum(tb.n_expected) as UDR_Count 
from t_batch tb
where 1=1 
and getutcdate()-tb.dt_crt <= 30 
and tb.n_expected > 0 
group by getutcdate()-tb.dt_crt, cast(tb.dt_crt as date)
) ctel
WHERE cte2.n = ctel.Day_No (+)
order by 2 asc
