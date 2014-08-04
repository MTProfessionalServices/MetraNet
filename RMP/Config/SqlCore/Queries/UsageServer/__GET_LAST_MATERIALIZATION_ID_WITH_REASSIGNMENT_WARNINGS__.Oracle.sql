
/* ===========================================================
For the given interval return the latest materialization id 
which had reassignment failures in t_billgroup_member_history.
=========================================================== */
SELECT bgm.id_materialization
FROM t_billgroup_materialization bgm
INNER JOIN t_billgroup_member_history bgmh
   ON bgmh.id_materialization = bgm.id_materialization
WHERE  bgm.dt_start IN (SELECT MAX(dt_start)
                                       FROM t_billgroup_materialization 
                                       WHERE id_usage_interval = %%ID_INTERVAL%%) AND
              DECODE (bgmh.tx_status, 'Failed', 1, NULL) = 1
GROUP BY bgm.id_materialization
   