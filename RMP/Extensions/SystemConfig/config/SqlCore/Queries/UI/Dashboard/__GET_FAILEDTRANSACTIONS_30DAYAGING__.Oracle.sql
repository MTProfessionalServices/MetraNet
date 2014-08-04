WITH cte1 AS(
                SELECT trunc(sysdate) - trunc(ft.dt_FailureTime) Days_Old,
                       SUM(CASE WHEN ft.state = 'R' THEN 1 ELSE 0 END) AS 
                       Fixed_Count,
                       SUM(CASE WHEN ft.state = 'N' THEN 1 ELSE 0 END) AS 
                       Open_Count,
                       SUM(CASE WHEN ft.state = 'I' THEN 1 ELSE 0 END) AS 
                       Under_Investigation_Count
                FROM   t_failed_transaction ft
                WHERE  trunc(sysdate) - trunc(ft.dt_FailureTime) <= 30
                GROUP BY
                       trunc(sysdate) - trunc(ft.dt_FailureTime)
            ),
cte2 AS(
           SELECT (ROWNUM - 1) AS n
           FROM   ALL_OBJECTS
           WHERE  ROWNUM <= 31
       )
SELECT cte2.n AS Days_Old,
       NVL(cte1.Fixed_Count, 0) AS Fixed_Count,
       NVL(cte1.Open_Count, 0) AS Open_Count,
       NVL(cte1.Under_Investigation_Count, 0) AS Under_Investigation_count
FROM   cte2
       LEFT OUTER JOIN cte1
            ON  cte2.n = cte1.Days_Old
ORDER BY
       cte2.n ASC