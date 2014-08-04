SELECT GETUTCDATE() - cte2.n AS CalendarDate,
       cte2.n AS Day_No,
       NVL(ctel.Batch_Count, 0) AS Batch_Count,
       NVL(ctel.UDR_Count, 0) AS UDR_Count
FROM   (
           SELECT ROWNUM - 1 AS n
           FROM   ALL_OBJECTS
           WHERE  ROWNUM <= 31
       ) cte2,
       (
           SELECT trunc(GETUTCDATE()) - trunc(tb.dt_crt) AS Day_No,
                  COUNT(1) AS Batch_Count,
                  SUM(tb.n_completed + tb.n_failed + tb.n_dismissed) AS UDR_Count
           FROM   t_batch tb
           WHERE  trunc(GETUTCDATE()) - trunc(tb.dt_crt) <= 30
           GROUP BY
                  trunc(GETUTCDATE()) - trunc(tb.dt_crt)
       ) ctel
WHERE  cte2.n = ctel.Day_No (+)
ORDER BY
       2 ASC