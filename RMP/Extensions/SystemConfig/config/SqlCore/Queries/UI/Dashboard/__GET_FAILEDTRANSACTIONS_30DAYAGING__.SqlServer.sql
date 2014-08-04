/*create index IDX_FT_DATE ON t_failed_transaction (dt_failuretime desc) include(state);*/

WITH cte1 AS(
                SELECT DATEDIFF(DAY, ft.dt_FailureTime, GETUTCDATE()) AS 
                       Days_Old,
                       SUM(CASE WHEN ft.state = 'R' THEN 1 ELSE 0 END) AS 
                       Fixed_Count,
                       SUM(CASE WHEN ft.state = 'N' THEN 1 ELSE 0 END) AS 
                       Open_Count,
                       SUM(CASE WHEN ft.state = 'I' THEN 1 ELSE 0 END) AS 
                       Under_Investigation_Count
                FROM   t_failed_transaction ft WITH (NOLOCK, INDEX(IDX_FT_DATE))
                WHERE  DATEDIFF(DAY, ft.dt_FailureTime, GETUTCDATE()) <= 30
                GROUP BY
                       DATEDIFF(DAY, ft.dt_FailureTime, GETUTCDATE())
            ),
cte2 AS(
           SELECT TOP(31) n = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY s1.[object_id])) 
                  - 1
           FROM   sys.all_objects AS s1
                  CROSS JOIN sys.all_objects AS s2
       )
SELECT cte2.n AS Days_Old,
       ISNULL(cte1.Fixed_Count, 0) AS Fixed_Count,
       ISNULL(cte1.Open_Count, 0) AS Open_Count,
       ISNULL(cte1.Under_Investigation_Count, 0) AS Under_Investigation_count
FROM   cte2
       LEFT OUTER JOIN cte1
            ON  cte2.n = cte1.Days_Old
ORDER BY
       cte2.n ASC 
       OPTION(MAXDOP 1)

