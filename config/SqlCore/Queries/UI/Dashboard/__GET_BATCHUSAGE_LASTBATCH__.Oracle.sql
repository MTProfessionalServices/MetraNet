SELECT s1.BATCHID,
       s1."DATETIME",
       TRUNC((s1.LastRunDate - s2.PrevRunDate) * 24 * 60) "TIME DIFF"
FROM   (
           SELECT id_batch AS BATCHID,
                  dt_crt AS "DATETIME",                  
                  dt_crt AS LastRunDate
           FROM   t_batch
           WHERE  (n_completed + n_failed + n_dismissed) > 0
                  AND ROWNUM <= 1
           ORDER BY
                  dt_crt DESC
       ) s1,
       (
           SELECT MIN(dt_crt) AS PrevRunDate
           FROM   t_batch
           WHERE  ROWNUM <= 2
                  AND (n_completed + n_failed + n_dismissed) > 0
           ORDER BY
                  dt_crt DESC
       ) s2