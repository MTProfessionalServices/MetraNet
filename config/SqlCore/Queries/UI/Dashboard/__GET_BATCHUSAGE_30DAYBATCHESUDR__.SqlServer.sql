WITH cte1 AS(
                SELECT DATEDIFF(DAY, tb.dt_crt, GETUTCDATE()) AS Day_No,
                       COUNT(1) AS Batch_Count,
                       SUM(tb.n_completed + tb.n_failed + tb.n_dismissed) AS UDR_Count
                FROM   t_batch tb WITH(NOLOCK, INDEX(IDX_TB_DATE))
                WHERE  DATEDIFF(DAY, tb.dt_crt, GETUTCDATE()) <= 30
                GROUP BY
                       DATEDIFF(DAY, tb.dt_crt, GETUTCDATE())
            ),
cte2 AS(
           SELECT TOP(31) n = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY s1.[object_id])) 
                  - 1
           FROM   sys.all_objects AS s1
                  CROSS JOIN sys.all_objects AS s2
       )
SELECT DATEADD(DAY, -cte2.n, CAST(GETUTCDATE() AS DATE)) AS CalendarDate,
       cte2.n AS Day_No,
       ISNULL(cte1.Batch_Count, 0) AS Batch_Count,
       ISNULL(cte1.UDR_Count, 0) AS UDR_Count
FROM   cte2
       LEFT OUTER JOIN cte1
            ON  cte2.n = cte1.Day_No
ORDER BY
       cte2.n ASC 
OPTION (MAXDOP 1)