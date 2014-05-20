SELECT s1.BATCHID,
       s1."DATE",
       s1."TIME",
       TRUNC((s1.LastRunDate - s2.PrevRunDate) * 24 * 60)
FROM   (
           SELECT id_batch AS BATCHID,
                  to_char(dt_crt, 'MON DD') AS "DATE",
                  to_char(dt_crt, 'FMHH:MI PM') AS "TIME",
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