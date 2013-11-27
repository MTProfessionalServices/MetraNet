
/* ==========================================================
For the given materialization, and the given parent billing group,
Return the account ids added during constraint satisfaction
which do not belong to the parent billing group.
=========================================================== */
SELECT bgmt.id_acc AccountID
FROM t_billgroup_member_tmp bgmt
WHERE id_acc NOT IN (SELECT id_acc 
    FROM t_billgroup_member bm
    INNER JOIN t_billgroup bg
        ON bg.id_billgroup = bm.id_billgroup
    INNER JOIN t_billgroup_materialization bgm
        ON bgm.id_usage_interval = bg.id_usage_interval
    WHERE bg.id_billgroup = %%ID_PARENT_BILLGROUP%% AND
                bgm.id_materialization = %%ID_MATERIALIZATION%%)
      AND
      b_extra = 1
GROUP BY bgmt.id_acc
   